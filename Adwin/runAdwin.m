function [labels,dist2mean] = runAdwin(cnndata, fi, p)
%filename = '/home/mariella/MATLAB/Mariella/data/Narrative/CNNfeatures.mat'
%filename = '/home/mariella/MATLAB/Mariella/data/SenseCam/CNNfeatures_4254.mat'
%filename = '/home/mariella/MATLAB/Mariella/data/SenseCam/CNNfeatures_9000.mat'
%filename = '/home/mariella/MATLAB/Mariella/data/Narrative/estefania2_CNN.mat'
alpha = 0.5;%coefficient of the signed root normalization
pcadim = 500;%dimension of data after pca
% stringvec = strsplit(filename,'.');
%load CCN features from the .mat and put them into a variable called 'data'
% datastruct = load(filename);
% names = fieldnames(datastruct);
% cnndata = datastruct.(names{1});
%signed root normalization to produce more uniformly distributed data
% X = sign(cnndata).*(abs(cnndata).^alpha);
X = normalizeL2(cnndata);
%compute PCA
C = cov(double(X));
%eigenvectors of the covariance matrix
[V,D] = eigs(C, pcadim);
%project onto the new basis
X = double(X*V);
%after PCA there are negative values, rescale between 0 and 1
%data = zeros(size(X,1),size(X,2));
%data = (X-min(X(:))) ./ (max(X(:)-min(X(:))));
data=X;

%set parameters

epsilon= 1; % epsilon, 1 - sensitive segmentation; 0 - robust segmentation;


[w, indexes]=k_dim_segmentation(data,fi, p, epsilon);

indexes = indexes(2:end);
labels = zeros(1,size(data,1));
label = 1;

j=1;
for i=1:size(data,1)
    if i<=indexes(j)
      labels(i)=label;
    else
      label = label + 1;
      j=j+1;
      labels(i)=label;
    end
end

 Nclusters = size(indexes,2);
    clusters = zeros(Nclusters,size(w,2));
    i = 1;
    for j=1:Nclusters
        clusters(j,:) = w(indexes(i)-1,:);
        i=i+1;
    end
   
   
    dist2mean = zeros(size(w,1), Nclusters);
    for j=1:size(w,1)%for each sample
        for i=1:Nclusters
            %average on the neighbors
            nneigh = 0;
            for k=-2:2
                if ((k+j)>0 & (k+j)<=size(data,1))
                    dist2mean(j,i) =  dist2mean(j,i) + norm(data(j+k,:)-clusters(i,:));
                    nneigh = nneigh + 1;
                end          
            end
            dist2mean(j,i) = dist2mean(j,i)/nneigh;
        end
    end



