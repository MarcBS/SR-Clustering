function S = concept_distance_4_clustering(path2concepts,path_featuresPCA)
addpath('/media/lifelogging/HDD_2TB/R-Clustering/Concepts')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sequence_number = 9;
%path2concepts = ['/media/lifelogging/HDD_2TB/Video_Summarization_Tests/CNNconcepts/Exec_ConceptDiscovery_' num2str(sequence_number) '/Concept_featuresPCA/'];
%path_featuresPCA = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/SenseCam/CNNfeatures/CNNfeatures_Day4.mat';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cd(path2concepts)
files_CNNconcepts = dir();

load(path_featuresPCA);%this will load a variable called featuresPCA
n = size(featuresPCA,1);
S = zeros(1,n*(n-1)./2);
k = 1;% at the end k should be n*(n-1)./2
l=0;
for i=1:n-1
    CNN1 = normalizeL2(featuresPCA(i,:));
    while isempty(strfind(files_CNNconcepts(i+l).name,'feat_concepts'))
        l=l+1;
    end
        %load concept matrix for image i
        load([path2concepts files_CNNconcepts(i+l).name]);%matriz de conceptos
        %signed root normalization to each object
        %[featuresPCA_norm] = signedRootNormalization(feat_concepts);
        objects1 =  feat_concepts;
        clearvars feat_concepts;
        for j=i+1:n
            %load gloabl CNN for image j
            CNN2 =  normalizeL2(featuresPCA(j,:));
            %load concept matrix for image j
            load(files_CNNconcepts(j+l).name);%matriz de conceptos       
            objects2 =  feat_concepts; 
            clearvars feat_concepts;
            %compute similarity
            S(k) = compute_concept_similarity(CNN1,CNN2,objects1,objects2);
        end%end for
end%end for
           
end
  

    %load global CNN for image i
    %filename = files_CNNglobal(i).name;
    %datastruct = load(filename);
    %names = fieldnames(datastruct);
    %CNN1 = datastruct.(names{1});
% path2concepts = '/media/lifelogging/HDD_2TB/Video_Summarization_Tests/ExecutionResults/'%the input should be like this
% cd(path2concepts);%path to 
% dirinfo = dir()%k=12
% for k=1:lenth(dir)
%     if ~isempty(strfind(dirinfo(k).name,'Exec_ConceptDiscovery_'))
%          nameFolder = dirinfo(k).name;
%          files_CNN =dir([path2concepts nameFolder '/Concept_featuresPCA/*.mat']);
%          for i=1:length(filesCNN)
%              if ~isempty(strfind(dirinfo(k).name,'feat_concepts'))
%                 load(filesCNN(i).name);
%              end
%          end      
% end%end if
% end%end for
