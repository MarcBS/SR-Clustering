
%% Segmentation based on color histogram applied in the following paper
%
%   Ghosh, Joydeep, Yong Jae Lee, and Kristen Grauman. "Discovering important 
%   people and objects for egocentric video summarization." 2012 IEEE Conference 
%   on Computer Vision and Pattern Recognition. IEEE, 2012.
%
%%%%%

%% Parameters
% Folder with lifelogging images that we want to segment
% folder = '/Volumes/SHARED HD/Video Summarization Project Data Sets/R-Clustering/Narrative/imageSets/Estefania1';
path_data = '/media/HDD_2TB/DATASETS/LIFELOG_DATASETS';
% folder = '/media/HDD_2TB/DATASETS/LIFELOG_DATASETS/Narrative/imageSets/Estefania1';
folders = {'Estefania1', 'Estefania2', 'Estefania3', 'Petia1', 'Petia2', 'Marc1', 'Maya1', 'Maya2', 'Maya3', 'Mariella', 'Day1', 'Day2', 'Day3', 'Day4', 'Day6'};
% Format of the images in 'folder'
% images_format = '.jpg';
formats = {'.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.JPG', '.JPG', '.JPG', '.JPG', '.JPG'};
cameras = {'Narrative','Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'SenseCam', 'SenseCam', 'SenseCam', 'SenseCam', 'SenseCam'};
% Excel .xls file with the segmentation GT of the data
% (OPTIONAL, comment if you don't want an evaluation of the result) 
% GT_path = '/Volumes/SHARED HD/Video Summarization Project Data Sets/R-Clustering/Narrative/GT/GT_Estefania1.xls';
% GT_path = '/media/HDD_2TB/DATASETS/LIFELOG_DATASETS/Narrative/GT/GT_Estefania1.xls';

% Number of bins per channel extracted from each image
colorFeatures_params.nBins = 23;

% As stated in the paper, they: "set t = 27000 and t = 2250 (i.e., a 60 and 5
% minute temporal window), for UT Ego and ADL, respectively."
% Taking this into account, we use an intermediate time window w.r.t their
% datasets t = 60, which is equivalent to 30 minutes in Narrative (2 fpm).
segmentation_params.t = 10;

%%% Evaluation parameters
tolerance = 5;


%% Add paths and create folders
addpath('../Data_Loading;../Evaluation');

feat_dir = [pwd '/Features'];
if(~exist(feat_dir, 'dir'))
    mkdir(feat_dir)
end



t_vals = [10 25 40 50 60 80 90 100]; 
count_t = 1;
nFolders = length(folders);
Results = struct();
for t = t_vals

	segmentation_params.t = t;

	for f = 1:nFolders
		folder = [path_data '/' cameras{f} '/imageSets/' folders{f}];
		images_format = formats{f};	
		GT_path = [path_data '/' cameras{f} '/GT/GT_' folders{f} '.xls'];
		[folder_path, folder_name, ~] = fileparts(folder);

		%% Load list of files
		files = dir([folder '/*' images_format]);
		files = files(arrayfun(@(x) x.name(1) ~= '.', files));


		%% Extract color features
		path_features = [feat_dir '/ColorFeatures_' folder_name '.mat'];
		if(~exist(path_features, 'file'))
		    disp('Extracting features...');
		    features = extractColorFeatures(folder, images_format, colorFeatures_params);
		    save(path_features, 'features');
		else
		    disp('Loading features...');
		    load(path_features); % features
		end


		%% Segment
		disp('Applying segmentation...');
		clusters = colorSegmentation(features, segmentation_params);
		segments = compute_boundaries(clusters,files);

		%% Evaluate
		[~,clustersID,cl_limGT, ~] = analizarExcel_Narrative(GT_path, files);
		GT=cl_limGT';
		if GT(1) == 1, GT=GT(2:end); end

		nSamples = size(features,1);
		[recall,precision,~,fMeasure]=Rec_Pre_Acc_Evaluation(GT,segments,nSamples,tolerance);

% 		f = figure;
% 		imagesc([clusters'; clustersID]);
% 		saveas(f, [folder_name '_' num2str(segmentation_params.t) '.jpg']);

		Results(f).precision(count_t) = precision;
		Results(f).recall(count_t) = recall;
		Results(f).fMeasure(count_t) = fMeasure;
		Results(f).t(count_t) = segmentation_params.t;
		Results(f).segments{count_t} = segments;

		%% Plot result
		disp(['-------- Results Color Segmentation --------']);
		disp(['Precision: ' num2str(precision)]);
		disp(['Recall: ' num2str(recall)]);
		disp(['F-Measure: ' num2str(fMeasure)]);
	
	end
	count_t = count_t+1;
end

save('Results_Grauman.mat', 'Results');
exit;
