function [ LH ] = getLHFromClustering( features, clusters )

    nSamples = size(features,1);
    unique_clusters = unique(clusters);
    nClusters = length(unique_clusters);

    dists = zeros(nSamples, nClusters);
    for i = 1:nClusters
        idx = find(clusters==unique_clusters(i));
        if(length(idx) > 1)
            mean_clus = mean(features(idx,:));
        else
            mean_clus = features(idx,:);
        end
        dists(:,i) = pdist2(features, mean_clus);
        %dists(:,i) = mean(pdist2(features, features(idx,:)), 2);
    end
    for i = 1:nSamples
        dists(i,clusters(i)) = min(dists(i,:))/2;
    end
    LH = getLHFromDists(dists);

end

