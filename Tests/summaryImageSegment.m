
% Creates a summary image for each of the events extracted.
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
% results_path: folder where all the segment images will be stored.
function summaryImageSegment( props, num_clusters, n_summaryImages, result_data, fileList, source, source_type, ini, labels_text, results_path)

    if(~exist(results_path))
        mkdir(results_path);
    end
    border = 8;
    letters = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'};

    for n_clus = 1:num_clusters
        
        this_clus = result_data{n_clus};
        nRows = ceil(length(this_clus) / n_summaryImages);
        
        if(isempty(labels_text))
            gen_image = uint8(ones((props(1)+border)*(nRows+1), props(2)*(n_summaryImages+1), 3));
        else
            gen_image = uint8(ones((props(1)+border)*(nRows+1), props(2)*(n_summaryImages+2), 3));
        end

        for i = 0:nRows
            
            if(i > 0)
                max_idx = min(i*n_summaryImages, length(this_clus));
                this_c = this_clus((i-1)*n_summaryImages+1 : max_idx);
                n_elems = length(this_c);
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
            else
                last = n_summaryImages;
            end

            for j = 0:last
                % Insert row/column index
                if(j==0 || i==0)
                    x1 = ((i)*(props(1)+border));
                    x2 = ((i+1)*props(1)+i*border);
                    y1 = ((j)*props(2));
                    y2 = ((j+1)*props(2));
                    if(j==0)
                        htxtins = vision.TextInserter(num2str(i));
                    elseif(i==0)
                        htxtins = vision.TextInserter(letters{j});
                    end
                    if(~(j==0 && i==0))
                        htxtins.Color = [255, 255, 255]; % [red, green, blue]
                        htxtins.FontSize = 35;
                        htxtins.Location = [((y2-y1)/3)+y1 ((x2-x1)/3)+x1]; % [x y]
                        gen_image = step(htxtins, gen_image);
                        htxtins.release();
                    end
                elseif(j > num_sum)
                    % Insert label at the end of the event
                    x1 = ((i-1)*props(1));
                    x2 = (i*props(1));
                    y1 = ((j-1)*props(2)-props(2)/4);
                    y2 = (j*props(2));
                    htxtins = vision.TextInserter([labels_text(i) ' ' num2str(length(this_clus))]);
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
                    x1 = (i*(props(1)+border)+1);
                    x2 = ((i+1)*props(1)+i*border);
                    y1 = (j*props(2)+1);
                    y2 = ((j+1)*props(2));
                    gen_image( x1:x2, y1:y2, 1 ) = im(:,:,1);
                    gen_image( x1:x2, y1:y2, 2 ) = im(:,:,2);
                    gen_image( x1:x2, y1:y2, 3 ) = im(:,:,3);
                end
            end
        end
        
        % Write image for the current segment
        imwrite(gen_image, [results_path '/Segm_' num2str(n_clus) '.jpg']);
    end
        
end

