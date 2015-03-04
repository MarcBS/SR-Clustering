function [ all_indices ] = getAllIndices( objects )

    nSamples = 0;
    nImages = length(objects);
    for i = 1:nImages
        nSamples = nSamples + length(objects(i).objects);
    end
    
    all_indices = zeros(nSamples, 2);
    count = 1;
    for i = 1:nImages
        nObjects = length(objects(i).objects);
        for j = 1:nObjects
            all_indices(count,:) = [i j];
            count = count+1;
        end
    end

end

