
% Creates a summary image of all the events extracted from the set of
% images.
%
% props: final proportions of the images
% num_clusters: number of events extracted from the set
% n_summaryImages: number of images shown for each event
% result_data: cell structure with lists of images' ids for each event
% fileList: list of files where the images are stored or video loaded
% source: path to the directory where the images are ('' if using video)
% source_type: type of the source {images, video}
% ini: initial image for the video extraction (0 if source_type == images)
% labels_text: labels assigned to each of the events (leave empty [] for
%               not writing it).
function [ gen_image ] = summaryImage( props, num_clusters, n_summaryImages, result_data, fileList, source, source_type, ini, labels_text, semantic, semantic_tags )

    top_sem = 8;
    space_labels_horizontal = 20;
    if(nargin < 10)
	semantic = [];
    end
    if(~isempty(semantic))
	use_semantic = true;
	space_labels = 30;
    else
	use_semantic = false;
	space_labels = 0;
    end

    border = 8;

    if(isempty(labels_text))
        gen_image = uint8(ones((props(1)+border+space_labels)*num_clusters, props(2)*n_summaryImages, 3)*255);
    else
        gen_image = uint8(ones((props(1)+border+space_labels)*num_clusters, props(2)*(n_summaryImages+1), 3)*255);
    end
    
    for i = 1:num_clusters
        this_c = result_data{i};
	n_elems = length(this_c);

	if(use_semantic)
	    sem = semantic(:, this_c);
	    sem = sum(sem,2)/n_elems;
	    [vsem,psem] = sort(sem, 'descend');
	    this_tags = {semantic_tags{psem(1:top_sem)}};
	    this_tags_values = vsem(1:top_sem);
	end

        if(n_elems < n_summaryImages)
            num_sum = n_elems;
            jump = 1;
        else
            num_sum = n_summaryImages;
            jump = floor(n_elems/n_summaryImages);
        end
        
        if(isempty(labels_text))
            last = num_sum;
        else
            last = num_sum+1;
        end
        
        for j = 1:last
            if(j > num_sum)
                % Insert label at the end of the event
                x1 = ((i-1)*props(1));
                x2 = (i*props(1));
                y1 = ((j-1)*props(2)-props(2)/4);
                y2 = (j*props(2));
                htxtins = vision.TextInserter([labels_text(i) ' ' num2str(size(result_data{i},2))]);
                htxtins.Color = [0, 0, 0]; % [red, green, blue]
                htxtins.FontSize = 35;
                htxtins.Location = [((y2-y1)/3)+y1 ((x2-x1)/3)+x1]; % [x y]
                gen_image = step(htxtins, gen_image);
                  
            else
                if(strcmp(source_type, 'images'))
                    im = imread([source '/' fileList(this_c(j*jump)).name]);
                elseif(strcmp(source_type, 'video'))
                    im = read(fileList, (ini + this_c(j*jump)));
                end
                im = imresize(im, props);
                x1 = ((i-1)*(props(1)+border+space_labels)+1);
                x2 = (i*props(1)+(i-1)*border+(i-1)*space_labels);
                y1 = ((j-1)*props(2)+1);
                y2 = (j*props(2));
                gen_image( x1:x2, y1:y2, 1 ) = im(:,:,1);
                gen_image( x1:x2, y1:y2, 2 ) = im(:,:,2);
                gen_image( x1:x2, y1:y2, 3 ) = im(:,:,3);
            end
        end

	% Show tags
	if(use_semantic)
	    t = strjoin(this_tags, ', ');
            x2 = (i*props(1)+(i-1)*border+(i-1)*space_labels);
            y1 = 1;
            htxtins = vision.TextInserter(t);
            htxtins.Color = [0, 0, 0]; % [red, green, blue]
            htxtins.FontSize = 20;
            htxtins.Location = [y1+border x2+border]; % [x y]
	    gen_image = step(htxtins, gen_image);
%	    for j = 1:top_sem
%		x1 = ((i-1)*(props(1)+border+space_labels)+1);
%                x2 = (i*props(1)+(i-1)*border+(i-1)*space_labels);
%                y1 = ((j-1)*props(2)+1)+(j-1)*space_labels_horizontal;
%                y2 = (j*props(2))+(j-1)*space_labels_horizontal;
%		htxtins = vision.TextInserter([' ' this_tags{j}]);
%		htxtins.Color = [0, 0, 0]; % [red, green, blue]
%                htxtins.FontSize = 20;
%		htxtins.Location = [y1+border x2+border]; % [x y]
%                gen_image = step(htxtins, gen_image);
%	    end
	end
    end

end

