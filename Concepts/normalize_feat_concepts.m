function normalize_feat_concepts(path2concepts,Nimages)
addpath('/media/lifelogging/HDD_2TB/R-Clustering/Features_Preprocessing')
cd(path2concepts)
files_CNNconcepts = dir();
l=0;
mkdir normalized
for i=1:Nimages
        while isempty(strfind(files_CNNconcepts(i+l).name,'feat_concepts'))
            l=l+1;
        end
        i
        %load concept matrix for image i
        load([path2concepts files_CNNconcepts(i+l).name]);%
        %compute signed root normalization of concepts   
        for p=1:size(feat_concepts,2)
            if(~isempty(feat_concepts{p}))
                for q=1:size(feat_concepts,1)
                    feat_concepts{p}(q,:) = signedRootNormalization(feat_concepts{p}(q,:));
                end
            end
        end
        save([path2concepts 'normalized/' files_CNNconcepts(i+l).name],'feat_concepts','-v7.3')
end


        
end
