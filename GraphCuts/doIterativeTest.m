function [ fig ,vec_numC,vec_perC,clusterIds ] = doIterativeTest( LHs, clusterId, bound, maxTest, win_len, W, W2, features, tolerance, GT, clus_type, has_GT )
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
%   maxTest:    number of iterations applied.
%   win_len:    window length used for the linking of the GC samples
%   W:          weighting term applied on the pair-wise term (increas in
%               each iteration).
%               W > 0
%   W2:         weighting term applied to the LHs of the two clustering
%               methods (only if there are 2 elements in LHs).
%               0 <= W2 <= 1
%   features:   samples pair-wise features.
%   tolerance:  tolerance value for the evaluation
%   GT:         events starting points on the ground truth.
%
%%%%%%
    nSamples = size(features,1);
    nW = 5;
    
    dists = pdist(features);
%     dists = normalizeHistograms(dists);
    dists = squareform(dists);
    
    if(length(LHs) == 2 && length(clusterId) == 2)
        %% Apply weighting between the clustering methods
        nClus = 2;
        if(has_GT)
            [~, ~, ~, fMeasureClus]=Rec_Pre_Acc_Evaluation(GT,bound{1},nSamples,tolerance);
            [~, ~, ~, fMeasureClus2]=Rec_Pre_Acc_Evaluation(GT,bound{2},nSamples,tolerance);
        end
    elseif(length(LHs) == 1 && length(clusterId) == 1)
        nClus = 1;
        if(has_GT)
            [~, ~, ~, fMeasureClus]=Rec_Pre_Acc_Evaluation(GT,bound{1},nSamples,tolerance);
        end
        LH_Clus = LHs{1};
    else
        error('LHs and start_clus variables must be cells with the same length and 2 terms as maximum!');
    end
    
    %% Single clustering plot
    if(nClus == 1)
        %%%%%%%%%%% TESTS
        offset = 1e-99;
        vec_numC = zeros(1,maxTest);
        vec_perC = zeros(1,maxTest);
        for num_i = [1:maxTest]
        %%%%%%%%%%

%             tic
%             disp('Applying Graph-Cut smoothing...');
            % TESTS: num_i*increment+offset
            LH_GC = buildGraphCuts(LH_Clus, features, win_len, (num_i-1)*W+offset); 
        %     LH_GC = buildGraphCuts(LH_Clus, features, win_len, power((num_i-1)*W, num_i-1)+offset); 
                                        % (the higher the less events)
%             toc                                                             


            %% Convert LH results on events separation (on GC result)
            [ labels, start_GC, num_clusters ] = getEventsFromLH(LH_GC);


        %%%%%%%%%%% TESTS
            vec_numC(num_i) = num_clusters;
            if(has_GT)
                [~,~,~,vec_perC(num_i)]=Rec_Pre_Acc_Evaluation(GT,start_GC,nSamples,tolerance);
            end
        end    
        fig = figure;
        if(has_GT)
            scatter([1:maxTest]-1, ((vec_numC-min(vec_numC))./(max(vec_numC) - min(vec_numC))), 25, [0 0 0.8], 'filled'); % num events points
            text([1:maxTest]-1-0.05, ((vec_numC-min(vec_numC))./(max(vec_numC) - min(vec_numC))), cellstr(num2str(vec_numC'))); % num events labels
            line([1:maxTest]-1, vec_perC, 'Color', 'g', 'LineWidth', 1.5) % GC accuracy
            line([1:maxTest]-1, ones(1,maxTest)*fMeasureClus, 'Color', 'r', 'LineWidth', 2) % Clustering accuracy
            legend('Number Events', 'GC F-Measure', [clus_type ' F-Measure'], 1);
            set(gca,'XTick', [1:maxTest]-1 ); % x axis labels positions
            xticklabel_rotate([1:maxTest]-1,90,num2cell(([1:maxTest]-1).*W+offset), 'FontSize', 16,'interpreter','none');
            title('Test data F-Measure comparison.', 'FontSize', 18);
            ylabel('F-Measure', 'FontSize', 16);
            xlabel('GC tuning value.', 'FontSize', 16);
            set(gca,'FontSize',16);
            %%%%%%%%%%%
        end
        
    %% Dual clustering plot
    elseif(nClus == 2)
        W2 = linspace(0,1,nW);
        
        vec_numC = zeros(length(W2),maxTest);
        vec_perC = zeros(length(W2),maxTest);
        clusterIds = zeros(length(W2),maxTest,nSamples);
        
        fig = figure; hold all;
        
        count_w2 = 1;
        for w2 = W2
            % Calculate combined likelihoods
            LH_Clus = joinLHs(LHs, clusterId, w2);
            
            offset = 1e-99;
            for num_i = [1:maxTest]

%                 tic
%                 disp('Applying Graph-Cut smoothing...');
                % TESTS: num_i*increment+offset
                LH_GC = buildGraphCuts(LH_Clus, features, win_len, (num_i-1)*W+offset, dists); 
            %     LH_GC = buildGraphCuts(LH_Clus, features, win_len, power((num_i-1)*W, num_i-1)+offset); 
                                            % (the higher the less events)
%                 toc                                                             


                %% Convert LH results on events separation (on GC result)
                [ labels, start_GC, num_clusters ] = getEventsFromLH(LH_GC);
                

            %%%%%%%%%%% TESTS
                clusterIds(count_w2, num_i,:) = labels;
                vec_numC(count_w2, num_i) = num_clusters;
                if(has_GT)
                    [~,~,~,vec_perC(count_w2, num_i)]=Rec_Pre_Acc_Evaluation(GT,start_GC,nSamples,tolerance);
                end
            end
            
            blue = [0 0 0.8];
            
            % Plot figure information
            if(has_GT)
                this_nums = vec_numC(count_w2,:);
                pos = ((this_nums-min(this_nums))./(max(this_nums) - min(this_nums)));
                scatter3([1:maxTest]-1, ones(1,maxTest)*w2, pos, 25, blue, 'filled'); % num events points
                hold all;
                text([1:maxTest]-1+0.05, ones(1,maxTest)*w2, pos+0.02, cellstr(num2str(vec_numC(count_w2,:)'))); % num events labels
            end
            disp(['Tested ' num2str(count_w2) '/' num2str(nW) ' different weights.']);
            count_w2 = count_w2+1;
        end
        
        white = ones(nW,maxTest,3);
        red = white; red(:,:,[2 3]) = 0;
        green = white; green(:,:,[1 3]) = 0;
        orange = white; orange(:,:,3) = 0; orange(:,:,2) = 0.65;
        
        if(has_GT)
            surf([1:maxTest]-1, W2, vec_perC, green) % GC accuracy
            surf([1:maxTest]-1, W2, repmat((ones(1,maxTest)*fMeasureClus),nW,1), red) % Clustering accuracy
            surf([1:maxTest]-1, W2, repmat((ones(1,maxTest)*fMeasureClus2),nW,1), orange) % Clustering2 accuracy
%         line([1:maxTest]-1, vec_perC, 'Color', 'g', 'LineWidth', 1.5) % GC accuracy
%         line([1:maxTest]-1, ones(1,maxTest)*fMeasureClus, 'Color', 'r', 'LineWidth', 2) % Clustering accuracy
%         line([1:maxTest]-1, ones(1,maxTest)*fMeasureClus2, 'Color', 'r', 'LineWidth', 2) % Clustering2 accuracy
        
            %% Set legend
            colors = [blue; reshape(green(1,1,:), 1, 3); reshape(red(1,1,:), 1, 3); reshape(orange(1,1,:), 1, 3)];
            h(1) = scatter3([], [], [], 50, colors(1,:), 'filled');
            h(2) = scatter3([], [], [], 50, colors(2,:), 'filled');
            h(3) = scatter3([], [], [], 50, colors(3,:), 'filled');
            h(4) = scatter3([], [], [], 50, colors(4,:), 'filled');
            legend(h, {'Number Events'; 'GC F-Measure'; 'Clustering F-Measure'; 'Adwin F-Measure'}, 1);

            %% Set other text
            set(gca,'XTick', [1:maxTest]-1 ); % x axis labels positions
            xticklabel_rotate([1:maxTest]-1,90,num2cell(([1:maxTest]-1).*W+offset), 'FontSize', 16,'interpreter','none');
            title('Test data F-Measure comparison.', 'FontSize', 18);
            zlabel('F-Measure', 'FontSize', 16);
            ylabel('LH weighting term', 'FontSize', 16);
            xlabel('GC tuning value', 'FontSize', 16);
            set(gca,'FontSize',16);
            %%%%%%%%%%%
        end
    end

end
