#!/usr/bin/python

import os

from features.CNN import CNN
from utils.Variable import Path


class SRClustering:

    def __init__(self, folder_path, folder_name):
        self.folder_path = folder_path
        self.folder_name = folder_name

    def execute(self):
        # List containing all the images of the folder
        included_extensions = ['jpg']
        images_names = [fn for fn in os.listdiraz(self.folder_path + "/" + self.folder_name)
                        if any(fn.endswith(ext) for ext in included_extensions)]
        images_names = sorted(images_names)

        # Check if CNN features are computed
        cnn_features = Path.cnn_features + "/" + self.folder_name + ".csv"
        if not os.path.isfile(cnn_features):
            print "Extracting CNN features from", self.folder_name
            cnn = CNN(self.folder_path + "/" + self.folder_name)
            ret = cnn.execute()
            if not ret:
                # An error has occurred during the process
                return 0
