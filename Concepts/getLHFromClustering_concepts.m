function [ LH ] = getdistsFromClustering_concepts(features_global, features_concepts, clusters )

    nSamples = size(features_global,1);
    unique_clusters = unique(clusters);
    nClusters = length(unique_clusters);

    dists = zeros(nSamples, nClusters);
    for i = 1:nClusters
        idx = find(clusters==unique_clusters(i));
        if(length(idx) > 1)
            mean_clus = mean(features_global(idx,:));
            %compute mean concepts: feature_concepts is three-dimensional 
            mean_concepts =  mean(features_concepts(:,:,idx),3);
        else
            mean_clus = features_global(idx,:);
            mean_concepts =  features_concepts(:,:,idx);
        end

        for k=1:nSamples
            dists(:,i) = compute_concept_distance(features_global(k,:),mean_clus,features_concepts(:,:,k),mean_concepts);
        end
    end
    for i = 1:nSamples
        dists(i,clustersId(i)) = min(dists(i,:))/2;
    end
    LH = getLHFromDists(dists);


end
