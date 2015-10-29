
function segmentation = RClustering(folder, format, data_params, R_Clustering_params, CNN_params, Semantic_params, plot_params, GT_path)
%%RClustering Segments a day lifelog using visual features.
%
%   Applies the R-Clustering segmentation algorithm on the data in
%   'folder' and retuns the result. Only if the argument GT_path is used, 
%   the segmentation result is evaluated.
%
%   Returns a cell with N positions (N = #segments), where each 
%   cell position contains the list of image names in that segment.
%
%%%%

    %% If the optional parameter 'GT_path' is used, the segmentation will be evaluated
    if(nargin < 8)
        eval_GT = false;
        disp('Not performing final evaluation.');
    elseif(~exist(GT_path, 'file'))
        eval_GT = false;
        disp('Not performing final evaluation: non existent GT_file');
    else
        eval_GT = true;
    end
    
    %% Build params in case the results are not generated
    params.RC_results_path = data_params.RC_results_path;
    params.features_path = data_params.features_path;

    %%% Clustering parameters
    params.methods_indx = {R_Clustering_params.methods_indx};
    params.cut_indx_use = [R_Clustering_params.cut_indx_use];

    %%% R-Clustering parameters
    params.files_path = folder;
    params.formats = format;
    params.clus_type = R_Clustering_params.clus_type;

    params.W_unary = R_Clustering_params.W_unary;
    params.W_pairwise = R_Clustering_params.W_pairwise;
    
    %%% Plot params
    doPlots = plot_params.doPlots;


    %% Start data processing

    [~, folder_name, ~] = fileparts(folder);
    files = dir([folder '/*' format]);
    files = files(arrayfun(@(x) x.name(1) ~= '.', files));

    %% Check if global features are computed
    path_features = [data_params.features_path '/CNNfeatures/CNNfeatures_' folder_name '.mat'];
    if(~exist(path_features, 'file'))
        % Compute CNN features
        disp(['Extracting CNN global features of folder ' folder_name]);
        features = extractCNNFeaturesDemo(folder, files, CNN_params);
        this_feat_path = [data_params.features_path '/CNNfeatures'];
        save([this_feat_path '/CNNfeatures_' folder_name '.mat'], 'features');
        clear features;
    end
    
    %% Check if semantic features are computed
    if(R_Clustering_params.features_used == 2)
        params.use_semantic = true;
        path_semantic = [data_params.features_path '/SemanticFeatures/SemanticFeatures_' folder_name '.mat'];
        if(~exist(path_semantic, 'file'))
            % Compute Semantic features
            disp(['Extracting Semantic features of folder ' folder_name]);
            tag_matrix = extractSemanticFeaturesDemo(folder, format, Semantic_params);
            this_feat_path = [data_params.features_path '/SemanticFeatures'];
            save([this_feat_path '/SemanticFeatures_' folder_name '.mat'], 'tag_matrix');
            clear tag_matrix;
        end
    else
        params.use_semantic = false;
    end


    %% APPLY R-CLUSTERING

    %%% Prepare GT if evaluating
    if(eval_GT)
        params.doEvaluation = true;

        [~,~,cl_limGT, ~]=analizarExcel_Narrative(GT_path, files);
        delim=cl_limGT';
        if delim(1) == 1, delim=delim(2:end); end
        params.GT = delim;

    else
        params.doEvaluation = false;
    end

    %%% Get cluster indices applying R-Clustering
    path_here = pwd;
    cd ..
    events = process_single_sequence_v2(folder, params);
    cd(path_here)

    num_clusters = max(events);
    nFrames = length(files);

    result_data = cell(1, num_clusters);
    for i = 1:nFrames
        if(events(i) ~= 0)
            result_data{events(i)} = [result_data{events(i)} i];
        end
    end

    %% Deletes events with less than min_imgs_event images (only for plot purposes)
    if(doPlots{1} || doPlots{2} || doPlots{3})
        res_dat = {};
        count = 1;
        for i = 1:length(result_data)
            if(length(result_data{i}) >= plot_params.min_imgs_event)
                res_dat{count} = result_data{i};
                count = count+1;
            end
        end
        num_clus = length(res_dat);

        img_ex = imread([folder '/' files(1).name]);
        props = round([size(img_ex,1)/plot_params.prop_div, size(img_ex,2)/plot_params.prop_div]);
    end

    %% Plot summary images
    if(doPlots{1})
        %% Plot a single image with all the segments
        disp('Starting plot whole summary image...');
        if(~exist(data_params.RC_plot_results_path, 'dir'))
            mkdir(data_params.RC_plot_results_path);
        end
        try
            gen_image = summaryImage(props, num_clus, 30, res_dat, files, folder, 'images', '', []);
            imwrite(gen_image, [data_params.RC_plot_results_path '/' folder_name '.jpg']);
        end
    end
    if(doPlots{2})
        %% Plot an image per segment
        disp('Starting plot image per segment...');
        summaryImageSegment(props, num_clus, 10, res_dat, files, folder, 'images', '', [], [data_params.RC_plot_results_path '/' folder_name]);
    end
    if(doPlots{3})
        %% Plot all the single images in folders per segment
        disp('Starting plot segments in folders...');
        summaryImageSegmentSingleImages(num_clus, res_dat, files, folder, 'images', '', [data_params.RC_plot_results_path '/' folder_name]);
    end
    
    
    %% Prepare output R-Clustering result
    segmentation = cell(1, num_clusters);
    
    % Store result it in a .csv file
    segmentation_file = [data_params.RC_results_path '/result_' folder_name '.csv'];
    f = fopen(segmentation_file, 'w');

    for s = 1:num_clusters
        nImgs = length(result_data{s});
        line = ['Segment_' num2str(s)];
        for i = 1:nImgs
            img_name = files(result_data{s}(i)).name;
            segmentation{s} = {segmentation{s}, img_name};
            line = [line ',' img_name];
        end
        fprintf(f, [line '\n']);
    end
    
    fclose(f);
    disp(['A .csv file with the result has been stored in ' data_params.RC_results_path]);
end
