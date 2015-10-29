function [ features ] = extractSemanticFeaturesDemo( folder, format, Semantic_params )
%EXTRACTSEMANTICFEATURESDEMO Extracts semantic features for the files
%passed by parameter.

    %% Variables and folders initialization
    this_path = pwd;
    [prev_folder, ~, ~] = fileparts(this_path);
    path_concept_detector = [prev_folder '/Concept_Detector'];
    tmp_dir = [path_concept_detector '/tmp'];
    tags_dir = [tmp_dir '/tags'];
    list_clusters_dir = [tmp_dir '/list_clusters'];
    [folder_path, folder_name, ~] = fileparts(folder);

    % Create temporal directory for storing data
    if(exist(tmp_dir, 'dir'))
        rmdir(tmp_dir, 's');
    end
    mkdir(tmp_dir);
    mkdir(tags_dir);
    mkdir(list_clusters_dir);
    
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
    cd(path_concept_detector);
    system(['nohup python -u ' tmp_script ' >' tmp_dir '/' log_file ' 2>&1']);
    cd(this_path);
    disp('Done requesting tags with errors.');
    
    
    %% Calculate word similarity and BoW running Word_Similarity.py
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
    
    disp('Calculating word similarity and forming BoW...');
    cd(path_concept_detector);
    system(['nohup python -u ' tmp_script ' >' tmp_dir '/' log_file ' 2>&1']);
    cd(this_path);
    disp('Done calculating BoW.');
    
    
    %% Create tag_matrix applying Density Estimation and filtering after 
    % joining the confidences from all elements in each BoW
    disp('Applying Density Estimation...');
    features = analyzeIMAGGAoutput(tags_dir, folder, list_clusters_dir, Semantic_params);
    disp('Done preparing semantic features.');
    
end

