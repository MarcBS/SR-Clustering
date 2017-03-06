function [ clusters ] = colorSegmentation( features, segmentation_params )
%COLORSEGMENTATION Applies a segmentation based on color.
% Implementation of the segmentation method described in the paper names
% in mainColorSegment.m
%%%%%

%     global t;
    t = segmentation_params.t;
%     global chi2_distances_square;
%     global chi2_mean;
    nSamples = size(features,1);
    
    %% Calculate distances between frames
    chi2_distances = pdist(features, @chi2_dist);
    chi2_distances_square = squareform(chi2_distances);
    chi2_mean = mean(chi2_distances);
    chi2_std = std(reshape(chi2_distances, 1, size(chi2_distances,1)*size(chi2_distances,2)));
   
    samples_dist = [[1:nSamples]' chi2_distances_square ones(nSamples,1)*chi2_mean ones(nSamples,1)*t];
    distances = pdist(samples_dist, @color_dist);
    
%     cut = chi2_mean + chi2_std*2;
    cut = mean(distances)-std(distances)*2;
    
    %% Agglomerative clustering
    Z = linkage(distances, 'complete');
    clusters = cluster(Z, 'cutoff', cut, 'criterion', 'distance');

end

