#!/usr/bin/python


from utils.Variable import Path
from utils.Variable import Config
import caffe

import numpy as np
import csv


class CNN:
    def __init__(self, folder):
        self.folder = folder

    def execute(self):
        # CPU/GPU mode
        if Config.cnn_gpu:
            caffe.set_mode_gpu()
            caffe.set_device_id(1)
        else:
            caffe.set_mode_cpu()
        # Configure net
        net = caffe.Net(Path.cnn_deploy,    # defines the structure of the model
                        Path.cnn_model,     # contains the trained weights
                        caffe.TEST)         # use test mode (e.g., don't perform dropout)
        net.blobs['data'].reshape(Config.cnn_batch_size,    # batch size
                                  3,                        # 3-channel (BGR) images
                                  227, 227)                 # image size is 227x227
