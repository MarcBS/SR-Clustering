%function extractLSDAFeatures( path_src, file, path_dest, version, doplot, top_plots )

function [ LSDAfeatures, results, classes_names ] = extractLSDAFeatures(folder, format, Semantic_params) 
%EXTRACTLSDAFEATURESS Extract features using the LSDA object detection and
%recognition algorithm by building a semantical scores vector for each
%image.


    %% runLSDA.m
    results = runLSDA(folder, format, Semantic_params);
    
    [~, set_name, ~] = fileparts(folder);
    doplot = false;

    version = 2;

    %% Load
%     load([path_src '/' file]); % results
%     set_name = regexp(file, '_', 'split');
%     set_name = set_name{2};
%     set_name = regexp(set_name, '\.', 'split');
%     set_name = set_name{1};

    classes_original_IDs = [];
    classes_names = {};
    imgs_IDs = [];
    scores = [];
    scores_all = [];
    nImgs = length(results);

    %% Get all classes
    for i = 1:nImgs
        nDetect = size(results{i},1);
        for j = 1:nDetect
            classes_original_IDs = [classes_original_IDs results{i}{j,7}];
            imgs_IDs = [imgs_IDs i];
            scores = [scores results{i}{j,5}];
            if(version==2 || version==3)
                scores_all = [scores_all results{i}{j,8}'];
            end
            classes_names = {classes_names{:}, results{i}{j,6}{1}};
        end
    end

    %% Get unique values
    [classes_original_IDs, indToUnique, indToRepeat] = unique(classes_original_IDs);
    classes_names = {classes_names{indToUnique}};
    nClasses = length(classes_original_IDs);

    %% Get found labels for each image
    % Old version
    if(version==1)
        found_classes = zeros(nClasses, nImgs);
    elseif(version==2 || version == 3)
        found_classes = zeros(size(scores_all,1), nImgs);
    end
    nDetect = length(indToRepeat);
    for i = 1:nDetect
        if(version == 1)
            found_classes(indToRepeat(i), imgs_IDs(i)) = max(found_classes(indToRepeat(i), imgs_IDs(i)), scores(i));
        elseif(version==2)
            found_classes(:, imgs_IDs(i)) = max(found_classes(:, imgs_IDs(i)), scores_all(:,i));
        elseif(version == 3)
            this_scores = scores_all(:,i);
            this_scores(this_scores < 0) = 0;
            found_classes(:, imgs_IDs(i)) = found_classes(:, imgs_IDs(i)) + this_scores;
        end
    end
    if(version==2 || version==3)
        found_classes = found_classes(classes_original_IDs,:);
    end

    %% Normalize
    found_classes = normalize(found_classes')';

    %% Sum values and only take into account bigger values than 0!
    % vals = found_classes;
    % vals(vals<0) = 0;
    % classes_counts = sum(vals,2);
    classes_counts = sum(found_classes,2);
    [~, sort_counts] = sort(classes_counts, 'descend');

    if(doplot)
        %% Plot top classes
        for i = 1:length(top_plots)
            f = figure;
            if(strcmp(top_plots{i}, 'all'))
                this_classes = found_classes(sort_counts(1:end), :);
                imagesc(this_classes);
                set(gca, 'YTick', 1:nClasses)
                set(gca, 'YTickLabel', {classes_names{sort_counts(1:end)}})
                ti = 'All classes';
                colorbar;
            else
                this_classes = found_classes(sort_counts(1:top_plots{i}), :);
                imagesc(this_classes);
                set(gca, 'YTick', 1:top_plots{i})
                set(gca, 'YTickLabel', {classes_names{sort_counts(1:top_plots{i})}})
                ti = ['Top ' num2str(top_plots{i}) ' classes'];
                colorbar;
            end
            title(ti);
            saveas(f, [set_name '_' ti '_v' num2str(version) '.jpg']);
            close(gcf);
        end
    end

    LSDAfeatures = found_classes(sort_counts, :);
%     save([path_dest '/LSDAfeatures_' set_name '_v' num2str(version) '.mat'], 'LSDAfeatures');
    % Save also classes names (for further analysis)
    classes_names = {classes_names{sort_counts}};
%     save([path_dest '/LSDAfeatures_' set_name '_classes_names.mat'], 'classes_names');

end
