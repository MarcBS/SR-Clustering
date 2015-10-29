
%% This scripts uses the ConvolutionalNN provided by Caffe to extract features
% for the given set of images.

%%% Dataset parameters
% data_path = '/media/lifelogging/HDD 2TB/LIFELOG_DATASETS/SenseCam/imageSets/terrassaPatient1';
% folders = {'day6' 'day7' 'day8' 'day9'};
% format = '.JPG';

data_path = '/media/lifelogging/HDD_2TB/DATASETS/LIFELOG_DATASETS';
folders = {'Maya2', 'Maya3', 'Estefania3'};
cameras = {'Narrative', 'Narrative', 'Narrative'}; 
formats = {'.jpg', '.jpg', '.jpg'};

%%% CNN parameters
CNN_params.caffe_path = '/usr/local/caffe-master2/matlab/caffe';
CNN_params.use_gpu = 1;
CNN_params.batch_size = 10; % Depending on the deploy net structure!!
CNN_params.model_def_file = '/media/lifelogging/HDD_2TB/CNN_MODELS/Caffenet_Reference/deploy_signed_features.prototxt';
CNN_params.model_file = '/media/lifelogging/HDD_2TB/CNN_MODELS/Caffenet_Reference/bvlc_reference_caffenet.caffemodel';
CNN_params.size_features = 4096;


extractCNNFeatures(data_path, folders, cameras, formats, CNN_params);

disp('Done');
exit;
