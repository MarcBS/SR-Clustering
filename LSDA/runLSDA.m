%%%%%
%
%   results = [x y h w score class class_id]
%
%%

function results = runLSDA(folder, format, Semantic_params)

% %% Parametrs
% path_data = '/media/lifelogging/HDD_2TB/DATASETS/LIFELOG_DATASETS';
% folder_list = {'Maya2', 'Maya3', 'Estefania3'};
% cameras = {'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative'};
% formats = {'.jpg', '.jpg', '.jpg', '.jpg', '.jpg'};

print_imgs = false;
out_path = '../Test_Output_AllClasses';


current_path = pwd;
cd(Semantic_params.path_lsda_repository);
addpath('..');

%% Prepare LSDA model
try
    startup;
catch ME
    if(strcmp(ME.message, 'Expected 3 arguments, got 2'))
	rcnn_feat = rcnn_load_model_new(rcnn_feat);
	fprintf(' Done.\n');
	fprintf('LSDA startup done\n');    	
    else
    	error(ME.message);
    end
end

%% Run LSDA
% nFolders = length(folder_list);
% for i = 1:nFolders
%     this_path = [path_data '/' cameras{i} '/imageSets/' folder_list{i}];
%     img_list = dir([this_path '/*' formats{i}]);


    this_path = folder;
    
    img_list = dir([this_path '/*' format]);
    img_list = img_list(arrayfun(@(x) x.name(1) ~= '.', img_list));


    img_list_aux = []; count = 1;
    nImgs = length(img_list);
    for n_files = 1:nImgs
        if(img_list(n_files).name(1) ~= '.')
            img_list_aux(count).name = img_list(n_files).name;
            count = count+1;
        end
    end
    img_list = img_list_aux;
    
    nImgs = length(img_list);
    results = cell(nImgs,1);
    for j = 1:nImgs
        %[top_boxes, cats_found, cats_ids, all_scores] = detectK(rcnn_model, rcnn_feat, [this_path '/' img_list(j).name], '', false, 200);
        [top_boxes, cats_found, cats_ids, all_scores] = detectK(rcnn_model, rcnn_feat, [this_path '/' img_list(j).name], '', false);
        nDetect = length(cats_found);
        if(nDetect)
            results{j} = cell(nDetect, 7);
            for k = 1:nDetect
                results{j}{k,1} = top_boxes(k,1);
                results{j}{k,2} = top_boxes(k,2);
                results{j}{k,3} = top_boxes(k,3);
                results{j}{k,4} = top_boxes(k,4);
                results{j}{k,5} = top_boxes(k,5);
                results{j}{k,6} = cats_found(k);
                results{j}{k,7} = cats_ids(k);
                results{j}{k,8} = all_scores(k,:);
            end
        end
        % Show result
	if(print_imgs)
            iim = imread([this_path '/' img_list(j).name]);
	    showdets(im, top_boxes, cats_found, cats_ids);
            saveas(gca, [out_path '/' folder_list{i} '_' img_list(j).name]);
            close(gcf);
	end
%         disp(['Folder ' num2str(i) ' img ' num2str(j)]);
	
	%% Show progress
	if(mod(j,10) == 0 || j ==nImgs)
	    disp(['    Applied LSDA to ' num2str(j) '/' num2str(nImgs) ' images.']);
	end
    end
%     save([out_path '/results_' folder_list{i} '.mat'], 'results');
% end

cd(current_path);

end
