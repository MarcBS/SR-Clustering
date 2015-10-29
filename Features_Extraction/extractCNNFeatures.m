function extractCNNFeatures( data_path, folders, cameras, formats, CNN_params )
%EXTRACTCNNFEATURESS Extract global CNN features for the given folders

    if(nargin < 5)
        %%% CNN parameters
        CNN_params.caffe_path = '/usr/local/caffe-dev/matlab/caffe';
        CNN_params.use_gpu = 1;
        CNN_params.batch_size = 10; % Depending on the deploy net structure!!
        CNN_params.model_def_file = '../../models/bvlc_reference_caffenet/deploy_signed_features.prototxt';
        CNN_params.model_file = '../../models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel';
        CNN_params.size_features = 4096;
    end

    %% Prepare paths and initialize caffe
    batch_size = CNN_params.batch_size;

    this_path = pwd;
    addpath(CNN_params.caffe_path);
    cd(CNN_params.caffe_path)
    matcaffe_init(CNN_params.use_gpu, CNN_params.model_def_file, CNN_params.model_file); % initialize using or not GPU and model/network files
    nFold = length(folders);
    count_fold = 1;
    tic;
    for f = folders
        camera = cameras{count_fold}; 
        format = formats{count_fold}; 
        images = dir([data_path '/' camera '/imageSets/' f{1} '/*' format]);
        features = zeros(length(images), CNN_params.size_features);
        %% For each image in this folder
        count_im = 1;
        names = {images(:).name};
        nImages = length(names);

        if(nImages == 0)
            error(['Images with format ' format ' not found in folder ' f{1} '.']);
        end

        for i = 0:batch_size:nImages
            this_batch = i+1:min(i+batch_size,  nImages);
            im_list = cell(1,batch_size);
            [im_list{:}] = deal(0);
            count = 1;
            for j = this_batch
                im_list{count} = [data_path '/' camera '/imageSets/' f{1} '/' names{j}];
                count = count+1;
            end
            images = {prepare_batch(im_list)};
            scores = caffe('forward', images);
            scores = squeeze(scores{1});
            features(this_batch, :) = scores(:,1:length(this_batch))';
        end

        disp(['Completed folder ' num2str(count_fold) ' with ' num2str(nImages) ' images.']);
        this_feat_path = [data_path '/' camera '/CNNfeatures'];
        if(~exist(this_feat_path))
            mkdir(this_feat_path);
        end
        save([this_feat_path '/CNNfeatures_' f{1} '.mat'], 'features');

        clear features;
        count_fold = count_fold+1;
    end
    toc
    cd(this_path)


end

