addpath('../Data_Loading;..');

%%% Folders used
% folders={'Petia1', 'Petia2','Mariella','Estefania1','Estefania2'};
% folders={'Petia1'};
% folders={'Day1','Day2','Day3','Day4','Day6'};
% folders={'day2','day3','day4','day5','day6','day7','day8','day9'};
% folders={'Petia1','Petia2','Mariella','Estefania1','Estefania2','Day1','Day2','Day3','Day4','Day6'};
% folders = {'Estefania1'};
folders={'Marc1', 'MAngeles1', 'MAngeles2', 'MAngeles3'};
cameras = {'Narrative', 'Narrative', 'Narrative', 'Narrative'};


%%% Data path
% files_path_base = 'D:/LIFELOG_DATASETS';
files_path_base = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS';
% files_path_base = '/Volumes/SHARED HD/Video Summarization Project Data Sets/R-Clustering'; % MARC

%%% GT path
% GT_path = 'D:/LIFELOG_DATASETS/Narrative/GT';
GT_path = '/Volumes/SHARED HD/Video Summarization Project Data Sets/R-Clustering/Narrative/GT'; % MARC PC

%%% R-Clustering results path
RC_results_path = 'media/lifelogging/HDD_2TB/R-Clustering_Results';

%%% Methods used
% methods_indx={'ward', 'complete','centroid','average','single','weighted','median'};
methods_indx={'single'}; % IbPRIA single best
clus_type = 'Both1'; % Clustering type used before the GraphCuts. 
                        % It can take the following values:
                        %           'Clustering' : Clustering + GC
                        %           'Both1' : Clustering + Adwin + GC
                        %           'Spectral' : Spectral + GC
                        %           'Both2' : Spectral + Adwin + GC

%%% Cut values used
cut_indx=(0.45:0.05:0.8); % narrative
% cut_indx = [0.8]; % patient
cut_indx_use = [0.2]; % IbPRIA 0.2 best??

%%% Images format
formats={'.jpg', '.jpg', '.jpg', '.jpg', '.jpg'};

W_unary = 1;      % 0 <= W_unary <= 1 for evalType == 1
W_pairwise = 0.5;   % 0 <= W_pairwise <= 1 for evalType == 1

min_imgs_event = 0;

prop_div = 20; % rest?
% prop_div = 2; % patient day 1

% Use the real data GT or use the segmentation software
use_GT = false;

% {image whole dataset,   image per segment,    single images splitted by segments}
doPlots = {false, false, true};

%% Build params in case the results are not generated
params.RC_results_path = RC_results_path;

params.doEvaluation = false;

%%% Clustering parameters
params.methods_indx = methods_indx;
params.cut_indx_use = cut_indx_use;

%%% R-Clustering parameters
params.clus_type = clus_type;

params.W_unary = W_unary;
params.W_pairwise = W_pairwise;

%% Results path
% results = 'D:/R-Clustering_Results/PlotResults_GT';
% results = '/Volumes/SHARED HD/R-Clustering Results/PlotResults_GT'; % MARC
results = '/media/lifelogging/HDD_2TB/R-Clustering_Results/PlotResults_R-Clustering';

%% Start data processing
for i_met=1:length(methods_indx)
     method=methods_indx{i_met};
     for i_ind=1:length(cut_indx_use)
        Matrix_aux=zeros(5,11,length(folders));
        for i_fold=1:length(folders)
            folder = folders{i_fold};
            format = formats{i_fold};
            
            files_path = [files_path_base '/' cameras{i_fold} '/imageSets'];
            path_source = [files_path '/' folder];
            files_aux = dir([path_source '/*' formats{i_fold}]);
            count = 1;
            files = struct('name', []);
            for n_files = 1:length(files_aux)
                if(files_aux(n_files).name(1) ~= '.')
                    files(count).name = files_aux(n_files).name;
                    count = count+1;
                end
            end
%             path_source = [volume '/Segmentation_Adwin_Cluster_GC/GC_IBPRIA/' folder];
%             path_source = [volume '/Segmentation_Adwin_Cluster_GC/GC_IBPRIA/petia_2'];
            
            %% Use R-Clustering results
            if(~use_GT)
                try
%                     file_saved=(['Results_' method '_Res_' clus_type '_' folder '.mat']);
                    load([RC_results_path '/' folder '/' folder '_' method '_Res_Both_' num2str(find(cut_indx==cut_indx_use(i_ind))) '.mat']);
                    %% Get cluster indices of best narrative result
                    clusIds = [Results{4}(W_unary,W_pairwise,:)];
                    clusIds = reshape(clusIds,[1 size(clusIds,3)]);
                catch
                    % If file does not exist
                    params.files_path = files_path_base;
                    params.formats = format;
                    %% Get cluster indices applying R-Clustering
                    cd ..
                    clusIds = process_single_sequence(cameras{i_fold}, folder, params);
                    cd Tests
                end
                
                nFrames = length(clusIds);
                event = zeros(1, nFrames); event(1) = 1;
                prev = 1;
                for i = 1:nFrames
                    if(clusIds(i) == 0)
                        event(i) = 0;
                    else
                        if(clusIds(i) == clusIds(prev))
                            event(i) = event(prev);
                        else
                            event(i) = event(prev)+1;
                        end
                        prev = i;
                    end
                end
            %% Use GT segmentation
            else
                path_source_GT = [GT_path '/GT_' folder];
                [~, ~,cl_limGT, nFrames]=analizarExcel_Narrative(path_source_GT, files);
                
                event = zeros(1, nFrames);
                for i = 2:length(cl_limGT)
                    event(cl_limGT(i-1):cl_limGT(i)) = i-1;
                end
                event(cl_limGT(i):nFrames) = i;
            end
                
            num_clusters = max(event);

            result_data = {};
            for i = 1:num_clusters
                result_data{i} = [];
            end
            for i = 1:nFrames
                if(event(i) ~= 0)
                    result_data{event(i)} = [result_data{event(i)} i];
                end
            end
            
            % Deletes events with less than min_imgs_event images
            res_dat = {};
            count = 1;
            for i = 1:length(result_data)
                if(length(result_data{i}) >= min_imgs_event)
                    res_dat{count} = result_data{i};
                    count = count+1;
                end
            end
            num_clus = length(res_dat);

            file_list = dir([path_source '/*' format]);
            clearvars fileList
            count = 1;
            for i = 1:length(file_list)
                if(file_list(i).name(1) ~= '.')
                    fileList(count) = file_list(i);
                    count = count+1;
                end
            end
            img_ex = imread([path_source '/' fileList(1).name]);
            props = round([size(img_ex,1)/prop_div, size(img_ex,2)/prop_div]);
            %% Get summary image
            if(doPlots{1})
                try
                    gen_image = summaryImage(props, num_clus, 30, res_dat, fileList, path_source, 'images', '', []);
                    imwrite(gen_image, [results '/' folder '.jpg']);
                end
            end
            if(doPlots{2})
                %% Get an image per segment
                summaryImageSegment(props, num_clus, 10, res_dat, fileList, path_source, 'images', '', [], [results '/' folder]);
            end
            if(doPlots{3})
                %% Get all the single images per segment
                summaryImageSegmentSingleImages(num_clus, res_dat, fileList, path_source, 'images', '', [results '/' folder]);
            end
        end%End_folder
     end
end

