function [ LH ] = getLHFromClustering( features_norm, clustersId )

    nSamples = size(features_norm,1);
    unique_clustersId = unique(clustersId);
    nclustersId = length(unique_clustersId);

    dists = zeros(nSamples, nclustersId);
    for i = 1:nclustersId
        idx = find(clustersId==unique_clustersId(i));
        if(length(idx) > 1)
            mean_clus = mean(features_norm(idx,:));
        else
            mean_clus = features_norm(idx,:);
        end
        dists(:,i) = pdist2(features_norm, mean_clus);
        %dists(:,i) = mean(pdist2(features_norm, features_norm(idx,:)), 2);
    end
    for i = 1:nSamples
        dists(i,clustersId(i)) = min(dists(i,:))/2;
    end
    LH = getLHFromDists(dists);

end

