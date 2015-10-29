function [ features ] = extractColorFeatures( folder, format, colorFeatures_params )

    nBins = colorFeatures_params.nBins;
    binranges = round(linspace(0,255,nBins));

    % Get images list
    img_list = dir([folder '/*' format]);
    img_list = img_list(arrayfun(@(x) x.name(1) ~= '.', img_list));
   
    % Create transformation structure
    colorTransform = makecform('srgb2lab');
    
    %% Get ready to start features extraction
    nImgs = length(img_list);
    features = zeros(nImgs, nBins*3);
    for i = 1:nImgs
        % Load image
        img = imread([folder '/' img_list(i).name]);
        
        % Transform to LAB
        lab = applycform(img, colorTransform);
        
        % Create histogram and extract bins
        for c = 1:3
            hist_c = histc(reshape(lab(:,:,c), 1, size(lab,1)*size(lab,2)), binranges);
            features(i, 1+(c-1)*nBins:c*nBins) = hist_c;
        end
        
        % Show progress
        if(mod(i, 50) == 0 || i == nImgs)
            disp(['Extracted color features from ' num2str(i) '/' num2str(nImgs) ' images.']);
        end
    end

end

