
addpath('../Features_Preprocessing');

%% Parameters
volume_path = '/media/lifelogging';

feat_path = [volume_path '/HDD_2TB/Video Summarization Objects/Features/Data R-Clustering Ferrari']; % folder where we want to store the features for each object
path_folders = [volume_path '/HDD_2TB/LIFELOG_DATASETS'];

%%% R-Clustering Dataset
folders = {'Narrative/imageSets/Estefania1_resized', 'Narrative/imageSets/Estefania2_resized', ...
        'Narrative/imageSets/Petia1_resized', 'Narrative/imageSets/Petia2_resized', ...
        'Narrative/imageSets/Mariella_resized', 'SenseCam/imageSets/Day1', 'SenseCam/imageSets/Day2', ...
        'SenseCam/imageSets/Day3', 'SenseCam/imageSets/Day4', 'SenseCam/imageSets/Day6'};
format = {'.jpg', '.JPG'};

prop_res = 1.25; % (SenseCam 4, PASCAL 1, MSRC 1.25, Perina 1.25, Toy Problem 1, Narrative_stnd 1) resize proportion for the loaded images --> size(img)/prop_res

% Grauman's features (not used)
feature_params.bLAB = 15; % bins per channel of the Lab colormap histogram (15)
feature_params.wSIFT = 16; % width of the patch used for SIFT calculation (16)
feature_params.dSIFT = 10; % distance between centers of each neighbouring patches (10)
feature_params.lHOG = 3; % number of levels used for the P-HOG (2 better 'PASCAL_07 GT', 3 original)
feature_params.bHOG = 8; % number of bins used for the P-HOG (8)
feature_params.M = 200; % dimensionality of the vocabulary used (200)
feature_params.L = 2; % number of levels used in the SPM (2)
% CNN features
feature_params.lenCNN = 4096; % length of the vector of features extracted from the CNN (4096)

% Number of different abstract concrepts resulting from the clustering and 
% that will be introduced to the Bag of Refill.
nConcepts = 200;
% Number of samples used in the concrept grouping chosen randomly from all
% of them.
nSamplesUsed = 20000;

feat_type = 'CNN'; % 'CNN' or 'LSH'
nHyperplanes = 128; % LSH option only


%% Load objects file
disp('Loading objects.mat file...')
load([feat_path '/objects.mat']); % objects


%% Get all indices of all objects in a matrix
all_indices = getAllIndices(objects);
nSamples = size(all_indices,1);
fprintf('Size all_indices: %d\n', nSamples);

nSamplesUsed = min(nSamplesUsed, nSamples);
fprintf('Picking %d samples randomly...\n', nSamplesUsed);
all_indices = all_indices(randsample(1:nSamples,nSamplesUsed),:);


%% Recover features from all samples
fprintf('Recovering features from %d samples...\n', nSamplesUsed);
[all_features, ~] = recoverFeatures(objects, all_indices, ones(1,size(all_indices,1)), NaN, NaN, NaN, NaN, feature_params, feat_path, false, 0, path_folders, prop_res, [2 0], NaN);

if(strcmp(feat_type, 'CNN'))
    all_features = normalize(all_features);
elseif(strcmp(feat_type, 'LSH'))
    all_features = signedRootNormalization(all_features);
    nFeatures = size(all_features,2);
    % Create hyperplane
    r = zeros(nHyperplanes, nFeatures);
    for i = 1:nHyperplanes
        r(i,:) = mvnrnd(0,1,nFeatures)';
    end
    % Apply LSH
    h = zeros(size(all_features,1), nHyperplanes);
    for i = 1:nHyperplanes
        h_tmp = r(i,:)*all_features';
        h_tmp(h_tmp >= 0) = 1;
        h_tmp(h_tmp < 0) = 0;
        h(:,i) = h_tmp';
    end
    all_features = h;
end

%% Clustering
disp('Calculate similarity matrix...');
simil = squareform(pdist(all_features, 'euclidean'));

disp('Starting clustering...');
Z = linkage(simil, 'ward');    
clustersId = cluster(Z, 'maxclust', nConcepts, 'criterion', 'distance');
final_clusters = unique(clustersId);

%% Split samples in different concepts
disp(['Storing final ' num2str(length(final_clusters)) ' concepts split...']);
folder_name = sprintf(['Concepts_%0.4d_' feat_type '_split'], nConcepts);
mkdir(folder_name);
for i = 1:length(final_clusters)
    this_samples = clustersId == final_clusters(i);
    features = all_features(this_samples, :);
    indices = all_indices(this_samples, :);
    save(sprintf([folder_name '/features_%0.4d'], i), 'features');
    save(sprintf([folder_name '/indices_%0.4d'], i), 'indices');
end

disp('Done');

exit;

