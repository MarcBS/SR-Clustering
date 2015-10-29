%%%%%%% R-Clustering demo file
% This demo applies the R-Clustering segmentation algorithm on a set
% captured by a lifelogging wearable camera.
%
% For a visualization of the result, use the 'plot_params' variable in 
% loadParametersDemo.m.

cd('Demo');

% Load parameters
loadParametersDemo;

sets=[ 105 ];

for i=1:1:length(sets)
    % Folder with lifelogging images that we want to segment
    folder = [pwd '/test_data/' num2str(sets(i)) '_full_Crop'];
    % Format of the images in 'folder'
    images_format = '.jpg';
    % Excel .xls file with the segmentation GT of the data
    % (OPTIONAL, set to empty string if you don't want an evaluation of the result) 
    %GT_path = [pwd '/test_data/GT/GT_Subject1.xls'];
    GT_path = '';

    %% The R-Clustering segmentation is applied
    segmentation = RClustering(folder, images_format, data_params, R_Clustering_params, CNN_params, Semantic_params, plot_params, GT_path);

end

cd('..');
