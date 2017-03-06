nHyperplanes = 128;
nFeatures = 4096;

folder = '/Volumes/SHARED HD/Video Summarization Project Data Sets/R-Clustering/Narrative';

fold = 'Estefania1';

load([folder '/CNNfeatures/CNNfeatures_' fold]);
features = signedRootNormalization(features);

% Create hyperplane
r = zeros(nHyperplanes, nFeatures);
for i = 1:nHyperplanes
    r(i,:) = mvnrnd(0,1,nFeatures)';
end

h = zeros(size(features,1), nHyperplanes);
for i = 1:nHyperplanes
    h_tmp = r(i,:)*features';
    h_tmp(h_tmp >= 0) = 1;
    h_tmp(h_tmp < 0) = 0;
    h(:,i) = h_tmp';
end
