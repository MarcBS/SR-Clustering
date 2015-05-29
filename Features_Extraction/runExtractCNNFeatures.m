
%% This scripts uses the ConvolutionalNN provided by Caffe to extract features
% for the given set of images.

%%% Dataset parameters
% data_path = '/media/lifelogging/HDD 2TB/LIFELOG_DATASETS/SenseCam/imageSets/terrassaPatient1';
% folders = {'day6' 'day7' 'day8' 'day9'};
% format = '.JPG';

data_path = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS';
folders = {'MAngeles1', 'MAngeles2', 'MAngeles3'};
cameras = {'Narrative', 'Narrative', 'Narrative'}; 
formats = {'.jpg', '.jpg', '.jpg'};

%%% CNN parameters
CNN_params.caffe_path = '/usr/local/caffe-dev/matlab/caffe';
CNN_params.use_gpu = 1;
CNN_params.batch_size = 10; % Depending on the deploy net structure!!
CNN_params.model_def_file = '../../models/bvlc_reference_caffenet/deploy_signed_features.prototxt';
CNN_params.model_file = '../../models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel';
CNN_params.size_features = 4096;


extractCNNFeatures(data_path, folders, cameras, formats, CNN_params);