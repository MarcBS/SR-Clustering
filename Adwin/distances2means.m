function distances2means()

 path2CNN = '/home/mariella/MATLAB/Mariella/data/Narrative/CNNfeatures/';
 path2clusters = '/home/mariella/MATLAB/Mariella/adwin/means_clusters/Narrative/';
 files_clusters=dir([path2clusters '/*.mat']);
 files_CNN=dir([path2CNN '/*.mat']);
 alpha = 0.5;%coefficient of the signed root normalization
 pcadim = 500;%dimension of data after pca
 for i=1:length(files_CNN)
     filename = files_CNN(i).name;
     datastruct = load(strcat(path2CNN,filename));
    names = fieldnames(datastruct);
    cnndata = datastruct.(names{1});
    %name for the 
    vecstring = strsplit(filename,'.');
    namevar = strcat('dist2mean_',char(vecstring(1)),'.mat');
    %signed root normalization to produce more uniformly distributed data
    X = sign(cnndata).*(abs(cnndata).^alpha);
    X = normalize(X);
    %compute PCA
    C = cov(double(X));
    %eigenvectors of the covariance matrix
    [V,~] = eigs(C, pcadim);
    %project onto the new basis
    X = double(X*V);
    %after PCA there are negative values, rescale between 0 and 1
    data = zeros(size(X,1),size(X,2));
    data = (X-min(X(:))) ./ (max(X(:)-min(X(:))));
    
    filename = files_clusters(i).name;
    load(strcat(path2clusters,filename));
    dist2mean = zeros(1,size(w,1));
    for j=1:size(w,1)
        %average on the neighbors
        nneigh = 0;
        for k=-2:2
            if ((k+j)>0 & (k+j)<=size(data,1))
                dist2mean(j) =  dist2mean(j) + norm(data(j+k,:)-w(j,:));
                nneigh = nneigh + 1;
            end           
        end
        dist2mean(j) = dist2mean(j)/nneigh;
    end
    save(namevar,'dist2mean');
 end
 