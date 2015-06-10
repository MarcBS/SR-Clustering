%%%%%%% R-Clustering demo file
% This demo applies the R-Clustering segmentation algorithm on a set
% captured by a lifelogging wearable camera.

loadParametersDemo;


%% Build params in case the results are not generated
params.RC_results_path = RC_results_path;

%%% Clustering parameters
params.methods_indx = methods_indx;
params.cut_indx_use = cut_indx_use;

%%% R-Clustering parameters
params.clus_type = clus_type;

params.W_unary = W_unary;
params.W_pairwise = W_pairwise;


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

            %% Check if features are computed
            path_features = [files_path_base '/' cameras{i_fold} '/CNNfeatures/CNNfeatures_' folder '.mat'];
            if(~exist(path_features))
                % Compute CNN features
                disp(['Extraction CNN global features for folder ' folder]);
                extractCNNFeatures(files_path_base, {folder}, {cameras{i_fold}}, {formats{i_fold}}, CNN_params)
            end
            
                
            %% APPLY R-CLUSTERING

            params.files_path = files_path_base;
            params.formats = format;
            
            %%% Prepare GT if evaluating
            if(eval_GT)
                params.doEvaluation = true;
                
                path_excel = [files_path_base '/' cameras{i_fold} '/GT/GT_' folder '.xls'];
                [clust_man,clustersIdGT,cl_limGT, ~]=analizarExcel_Narrative(path_excel, files);
                delim=cl_limGT';
                if delim(1) == 1, delim=delim(2:end); end
                params.GT = delim;
                
            else
                params.doEvaluation = false;
            end
            
            %% Get cluster indices applying R-Clustering
            path_here = pwd;
            cd ..
            events = process_single_sequence(cameras{i_fold}, folder, params);
            cd(path_here)
                
            num_clusters = max(events);

            result_data = {};
            for i = 1:num_clusters
                result_data{i} = [];
            end
            for i = 1:nFrames
                if(events(i) ~= 0)
                    result_data{events(i)} = [result_data{events(i)} i];
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
                disp('Starting plot whole summary image...');
                try
                    gen_image = summaryImage(props, num_clus, 30, res_dat, fileList, path_source, 'images', '', []);
                    imwrite(gen_image, [RC_plot_results_path '/' folder '.jpg']);
                end
            end
            if(doPlots{2})
                %% Get an image per segment
                disp('Starting plot image per segment...');
                summaryImageSegment(props, num_clus, 10, res_dat, fileList, path_source, 'images', '', [], [RC_plot_results_path '/' folder]);
            end
            if(doPlots{3})
                %% Get all the single images in folders per segment
                disp('Starting plot segments in folders...');
                summaryImageSegmentSingleImages(num_clus, res_dat, fileList, path_source, 'images', '', [RC_plot_results_path '/' folder]);
            end
        end%End_folder
     end
end

disp('Done');
