#!/usr/bin/python


class Path:

    caffe_path = "/home/marcvaldivia/code/caffe/python"

    features = "/media/marcvaldivia/HDD1/EDUB-Seg/Features"
    results = "/media/marcvaldivia/HDD1/EDUB-Seg/Results"

    cnn_model = "/home/marcvaldivia/code/caffe/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel"
    cnn_deploy = "/home/marcvaldivia/code/caffe/models/bvlc_reference_caffenet/deploy_signed_features.prototxt"
    cnn_mean = ""

    cnn_features = features + "/CNNFeatures"
    semantic_features = features + "/SemanticFeatures"


class Config:

    method_idx = "single"       # ["ward", "complete", "centroid", "average", "single", "weighted", "median"]
    clustering_type = "Both1"
    cut_idx = 0.4
    W_unary = 0.9
    W_pairwise = 1

    # 1 -> Global CNN only
    # 2 -> Global and Semantic
    features_used = 2

    cnn_gpu = 0
    cnn_batch_size = 30
