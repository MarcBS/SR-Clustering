
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

nConcepts = 100;
feat_type = 'CNN'; % 'CNN' or 'LSH'

%% Start extraction of samples
folder = sprintf(['Concepts_%0.4d_' feat_type '_split'], nConcepts);


%% Load objects file
disp('Loading objects.mat file...')
load([feat_path '/objects.mat']); % objects

%% Extract objects images
for i = 1:nConcepts
    folder_name = sprintf([folder '/Concept_%0.4d'], i);
    mkdir(folder_name);
    
    load(sprintf([folder '/indices_%0.4d.mat'], i)); % indices
    nIndices = size(indices,1);
    indices = sortrows(indices);
    prev_img = '';
    for j = 1:nIndices
        this_img = [objects(indices(j,1)).folder '/' objects(indices(j,1)).imgName];
        if(~strcmp(this_img, prev_img))
            img = imread([path_folders '/' this_img]);
            img = imresize(img, ceil([size(img,1) size(img,2)]/prop_res));
        end
        
        % Extract crop
        obj = objects(indices(j,1)).objects(indices(j,2));
        crop = img(obj.ULy:obj.BRy, obj.ULx:obj.BRx,:);
        
        % Save crop
        name_crop = sprintf('%0.5d.png', j);
        imwrite(crop, [folder_name '/' name_crop]);
        
        prev_img = this_img;
    end
end

disp('Done');

exit;