%% Main for loading the data before Graph-Cuts application and evaluation

%% Params
addpath('../Evaluation;../GCMex');
data_path = '../GC_IBPRIA';

clus_type = 'Both'; % Clustering type used before the GraphCuts. 
                    % It can take the following values:
                    %           'Clustering'
                    %           'Both'

win_len = 11;
W_unary = 1e3;    % W > 0
W_pairwise = 0.5;   % 0 <= W2 <= 1

tolerance = 3; % tolerance for the final evaluation

evalType = 2; % 1 = single test, 2 = iterative W increase

doEvaluation = true; % plot precision/recall and f-measure when performing single test
maxTest = 10+1; % 25+1


%% Load previous data
%%% Load clustering result
load([data_path '/Results_Petia2.mat']); % RPAF
classes = RPAF{5,7}';
unique_classes = unique(classes); 
nClasses = length(unique_classes);
clear RPAF;

%%% Load CNN features
load([data_path '/Petia/CNN_features_petia2.mat']); % features
nSamples = size(features,1);

%%% Load Ground Truth
[~, ~, GT, ~] = analizarExcel_Narrative([data_path '/Petia/GT_Petia2.xls'],[data_path '/petia_2']);
GT = GT';



%% Normalize features using signed root normalization
[features_time] = normalizeL2([features (1:nSamples)']);
[features, ~, ~] = normalize(features);


%% Get Likelihoods from classes w.r.t distances and clustering
% Change by clustering P matrix
LH_Clus = getLHFromClustering(features_time, classes);

%% Convert LH results on events separation (on clustering)
[~, start_clus, ~] = getEventsFromLH(LH_Clus);


%% Build and calculate the Graph-Cuts
if(evalType == 2)
    
    fig = doIterativeTest({LH_Clus}, {start_clus}, maxTest, win_len, W_unary, W_pairwise, features, tolerance, GT, clus_type);
    
elseif(evalType == 1)
    
    doSingleTest({LH_Clus}, {start_clus}, win_len, W_unary, W_pairwise, features, tolerance, GT, doEvaluation, clus_type);

end
