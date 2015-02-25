function [ fig ] = plotRClustering_3D( W_unary, W_pairwise, numEvents, fMeasure_GC, previousFM, previousMethods )
%PLOTGC_3D Plots a 3D representation of R-Clustering result for each
%   GraphCut pair of parameters.
%
%   W_unary -> vector with set of unary weights for setting the
%       relationship between the joined segmentations. All values must be
%       greater or equal than 0 and smaller or equal than 1.
%
%   W_pairwise -> vector with set of pairwise weights for setting the
%       importance of the pairwise GC term. All values must be
%       greater or equal than 0 and smaller or equal than 1.
%
%   numEvents -> matrix NxM with all the resulting number of events for
%       each possible GC parameter. Where N = len(W_unary) and M = len(W_pairwise)
%
%   fMeasure_GC -> matrix NxM with all the resulting F-Measures for each 
%       combination of GC parameters. Where N = len(W_unary) and M = len(W_pairwise)
%
%   previousFM -> cell with two resulting F-Measures, one for each of the
%       methods combined in the GraphCut smoothing.
%
%   previousMethods -> cell with two strings, which represent each of the
%       methods combined in the GraphCut smoothing.
%
%%%%%

    %% Prepare initial variables
    nUnaryDivisions = length(W_unary);
    nPairwiseDivisions = length(W_pairwise);

    fMeasureClus = previousFM{1};
    fMeasureClus2 = previousFM{2};
    
    fig = figure; hold all;
    
    %% Prepare plot colours
    blue = [0 0 0.8];
    white = ones(nUnaryDivisions,nPairwiseDivisions,3);
    red = white; red(:,:,[2 3]) = 0;
    green = white; green(:,:,[1 3]) = 0;
    orange = white; orange(:,:,3) = 0; orange(:,:,2) = 0.65;

    
    %% Plot text number of clusters
    count_w2 = 1;
    for w2 = W_unary
        this_nums = numEvents(count_w2,:);
        pos_text{count_w2} = ((this_nums-min(this_nums))./(max(this_nums) - min(this_nums)));
        
        scatter3(W_pairwise, ones(1,nPairwiseDivisions)*w2, pos_text{count_w2}, 25, blue, 'filled'); % num events points
        hold all;
        text(W_pairwise, ones(1,nPairwiseDivisions)*w2, pos_text{count_w2}+0.02, cellstr(num2str(numEvents(count_w2,:)'))); % num events labels
        
        count_w2 = count_w2+1;
    end
   

    %% Plot surfaces
    surf(W_pairwise, W_unary, fMeasure_GC, green) % GC fmeasure
    surf(W_pairwise, W_unary, repmat((ones(1,nPairwiseDivisions)*fMeasureClus),nUnaryDivisions,1), red) % Clustering fmeasure
    surf(W_pairwise, W_unary, repmat((ones(1,nPairwiseDivisions)*fMeasureClus2),nUnaryDivisions,1), orange) % Clustering2 fmeasure

    %% Set legend
    colors = [blue; reshape(green(1,1,:), 1, 3); reshape(red(1,1,:), 1, 3); reshape(orange(1,1,:), 1, 3)];
    h(1) = scatter3([], [], [], 50, colors(1,:), 'filled');
    h(2) = scatter3([], [], [], 50, colors(2,:), 'filled');
    h(3) = scatter3([], [], [], 50, colors(3,:), 'filled');
    h(4) = scatter3([], [], [], 50, colors(4,:), 'filled');
    legend(h, {'Number Events'; 'GC F-Measure'; [previousMethods{1} ' F-Measure']; [previousMethods{2} ' F-Measure']}, 1);

    %% Set other text
    title('Test data F-Measure comparison.', 'FontSize', 18);
    zlabel('F-Measure', 'FontSize', 16);
    ylabel('Unary weight', 'FontSize', 16);
    xlabel('Pairwise weight', 'FontSize', 16);
    set(gca,'FontSize',16);
    
end

