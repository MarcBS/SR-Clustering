The script demo.m offers an example of the results obtained by the SR-Clustering algorithm.


Before running the demo modify consequently the following parameters:
    loadParametersDemo.m
        CNN_params.caffe_path: absolute path to the '/path_to_caffe_installation/matlab/caffe' directory
        CNN_params.use_gpu: should only be '1' if your Caffe installation is enabled for GPU computation
        CNN_params.model_file: absolute path to CaffeNet model (must be downloaded from Caffe)
		http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel
        CNN_params.mean_file: absolute path to the '.mat' mean image for substraction
        Semantic_params.api_key: API key of your IMAGGA account (for semantic features extraction)
        Semantic_params.api_secret: API password of your IMAGGA account (for semantic features extraction)
    demo.m
        folder: absolute path to the lifelogging images we want to segment
        format: format of the images in 'folder'


Just run to test on the demo dataset with the default parameters, or change 
the parameters (in loadParamatersDemo.m) consequently.

The output of the demo function will be a .txt file in 'Results' folder, where each line describes the list 
of images segmented in a different event. Additionally, you can generate three kinds of mosaics as an output 
(see plot_params in loadParametersDemo.m).
