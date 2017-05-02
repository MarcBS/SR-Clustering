#!/usr/bin/python

import os

from utils.Variable import Path
from utils.Variable import Config

import caffe

import numpy as np
import csv

# Image processing library
import scipy


class CNN:
    def __init__(self, folder_path, folder_name):
        self.folder_path = folder_path
        self.folder_name = folder_name
        self.mu = np.load(Path.caffe_path + '/caffe/imagenet/ilsvrc_2012_mean.npy')
        self.resize = 256
        self.resize_mode = 'bilinear'
        self.crop = 227

    def crop_center(self, img, crop_x, crop_y):
        y, x = img.shape
        start_x = x // 2 - (crop_x // 2)
        start_y = y // 2 - (crop_y // 2)
        return img[start_y:start_y + crop_y, start_x:start_x + crop_x]

    def process_image(self, image):
        img_matrix = np.array(scipy.misc.imresize(image, size=[self.resize, self.resize], interp=self.resize_mode))
        # Swap to make a (3, 256, 256) image
        swapped = np.swapaxes(img_matrix, 0, 2)
        swapped = np.swapaxes(swapped, 1, 2)
        # Convert RGB to BGR
        tmp = np.array(swapped)
        swapped[:][:][0] = tmp[:][:][2]
        swapped[:][:][2] = tmp[:][:][0]
        # Subtract the mean
        img_subs = swapped - self.mu
        # Crop the center of the image
        cropped0 = self.crop_center(img_subs[:][:][0], self.crop, self.crop)
        cropped1 = self.crop_center(img_subs[:][:][1], self.crop, self.crop)
        cropped2 = self.crop_center(img_subs[:][:][2], self.crop, self.crop)
        cropped = [cropped0, cropped1, cropped2]
        cropped = np.array(cropped)
        return cropped

    def execute(self):
        # CPU/GPU mode
        if Config.cnn_gpu:
            caffe.set_mode_gpu()
            caffe.set_device_id(1)
        else:
            caffe.set_mode_cpu()
        # Configure net
        net = caffe.Net(Path.cnn_deploy,  # defines the structure of the model
                        Path.cnn_model,  # contains the trained weights
                        caffe.TEST)  # use test mode (e.g., don't perform dropout)
        net.blobs['data'].reshape(Config.cnn_batch_size,  # batch size
                                  3,  # 3-channel (BGR) images
                                  227, 227)  # image size is 227x227
        # Folder images
        folder_path = self.folder_path + '/' + self.folder_name
        included_extensions = ['jpg']
        images_names = [fn for fn in os.listdir(folder_path)
                        if any(fn.endswith(ext) for ext in included_extensions)]
        images_names = sorted(images_names)
        # Process images
        features_list = list()
        for img in images_names:
            # load image
            image = scipy.misc.imread(folder_path + '/' +  img)
            transformed_image = self.process_image(image)
            # copy the image data into the memory allocated for the net
            net.blobs['data'].data[...] = [transformed_image]
            # perform classification
            net.forward()
            # fc7 layer values
            features = net.blobs['fc7'].data
            features_list.append(np.array(features[0]))
        # Save a csv with the results
        numpy_features = np.asarray(features_list)
        csv_name = 'CNNfeatures_' + self.folder_name + '.csv'
        result_path = Path.features + '/CNNfeatures/'
        with open(result_path + csv_name, 'wb') as fp:
            wr = csv.writer(fp, delimiter=',')
            wr.writerows(numpy_features)
        return result_path + csv_name