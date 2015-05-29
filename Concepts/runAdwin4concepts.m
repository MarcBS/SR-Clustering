function [labels,dist2mean] = runAdwin4concepts(data_global,data_concepts, fi, p)


%set parameters

epsilon= 1; % epsilon, 1 - sensitive segmentation; 0 - robust segmentation;


[w_global, w_concepts, indexes] = k_dim_segmentation_concepts(data_global,data_concepts,fi, p, epsilon);

indexes = indexes(2:end);
labels = zeros(1,size(data_global,1));
label = 1;

j=1;
for i=1:size(data_global,1)
    if i<=indexes(j)
      labels(i)=label;
    else
      label = label + 1;
      j=j+1;
      labels(i)=label;
    end
end

 Nclusters = size(indexes,2);
    clusters_global = zeros(Nclusters,size(w_global,2));
    clusters_concepts = zeros(size(w_concepts,1),size(w_concepts,2), Nclusters);
    i = 1;
    for j=1:Nclusters
        clusters_global(j,:) = w_global(indexes(i)-1,:);
        clusters_concepts(:,:,j) = w_concepts(:,:,indexes(i)-1);
        i=i+1;
    end
   
   
    dist2mean = zeros(size(w_global,1), Nclusters);
    for j=1:size(w_global,1)%for each sample
        for i=1:Nclusters
            %average on the neighbors
            nneigh = 0;
            for k=-2:2
                if ((k+j)>0 & (k+j)<=size(data_global,1))
                   mu_w0_global = data_global(j+k,:);
                   mu_w0_concepts = data_concepts(:,:,j+k);
                   mu_w1_global = clusters_global(i,:);
                   mu_w1_concepts = clusters_concepts(:,:,i);
                  
                    dist = compute_distance_adwin(mu_w0_global,mu_w1_global,mu_w0_concepts,mu_w1_concepts);
                    dist2mean(j,i) =  dist2mean(j,i) + dist;
                    nneigh = nneigh + 1;
                end          
            end
            dist2mean(j,i) = dist2mean(j,i)/nneigh;
        end
    end

