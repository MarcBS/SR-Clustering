function [ LH_Clus ] = joinLHs( LHs, clusterId, W )
%JOINLHS Joins the likelihoods of two different methods w.r.t a weighting
%term.

%     if(W == 0)
%         LH_Clus = LHs{1};
%     elseif(W == 1)
%         LH_Clus = LHs{2};
%     else

        nSamples = size(LHs{1},1);

        %% Define event indices for the two clustering methods
        clus = zeros(2,nSamples); % cluster indices for each clustering method
        clus(1,:) = clusterId{1};
        clus(2,:) = clusterId{2};

        %% Define event indices for the combined methods
        new_clus_id = unique(clus','rows', 'stable')';
        nClusters = size(new_clus_id,2);
        LH_Clus = zeros(nSamples, nClusters);
        clus_comb = 1:nClusters; % cluster index for the combined LHs

        %% Calculate combined Likelihoods
        for i = 1:nSamples
            for j = 1:nClusters
                LH_Clus(i,clus_comb(j)) = (LHs{1}(i,new_clus_id(1,j))) * (1-W) + (LHs{2}(i,new_clus_id(2,j))) * W;
            end
        end

        LH_Clus = bsxfun(@rdivide, LH_Clus, sum(LH_Clus,2));
%     end

end