
addpath('../Data_Loading;..;../Tests;../Features_Extraction');

%% Parameters

%%% Folders used
folders={'Subject1'};
% folders={'Marc1', '...', '...', '...'};
cameras = {'Narrative'}; % Camera used (dataset must be stored in the corresponding folder)
% cameras = {'...', '...', '...', '...'};
formats={'.jpg'}; % Images format
% formats={'.jpg', '...', '...', '...'};

% Use GT to evaluate the result?
eval_GT = true;

%%% Data path
files_path_base = '/media/lifelogging/HDD_2TB/R-Clustering/Demo/test_data';

%%% R-Clustering results path
RC_results_path = '/media/lifelogging/HDD_2TB/R-Clustering/Demo/test_data/Results';
RC_plot_results_path = '/media/lifelogging/HDD_2TB/R-Clustering/Demo/test_data/Plot_Results';


%%% Methods used

% Agglomerative clustering distance criterion
% methods_indx={'ward', 'complete','centroid','average','single','weighted','median'};
methods_indx={'single'}; % (IbPRIA 'single' best)

% R-Clustering combined methods
clus_type = 'Both1'; % Clustering type used before the GraphCuts. 
                        % It can take the following values:
                        %   'Clustering' : Clustering + GC
                        %   'Both1' : Clustering + Adwin + GC (RECOMMENDED)
                        %   'Spectral' : Spectral + GC
                        %   'Both2' : Spectral + Adwin + GC

%%% Cut values used
cut_indx_use = [0.2]; % ALL IbPRIA best
% cut_indx_use = [0.8]; % SenseCam IbPRIA best

%%% GT weight values
W_unary = 1;      % 0 <= W_unary <= 1 for evalType == 1 (IbPRIA 1 best)
W_pairwise = 0.5;   % 0 <= W_pairwise <= 1 for evalType == 1 (IbPRIA 0.5 best)


%%% CNN parameters
% Installation-dependent
CNN_params.caffe_path = '/usr/local/caffe-dev/matlab/caffe'; % installation path
CNN_params.use_gpu = 1;
% Model-dependent
CNN_params.batch_size = 10; % Depending on the deploy net structure!!
CNN_params.model_def_file = '../../models/bvlc_reference_caffenet/deploy_signed_features.prototxt';
CNN_params.model_file = '../../models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel';
CNN_params.size_features = 4096;


%%% Plot results parameters

% Minimum #images allowed per segment when plotting
min_imgs_event = 0;

% Proportions for plot purposes
prop_div = 20; % (Narrative)
% prop_div = 2; % (SenseCam)

% Which plots apply?
% {image whole dataset,   image per segment,    single images splitted by segments in folders}
doPlots = {false, true, false};