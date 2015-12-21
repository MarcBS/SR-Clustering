
function [ tag_matrix, tags_results, complete_scores, complete_tags ] = analyzeIMAGGAoutput(tags_path, folder, bag_of_tags_path, Semantic_params)

    %% Parameters
    [folder_path, folder_name, ~] = fileparts(folder);
    
    % Filters all tags with a mean value over or under times_std
    filter_tags_high_mean = Semantic_params.filter_tags_high_mean;
    times_std_over = Semantic_params.times_std_over;
    times_std_under = Semantic_params.times_std_under;

    % Smoothing
    use_smoothing = Semantic_params.use_smoothing;
    smoothing_param = Semantic_params.smoothing_param;
    

    %% Analyse the folder
    disp(['Reading clusters from folder ' folder_name '.']);

    BoW = fileread([bag_of_tags_path '/list_' folder_name '.txt']);
    BoW = regexp(BoW, '\n', 'split');
    nWords = length(BoW)-1;
    disp([num2str(nWords) ' clusters in graph.']);
    words = {};
    lists = {};
    for w = 1:nWords
    bow = regexp(BoW{w}, ' ', 'split');
    words{w} = bow{1};
    bow{2} = strjoin({bow{2:end}}, ' ');
    eval(['lists{w} = {' bow{2}(2:end-1) '};']);
    end

    disp(['Starting analysis of folder ' folder_name '.']);


    %% Load each json file
    imgs_list = dir([tags_path '/' folder_name '/*.json']);
    imgs_list = imgs_list(arrayfun(@(x) x.name(1) ~= '.', imgs_list));
    nJSON = length(imgs_list);
    % Matrix for storing all the scores
    scores = zeros(nJSON,100);
    % Cell for storing all the tags (after the clustering)
    all_tags = {};
    % Cell for storing the complete list of tags available
    complete_tags = {};
    complete_scores = zeros(nJSON, 2000);

    nFound = 0;
    nFound_complete = 0;

    for i = 1:nJSON
        json = fileread([tags_path '/' folder_name '/' imgs_list(i).name]);

        % Read all confidences
        these_confidences = [];
        confidences = regexp(json, '"confidence": ', 'split');
        nConfidences = length(confidences);
        for j = 2:nConfidences
            this_conf = regexp(confidences{j}, ',', 'split');
            these_confidences = [these_confidences str2num(this_conf{1})];
        end

        % Read all tags
        tags = regexp(json, '"tag": "', 'split');
        nTags = length(tags);
        for j = 2:nTags
            this_tag = regexp(tags{j}, '"', 'split');
            this_tag = this_tag{1};

            pos_bow = 0;
            w = 1;
            while(pos_bow == 0 && w <= nWords)
            	pos_bow = sum(ismember(lists{w}, this_tag));
            	w = w+1;
            end
            w = w-1;

	    keep_this_tag = this_tag;
            if(w <= nWords)
            	this_tag = words{w};

            	pos = find(ismember(all_tags, this_tag));
            	if(isempty(pos))
%                    pos = size(scores,2)+1;
		    nFound = nFound+1;
		    pos = nFound;
                    all_tags{pos} = this_tag;
            	end
            	scores(i,pos) = these_confidences(j-1);
            end

	    % Insert into complete list of tags and scores
	    pos = find(ismember(complete_tags, keep_this_tag));
	    if(isempty(pos))
		nFound_complete = nFound_complete+1;
		pos = nFound_complete;
		complete_tags{pos} = keep_this_tag;
	    end
	    complete_scores(i,pos) = these_confidences(j-1);
        end
    end
    scores = scores(:,1:length(all_tags));
    found_classes = scores';

    complete_scores = complete_scores(:,1:length(complete_tags))';

    %% Normalize
    found_classes = normalize(found_classes')';


    %% Filter classes appearing in most of the frames
    if(filter_tags_high_mean)
        mean_scores = mean(found_classes,2);
        std_dev = std(mean_scores);
        filter = mean_scores<(mean(mean_scores)+std_dev*times_std_over);
        filter2 = mean_scores>(mean(mean_scores)-std_dev*times_std_under);
        found_classes = found_classes(filter&filter2,:);
        all_tags = {all_tags{filter&filter2}};
    end

    %% Sum values and only take into account bigger values than 0!
    classes_counts = sum(found_classes,2);
    [~, sort_counts] = sort(classes_counts, 'descend');

    %% Smooth top classes
    this_classes = found_classes(sort_counts(1:end), :);
    tags_results = {all_tags{sort_counts}};
    if(use_smoothing)
        height = size(this_classes, 1);
        for j = 1:height
            this_classes(j,:) = max(fastsmooth(this_classes(j,:), smoothing_param), 0);
        end
    end
    tag_matrix = this_classes;
    
end


