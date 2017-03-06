function features = extractCNNFeaturesDemo( folder, images, CNN_params )
%EXTRACTCNNFEATURESS Extract global CNN features for the given folders

    %% Prepare paths and initialize caffe
    batch_size = CNN_params.batch_size;

%     this_path = pwd;
    addpath(CNN_params.caffe_path);
%     cd(CNN_params.caffe_path)
    matcaffe_init(CNN_params.use_gpu, CNN_params.model_def_file, CNN_params.model_file); % initialize using or not GPU and model/network files

    tic;

    features = zeros(length(images), CNN_params.size_features);
    %% For each image in this folder
    names = {images(:).name};
    nImages = length(names);

    for i = 0:batch_size:nImages
        this_batch = i+1:min(i+batch_size,  nImages);
        im_list = cell(1,batch_size);
        [im_list{:}] = deal(0);
        count = 1;
        for j = this_batch
            im_list{count} = [folder '/' names{j}];
            count = count+1;
        end
        images = {prepare_batch2(im_list, false, CNN_params.parallel, CNN_params.mean_file)};
        scores = caffe('forward', images);
        scores = squeeze(scores{1});
        features(this_batch, :) = scores(:,1:length(this_batch))';
    end

    toc
%     cd(this_path)


end

