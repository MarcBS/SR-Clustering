%%%%%
%
% File for loading the main parameters for R-Clustering
%
%%%%%%%%%%%%%%%%%%%%%%

% clear all, close all

%% Load paths
addpath('Adwin;Data_Loading;Evaluation;Features_Preprocessing');
addpath('GCMex;GraphCuts;PCA;Tests;Utils');

%% Data loading
directorio_im = 'D:/LIFELOG_DATASETS'; % SHARED PC
% directorio_im = ''; % put your own datasets location

camera = {'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'SenseCam', 'SenseCam', 'SenseCam', 'SenseCam', 'SenseCam'};
folders={'Estefania1', 'Estefania2', 'Petia1', 'Petia2', 'Mariella', 'Day1','Day2','Day3','Day4','Day6'};
formats={'.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.JPG','.JPG','.JPG','.JPG','.JPG'};

directorio_results = 'D:/R-Clustering_Results'; % SHARED PC
% directorio_results = ''; % put your own results location

%% R-Clustering parameters
clus_type = 'Clustering'; % Clustering type used before the GraphCuts. 
                        % It can take the following values:
                        %           'Clustering'
                        %           'Both'

                        
%% Clustering parameters
methods_indx={'ward','centroid','complete','weighted','single','median','average'};
%methods_indx={'average'};
cut_indx=(0.2:0.05:1.6);
paramsPCA.minVarPCA=0.95;
paramsPCA.standarizePCA=true;

%% Adwin parameters
pnorm = 2;
confidence = 0.1;

%% GraphCuts parameters
win_len = 11;
W = 200;    % W > 0   W = 1e3    W = 200       W = 0.002
W2 = 0.5;   % 0 <= W2 <= 1
maxTest = 10+1; % 25+1
evalType = 2; % 1 = single test, 2 = iterative W increase
doEvaluation = true; % plot precision/recall and f-measure when performing single test
    

tol=5; % tolerance for the final evaluation
minImCl=0; % (deprecated)