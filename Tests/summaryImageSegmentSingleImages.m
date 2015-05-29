
% Creates a summary image for each of the events extracted.
%
% num_clusters: number of events extracted from the set
% result_data: cell structure with lists of images' ids for each event
% fileList: list of files where the images are stored or video loaded
% source: path to the directory where the images are ('' if using video)
% source_type: type of the source {images, video}
% ini: initial image for the video extraction (0 if source_type == images)
% results_path: folder where all the segment images will be stored.
function summaryImageSegmentSingleImages( num_clusters, result_data, fileList, source, source_type, ini, results_path)

    if(~exist(results_path))
        mkdir(results_path);
    end

    %% For each segment
    for n_clus = 1:num_clusters
        
        % Get images in the segment
        this_clus = result_data{n_clus};
        
        % Create folder for storing images
        store_path = [results_path '/Segment_' num2str(n_clus)];
        if(~exist(store_path))
            mkdir(store_path);
        end

        %% For each sub-image
        for i_im = this_clus
            if(strcmp(source_type, 'images'))
                copyfile([source '/' fileList(i_im).name], [store_path '/' fileList(i_im).name]);
            elseif(strcmp(source_type, 'video'))
                im = read(fileList, (ini + i_im));
                imwrite(gen_image, [store_path '/' num2str(i_im) '.jpg']);
            end
        end
    end
        
end

