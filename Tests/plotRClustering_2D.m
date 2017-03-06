function [ fig ] = plotRClustering_2D( W_pairwise, numEvents, fMeasure_GC, previousFM, previousMethods )
%PLOTRCLUSTERING_2D Plots a 3D representation of R-Clustering result for each
%   GraphCut pair of parameters.
%
%   W_pairwise -> vector with set of pairwise weights for setting the
%       importance of the pairwise GC term. All values must be
%       greater or equal than 0 and smaller or equal than 1.
%
%   numEvents -> vector M with all the resulting number of events for
%       each GC parameter. Where M = len(W_pairwise)
%
%   fMeasure_GC -> vector M with all the resulting F-Measures for each 
%       GC parameter. Where M = len(W_pairwise)
%
%   previousFM -> F-Measures of the method used as a baseline for the 
%       GraphCut smoothing.
%
%   previousMethods -> cell with a string which represents the baseline
%       method for the GraphCut smoothing.
%
%%%%%

    nPairwiseDivisions = length(W_pairwise);

    fig = figure;

    scatter(W_pairwise, ((numEvents-min(numEvents))./(max(numEvents) - min(numEvents))), 25, [0 0 0.8], 'filled'); % num events points
    text(W_pairwise, ((numEvents-min(numEvents))./(max(numEvents) - min(numEvents))), cellstr(num2str(numEvents'))); % num events labels
    line(W_pairwise, fMeasure_GC, 'Color', 'g', 'LineWidth', 1.5) % GC accuracy
    line(W_pairwise, ones(1,nPairwiseDivisions)*previousFM, 'Color', 'r', 'LineWidth', 2) % Clustering accuracy
    legend('Number Events', 'GC F-Measure', [previousMethods{1} ' F-Measure'], 1);
    title('Test data F-Measure comparison.', 'FontSize', 18);
    ylabel('F-Measure', 'FontSize', 16);
    xlabel('Pairwise weight', 'FontSize', 16);
    set(gca,'FontSize',16);

end

