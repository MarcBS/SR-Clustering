
addpath('../Data_Loading;..;../Tests;../Features_Extraction;../Utils;../Concept_Detector;../Concept_Detector/fastsmooth;../LSDA;../Evaluation');

%%%%%%%%%%% Parameters %%%%%%%%%%%

%% Data parameters

%% Features path
data_params.features_path = ['/media/********/HDD/EDUB-Seg/Features'];

%%% R-Clustering results path
data_params.RC_results_path = ['/media/********/HDD/EDUB-Seg/Results'];
data_params.RC_plot_results_path = ['/media/********/HDD/EDUB-Seg/Plot_Results'];

% Additional parameters
data_params.min_length_merge = 5; % (default 0) minimum length of segments, if smaller, will be merged to most similar adjacent segment.


%% Methods used

% Agglomerative clustering distance criterion
% methods_indx={'ward', 'complete','centroid','average','single','weighted','median'};
R_Clustering_params.methods_indx = 'single';  % Narrative Semantic (Imagga) 'centroid'
                                                % Narrative LSDA 'single'
                                                % All Non-Semantic 'single'

% R-Clustering combined methods
R_Clustering_params.clus_type = 'Both1';    % Clustering type used before the GraphCuts.
                                            % It can take the following values:
                                            %   'Clustering' : Clustering + GC
                                            %   'Both1' : Clustering + Adwin + GC (RECOMMENDED)

%%% Cut values used
R_Clustering_params.cut_indx_use = 0.4; % Narrative Semantic (Imagga) 0.2
                                        % Narrative LSDA 0.4
                                        % All Non-Semantic 0.2

%%% GT weight values
R_Clustering_params.W_unary = 0.9;      % 0 <= W_unary <= 1
                                        % Narrative Semantic (Imagga) 0.9
                                        % Narrative LSDA 0.9
                                        % All Non-Semantic 1

R_Clustering_params.W_pairwise = 1;   % 0.00001 <= W_pairwise <= 1
                                        % Narrative Semantic (Imagga) 0.9
                                        % Narrative LSDA 1
                                        % All Non-Semantic 0.5

%%% Features used
R_Clustering_params.features_used = 3;  % 1 -> Global CNN only
                                        % 2 -> Global and Semantic (IMAGGA)
                                        % 3 -> Global and Semantic (LSDA)


%% CNN parameters (Global Features)
% Installation-dependent
CNN_params.use_gpu = 1;
CNN_params.batch_size = 30; % Depending on the deploy net structure!!
CNN_params.model_file ='/media/HDD_2TB/CNN_MODELS/Caffenet_Reference/bvlc_reference_caffenet.caffemodel';
CNN_params.size_features = 4096;
CNN_params.caffe_path = '/usr/local/caffe-master2/matlab/caffe'; % installation path

% Model-dependent
CNN_params.parallel = false; % allow loading images in parallel
CNN_params.mean_file = '../Utils/ilsvrc_2012_mean.mat';

[structure_path, ~, ~] = fileparts(pwd);
CNN_params.model_def_file = [structure_path '/Utils/deploy_signed_features.prototxt'];
%CNN_params.model_def_file = '../../models/bvlc_reference_caffenet/deploy_signed_features.prototxt';


%% Semantic Features parameters
Semantic_params.endpoint = 'http://api.imagga.com/'; % link to Imagga's API
Semantic_params.api_key = 'api_key'; % API key of IMAGGA account
Semantic_params.api_secret = 'api_secret'; % API password of IMAGGA account

% Filters all tags with a mean value over or under times_std
Semantic_params.filter_tags_high_mean = true;
Semantic_params.times_std_over = 6; % the smaller, the more we filter
Semantic_params.times_std_under = 1; % the smaller, the more we filter

% Smoothing
Semantic_params.use_smoothing = false;
Semantic_params.smoothing_param = 10;

% LSDA
Semantic_params.path_lsda_repository = '../LSDA/lsda';
Semantic_params.batch_size = 128; % batch size must match the definition file!
Semantic_params.definition_file = 'model-defs/imagenet_rcnn_batch_256_output_fc7.prototxt';


%% Plot results parameters

% Minimum number of images allowed per segment when plotting
plot_params.min_imgs_event = 1;%9;

% Proportions for plot purposes
plot_params.prop_div = 20;

% Which plots apply?
% {image whole dataset,   image per segment,    single images splitted by segments in folders}
plot_params.doPlots = {false, false, false};


%% Create some folders for results
if(~exist(data_params.features_path, 'dir'))
    mkdir(data_params.features_path);
    mkdir([data_params.features_path '/CNNfeatures']);
    mkdir([data_params.features_path '/SemanticFeatures']);
end
if(~exist(data_params.RC_results_path, 'dir'))
    mkdir(data_params.RC_results_path);
end
if(~exist(data_params.RC_plot_results_path, 'dir'))
    mkdir(data_params.RC_plot_results_path);
end
