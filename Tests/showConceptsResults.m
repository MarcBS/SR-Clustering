
%% This script shows the concept discovery result on a particular set
% by storing each object candidate on the concept folder where it belongs.

%% Parameters
path_conceptdiscovery_results = '/media/lifelogging/HDD_2TB/Video_Summarization_Tests/CNNconcepts';
datasets = {'Exec_ConceptDiscovery_v2_1', 'Exec_ConceptDiscovery_v2_2', 'Exec_ConceptDiscovery_v2_3', 'Exec_ConceptDiscovery_v2_4', ...
	'Exec_ConceptDiscovery_v2_5', 'Exec_ConceptDiscovery_v2_6', 'Exec_ConceptDiscovery_v2_7', 'Exec_ConceptDiscovery_v2_8', ...
	'Exec_ConceptDiscovery_v2_9', 'Exec_ConceptDiscovery_v2_10'};

volume_path = '/media/lifelogging';
path_folders = [volume_path '/HDD_2TB/LIFELOG_DATASETS'];
prop_res = 1.25;

%% Go through each folder
nFold = length(datasets);
for i = 1:nFold
    disp(['Starting concepts show folder ' num2str(i) '/' num2str(nFold)]);
    feat_dir = [path_conceptdiscovery_results '/' datasets{i} '/Concept_Split'];
    mkdir(feat_dir);
    
    %% Load concept discovery results data
    load([path_conceptdiscovery_results '/' datasets{i} '/classes_results.mat']); % classes
    classes_results = classes; clear classes;
    load([path_conceptdiscovery_results '/' datasets{i} '/objects_results.mat']); % objects
    load([path_conceptdiscovery_results '/' datasets{i} '/ind_test.mat']); % ind_test
    
    %% Get classes info (removing not analyzed and no object)
    classes_names = {classes_results(3:end).name};
    classes_labels = [classes_results(3:end).label];
    nClasses = length(classes_labels);
    
    %% For each test image
    images_ids = unique(ind_test(:,1));
    nSamples = length(images_ids);
    prev_img = '';
    for j = 1:nSamples
        img_id = images_ids(j);
        
        this_img = [objects(img_id).folder '/' objects(img_id).imgName];
        if(~strcmp(this_img, prev_img))
            img = imread([path_folders '/' this_img]);
            img = imresize(img, ceil([size(img,1) size(img,2)]/prop_res));
        end
        
        %% Get labels for each concept
        concepts_ids = ind_test(ind_test(:,1)==img_id,2);
        nConcepts = length(concepts_ids);
        for k = 1:nConcepts
            conc_id = concepts_ids(k);
            lab = objects(img_id).objects(conc_id).label;
            
            lab_pos = find(classes_labels == lab);
            % If was labeled during concept discovery
            if(~isempty(lab_pos))
                
                % Extract crop
                obj = objects(img_id).objects(conc_id);
                crop = img(obj.ULy:obj.BRy, obj.ULx:obj.BRx,:);
                
                % Create concept folder (if doesn't exist)
                concept_dir = [feat_dir '/' sprintf('Concept_%0.4d', classes_labels(lab_pos))];
                if(~exist(concept_dir))
                    mkdir(concept_dir);
                end
                
                % Save object candidate
                img_name = ['img' num2str(img_id) '_obj' num2str(conc_id) '.jpg'];
                imwrite(crop, [concept_dir '/' img_name]);
            end
        end
        
        %% Show progress
        if(mod(j,50) == 0 || j == nSamples)
            disp(['    Stored object candidates from ' num2str(j) '/' num2str(nSamples) ' images.']);
        end
        prev_img = this_img;
    end
end

disp('Done');
exit;
