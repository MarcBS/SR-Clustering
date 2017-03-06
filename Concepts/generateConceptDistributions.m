
%% This script generates the concept distribution vectors resulting from 
% applying the Concept Discovery on the sets about to segment.
%
% A cell structure with the name "feat_concepts" is created for each test
% image. Where each cell represents a Concept Class, and in each cell we 
% can find the CNN features for all the concepts belonging to that class.
%
%%%%

%% Parameters
path_conceptdiscovery_results = '/media/lifelogging/HDD_2TB/Video Summarization Tests/ExecutionResults';
datasets = {'Exec_ConceptDiscovery_v3_1', 'Exec_ConceptDiscovery_v3_2', 'Exec_ConceptDiscovery_v3_3', 'Exec_ConceptDiscovery_v3_4', ...
	'Exec_ConceptDiscovery_v3_5', 'Exec_ConceptDiscovery_v3_6', 'Exec_ConceptDiscovery_v3_7', 'Exec_ConceptDiscovery_v3_8', ...
	'Exec_ConceptDiscovery_v3_9', 'Exec_ConceptDiscovery_v3_10'};

CNN_feat_path = '/media/lifelogging/HDD_2TB/Video Summarization Objects/Features/Data R-Clustering Ferrari';

%% Go through each folder
nFold = length(datasets);
for i = 1:nFold
    disp(['Starting features extraction dataset ' num2str(i) '/' num2str(nFold)]);
    feat_dir = [path_conceptdiscovery_results '/' datasets{i} '/Concept_Features'];
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
    for j = 1:nSamples
        img_id = images_ids(j);
        
        % Prepare features cell
        feat_concepts = cell(1, nClasses);
        
        %% Get labels for each concept
        concepts_ids = ind_test(ind_test(:,1)==img_id,2);
        nConcepts = length(concepts_ids);
        for k = 1:nConcepts
            conc_id = concepts_ids(k);
            lab = objects(img_id).objects(conc_id).label;
            
	    lab_pos = find(classes_labels == lab);
	    % If was labeled during concept discovery
            if(~isempty(lab_pos))
                % Get current concept's CNN features
                load([CNN_feat_path '/img' num2str(img_id) '/obj' num2str(conc_id) '.mat']);
            
                % Insert the CNN features for the current concept in the 
                % corresponding label cell.
                if(isempty(feat_concepts{lab_pos}))
                    feat_concepts{lab_pos} = obj_feat.CNN_feat;
                else
                    feat_concepts{lab_pos} = [feat_concepts{lab_pos}; obj_feat.CNN_feat];
                end
	    end
        end
        
        %% Show progress
        if(mod(j,50) == 0 || j == nSamples)
            disp(['    Extracted features from ' num2str(j) '/' num2str(nSamples) ' images.']);
        end
        
        %% Save features from the current image
        save(sprintf([feat_dir '/feat_concepts_%0.6d'], img_id), 'feat_concepts');
    end
end

disp('Done');
exit;
