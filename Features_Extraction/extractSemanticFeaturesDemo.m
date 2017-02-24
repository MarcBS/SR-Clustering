function [ features, tags_names, scores_complete, tags_complete ] = extractSemanticFeaturesDemo( folder, format, Semantic_params, scores_complete, tags_complete, R_Clustering_params )
    %EXTRACTSEMANTICFEATURESDEMO Extracts semantic features for the files
    %passed by parameter.

    if nargin > 3
        precomputed_tags = true;
    else
        precomputed_tags = false;
    end

    %% Variables and folders initialization
    this_path = pwd;
    [prev_folder, ~, ~] = fileparts(this_path);
    path_concept_detector = [prev_folder '/Concept_Detector'];
    tmp_dir = [path_concept_detector '/tmp'];
    tags_dir = [tmp_dir '/tags'];
    list_clusters_dir = [tmp_dir '/list_clusters'];
    [folder_path, folder_name, ~] = fileparts(folder);

    % Create temporary directory for storing data
    if (~exist([tags_dir '/' folder_name], 'dir'))
        %if exist(tmp_dir)
        %    rmdir(tmp_dir, 's');
        %end

        mkdir(tmp_dir);
        mkdir(tags_dir);
        mkdir(list_clusters_dir);
    end

    % If we are not providing a matrix of precomputed taggs we have to request them to Imagga
    if (~precomputed_tags)

        if (R_Clustering_params.features_used == 2)

            % File for handling the tagging connection errors
            errors_file = [tmp_dir '/errors_file.txt'];

            %% Prepare and run runRequestTagging.py
            tmp_script = 'runRequestTagging_tmp.py';
            log_file = 'runRequestTagging_log.txt';
            text = fileread([path_concept_detector '/runRequestTagging.py']);

            text = regexp(text, '%folder_path%', 'split');
            text = strjoin(text, folder_path);
            text = regexp(text, '%folder_name%', 'split');
            text = strjoin(text, folder_name);
            text = regexp(text, '%format%', 'split');
            text = strjoin(text, format);
            text = regexp(text, '%endpoint%', 'split');
            text = strjoin(text, Semantic_params.endpoint);
            text = regexp(text, '%api_key%', 'split');
            text = strjoin(text, Semantic_params.api_key);
            text = regexp(text, '%api_secret%', 'split');
            text = strjoin(text, Semantic_params.api_secret);
            text = regexp(text, '%result_path%', 'split');
            text = strjoin(text, tags_dir);
            text = regexp(text, '%', 'split');
            text = strjoin(text, '%%');

            f = fopen([path_concept_detector '/' tmp_script], 'w');
            fprintf(f, text);
            fclose(f);

            disp('Requesting image tags to IMAGGA (this operation may take some minutes)...');
            disp(['    Check ' tmp_dir '/' log_file ' for details.']);
            cd(path_concept_detector);
            system(['nohup python -u ' tmp_script ' >' tmp_dir '/' log_file ' 2>&1']);
            cd(this_path);
            disp('Done requesting tags.');

            %% Check errors file
            disp('Checking for possible connection errors during tagging.');
            checkErrors(tags_dir, {folder}, errors_file);

            %% Correct errors running runRequestTaggingErrors.py
            tmp_script = 'runRequestTaggingErrors_tmp.py';
            log_file = 'runRequestTaggingErrors_log.txt';
            text = fileread([path_concept_detector '/runRequestTaggingErrors.py']);

            text = regexp(text, '%folder_path%', 'split');
            text = strjoin(text, folder_path);
            text = regexp(text, '%errors_file%', 'split');
            text = strjoin(text, errors_file);
            text = regexp(text, '%endpoint%', 'split');
            text = strjoin(text, Semantic_params.endpoint);
            text = regexp(text, '%api_key%', 'split');
            text = strjoin(text, Semantic_params.api_key);
            text = regexp(text, '%api_secret%', 'split');
            text = strjoin(text, Semantic_params.api_secret);
            text = regexp(text, '%result_path%', 'split');
            text = strjoin(text, tags_dir);
            text = regexp(text, '%', 'split');
            text = strjoin(text, '%%');

            f = fopen([path_concept_detector '/' tmp_script], 'w');
            fprintf(f, text);
            fclose(f);

            disp('Requesting again failed connections to IMAGGA...');
            disp(['    Check ' tmp_dir '/' log_file ' for details.']);
            cd(path_concept_detector);
            system(['nohup python -u ' tmp_script ' >' tmp_dir '/' log_file ' 2>&1']);
            cd(this_path);
            disp('Done requesting tags with errors.');

        elseif (R_Clustering_params.features_used == 4)

            % File for handling the tagging connection errors
            errors_file = [tmp_dir '/errors_file.txt'];

            %% Prepare and run runRequestTagging.py
            tmp_script = 'runRequestTaggingYOLO_tmp.py';
            log_file = 'runRequestTaggingYOLO_log.txt';
            text = fileread([path_concept_detector '/runRequestTaggingYOLO.py']);

            text = regexp(text, '%folder_path%', 'split');
            text = strjoin(text, folder_path);
            text = regexp(text, '%folder_name%', 'split');
            text = strjoin(text, folder_name);
            text = regexp(text, '%format%', 'split');
            text = strjoin(text, format);
            text = regexp(text, '%result_path%', 'split');
            text = strjoin(text, tags_dir);
            text = regexp(text, '%', 'split');
            text = strjoin(text, '%%');

            f = fopen([path_concept_detector '/' tmp_script], 'w');
            fprintf(f, text);
            fclose(f);

            disp('Requesting image tags to YOLO (this operation may take some minutes)...');
            disp(['    Check ' tmp_dir '/' log_file ' for details.']);
            cd(path_concept_detector);
            system(['nohup python -u ' tmp_script ' >' tmp_dir '/' log_file ' 2>&1']);
            cd(this_path);
            disp('Done requesting tags.');

        end

        % If we provide a matrix of pre-computed tags then we have to insert them into the corresponding taggs folder
    else

        % Read list of images
        images = dir([folder_path '/' folder_name '/*' format]);
        images = images(arrayfun(@(x) x.name(1) ~= '.', images));
        n_images = length(images);

        if n_images ~= size(scores_complete,2)
            n_images
            size(scores_complete)
            error('Dimension mismatch on tags provided and number of images in folder.');
        end

        % Create folder
        mkdir([tags_dir '/' folder_name])

        % Format .json file for each image
        for i = 1:n_images
            store_text = '{"results": [{"image": "precomputed", "tags": [';

            these_conf = scores_complete(i,:);
            [v,p] = sort(these_conf, 'descend');
            pos_v = 1;
            while v(pos_v) > 0
                tag = tags_complete{:,p(pos_v)};
                conf = v(pos_v);

                store_text = [store_text '{"confidence": ' num2str(conf) ', "tag": "' tag '"}, '];

                pos_v = pos_v +1;
            end
            store_text = [store_text(1:end-2) ']}]}'];

            % Store text in json file
            f = fopen([tags_dir '/' folder_name '/' images(i).name '.json'], 'w');
            fprintf(f, store_text);
            fclose(f);
        end

    end


    %% Calculate word similarity and Graph running Word_Similarity.py
    tmp_script = 'Word_Similarity_tmp.py';
    log_file = 'Word_Similarity_log.txt';
    text = fileread([path_concept_detector '/Word_Similarity.py']);

    text = regexp(text, '%folder_path%', 'split');
    text = strjoin(text, folder_path);
    text = regexp(text, '%folder_name%', 'split');
    text = strjoin(text, folder_name);
    text = regexp(text, '%format%', 'split');
    text = strjoin(text, format);
    text = regexp(text, '%input_path%', 'split');
    text = strjoin(text, tags_dir);
    text = regexp(text, '%output_path%', 'split');
    text = strjoin(text, list_clusters_dir);
    text = regexp(text, '%', 'split');
    text = strjoin(text, '%%');
    text = regexp(text, '\', 'split');
    text = strjoin(text, '\\\');

    f = fopen([path_concept_detector '/' tmp_script], 'w');
    fprintf(f, text);
    fclose(f);

    disp('Calculating word similarity and forming Graph...');
    disp(['    Check ' tmp_dir '/' log_file ' for details.']);
    cd(path_concept_detector);
    system(['nohup python -u ' tmp_script ' >' tmp_dir '/' log_file ' 2>&1']);
    cd(this_path);
    disp('Done calculating Semantic Similarity Graph.');


    %% Create tag_matrix applying Density Estimation and filtering after
    % joining the confidences from all elements in each Cluster
    disp('Applying Density Estimation...');
    [features, tags_names, scores_complete, tags_complete] = analyzeIMAGGAoutput(tags_dir, folder, list_clusters_dir, Semantic_params);
    disp('Done preparing semantic features.');

end
