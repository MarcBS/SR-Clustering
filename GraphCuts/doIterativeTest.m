function [ fig ,vec_numC,vec_perC,clusterIds, W_pairwise, W_unary ] = doIterativeTest( LHs, clusterId, boundaries, win_len, features, tolerance, GT, has_GT, nUnaryDivisions, nPairwiseDivisions, previousMethods )
%%
%   Applies an iterative GC test increasing the value of the weighting term
%   by increments of W.
%
%   LHs:        likelihoods resulting from the previously applied 
%               clustering and/or adwin. This variable is a cell array with
%               1 or 2 positions, depending on the methods applied before.
%   clusterId:  clustering ids for each sample.
%               This variable is a cell array with
%               1 or 2 positions, depending on the methods applied before.
%   boundaries: resulting event boundaries for each of the previously
%               applied segmentation methods.
%   win_len:    window length used for the linking of the GC samples
%   features:   samples pair-wise features.
%   tolerance:  tolerance value for the evaluation
%   GT:         events starting points on the ground truth.
%   has_GT:     boolean indicating if we will evaluate w.r.t. GT.
%   nUnaryDivisions: number of unary weight divisions applied equally
%               spaced from 0 to 1.
%   nPairwiseDivisions: number of pairwise weight divisions applied equally
%               spaced from 0 to 1.
%   previousMethods: cell with two strings, which represent each of the
%               methods combined in the GraphCut smoothing.
%
%%%%%%

    nSamples = size(features,1);
    
    %% Calculate distances between features
    dists = pdist(features);
    dists = squareform(dists);
    
    if(length(LHs) == 2 && length(clusterId) == 2)
        %% Apply weighting between the clustering methods
        nClus = 2;
        if(has_GT)
            [~, ~, ~, fMeasureClus]=Rec_Pre_Acc_Evaluation(GT,boundaries{1},nSamples,tolerance);
            [~, ~, ~, fMeasureClus2]=Rec_Pre_Acc_Evaluation(GT,boundaries{2},nSamples,tolerance);
        end
    elseif(length(LHs) == 1 && length(clusterId) == 1)
        nClus = 1;
        if(has_GT)
            [~, ~, ~, fMeasureClus]=Rec_Pre_Acc_Evaluation(GT,boundaries{1},nSamples,tolerance);
        end
        LH_Clus = LHs{1};
    else
        error('LHs and start_clus variables must be cells with the same length and 2 terms as maximum!');
    end
    
    %% Single clustering plot
    if(nClus == 1)
        W_unary = [];
        W_pairwise = linspace(0,1,nPairwiseDivisions);
        W_pairwise(1) = 1e-99;

        vec_numC = zeros(1,nPairwiseDivisions);
        vec_perC = zeros(1,nPairwiseDivisions);
        
        %% Apply for each pairwise parameter
        for num_i = 1:nPairwiseDivisions
            LH_GC = buildGraphCuts(LH_Clus, features, win_len, W_pairwise(num_i), dists); 

            % Convert LH results on events separation (on GC result)
            [ labels, start_GC, num_clusters ] = getEventsFromLH(LH_GC);

            % Keep results and evaluate if we have the GT
            clusterIds(num_i,:) = labels;
            vec_numC(num_i) = num_clusters;
            if(has_GT)
                [~,~,~,vec_perC(num_i)]=Rec_Pre_Acc_Evaluation(GT,start_GC,nSamples,tolerance);
            end
        end    
        
        if(has_GT)
            fig = plotRClustering_2D(W_pairwise, vec_numC, vec_perC, fMeasureClus, previousMethods);
        else
            fig = [];
        end
        
    %% Dual clustering plot
    elseif(nClus == 2)
        W_unary = linspace(0,1,nUnaryDivisions);
        W_pairwise = linspace(0,1,nPairwiseDivisions);
        W_pairwise(1) = 1e-99;
        
        vec_numC = zeros(nUnaryDivisions,nPairwiseDivisions);
        vec_perC = zeros(nUnaryDivisions,nPairwiseDivisions);
        clusterIds = zeros(nUnaryDivisions,nPairwiseDivisions,nSamples);
        
        count_w2 = 1;
        pos_text = {};
        %% Apply for each unary parameter
        for w2 = W_unary
            % Calculate combined likelihoods
            LH_Clus = joinLHs(LHs, clusterId, w2);
            
            %% Apply for each pairwise parameter
            for num_i = 1:nPairwiseDivisions
                LH_GC = buildGraphCuts(LH_Clus, features, win_len, W_pairwise(num_i), dists);                                                         

                % Convert LH results on events separation (on GC result)
                [ labels, start_GC, num_clusters ] = getEventsFromLH(LH_GC);

                % Keep results and evaluate if we have the GT
                clusterIds(count_w2, num_i,:) = labels;
                vec_numC(count_w2, num_i) = num_clusters;
                if(has_GT)
                    [~,~,~,vec_perC(count_w2, num_i)]=Rec_Pre_Acc_Evaluation(GT,start_GC,nSamples,tolerance);
                end
            end

            % Show progress
            disp(['Tested ' num2str(count_w2) '/' num2str(nUnaryDivisions) ' different weights.']);
            count_w2 = count_w2+1;
        end

        %% Show 3D results comparison plot if we have the GT
        if(has_GT)
            previousFM = {fMeasureClus, fMeasureClus2};
            fig = plotRClustering_3D(W_unary, W_pairwise, vec_numC, vec_perC, previousFM, previousMethods);
        else
            fig = [];
        end

    end

end

