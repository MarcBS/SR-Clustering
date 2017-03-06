function compute_features_adwin(path2concepts,pcadim)  
  filesCNNconcepts = dir(path2concepts);%for each image we have a matrix 
  %features_concepts = zeros(1,length(feat_concepts),4096);
  for i=1:length(filesCNNconcepts)%for each image
      if ~isempty(strfind(filesCNNconcepts(i).name,'feat_concepts'))
          %filesCNNconcepts(i).name;
          load([path2concepts filesCNNconcepts(i).name]);%matriz de conceptos
           %mean over multiple instances of the same concept
           for j=1:length(feat_concepts)%for each concept
               mean_feat_concepts = zeros(1,4096);
               for k=1:size(feat_concepts{j},1)%number of istances of the same concept
                    mean_feat_concepts = mean_feat_concepts + feat_concepts{j}(k,:);
               end
               %divide by the number of object instances
               if size(feat_concepts{j},1)>0
                    features_concepts_adwin(j,:,i) = mean_feat_concepts/size(feat_concepts{j},1);
               else
                    features_concepts_adwin(j,:,i) = mean_feat_concepts;
               end                  
           end        
      end    

  end
  
  %j concept
  %m concept vector
  %i image

   Nimages = size(features_concepts_adwin,3);
   Nconcepts = size(features_concepts_adwin,1);
 
  X = [];
  for k=1:size(features_concepts_adwin,3)
    X = [X;features_concepts_adwin(:,:,k)];
  end
  clearvars features_concepts_adwin;
  [Y] = signedRootNormalization(X);
  clearvars X;

                   
C = cov(double(Y));
[V,~] = eigs(C, pcadim);
clearvars C;
X = double(Y*V);
features_concepts_adwin = [];
for k=1:Nimages
features_concepts_adwin(:,:,k) = X((k-1)*Nconcepts + 1:k*Nconcepts,:);
end
 
  save([path2concepts  'average.mat'],'features_concepts_adwin','-v7.3');

  
end
