#!/usr/bin/python

import os

from features.CNN import CNN
from utils.Variable import Path


class SRClustering:

    def __init__(self, folder_path, folder_name):
        self.folder_path = folder_path
        self.folder_name = folder_name

    def execute(self):
        # Check if CNN features are computed
        cnn_features = Path.cnn_features + '/' + self.folder_name + '.csv'
        if not os.path.isfile(cnn_features):
            print('Extracting CNN features from', self.folder_name)
            cnn = CNN(self.folder_path, self.folder_name)
            cnn_features = cnn.execute()
        semantic_features = Path.semantic_features + '/' + + self.folder_name + '.csv'
        if not os.path.isfile(semantic_features):
            print('Extracting Semantic features from', self.folder_name)
