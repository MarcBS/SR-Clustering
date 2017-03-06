function labels = process_single_sequence_informative(camera, folder, indexes)  
    %% Load paths
    addpath('Adwin;Data_Loading;Evaluation;Features_Preprocessing');
    addpath('GCMex;GraphCuts;PCA;Tests;Utils;SpectralClust');

   directorio_im = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS'; 
   directorio_results = '/media/lifelogging/HDD_2TB/R-Clustering_Results_Informative';
   paramsfeatures.type = 'CNN'; %CNN ....                       
    paramsPCA.minVarPCA=0.95;
    paramsPCA.standarizePCA=false;
    paramsPCA.usePCA_Clustering = true;
    tol=5;
%% Clustering parameters
methods_indx={'single'};
% methods_indx={'centroid'};
cut_indx=(0.45:0.1:0.45);
% cut_indx = [0.45];
paramsPCA.usePCA_Clustering = true;
%% R-Clustering parameters
clus_type = 'Both1';
    %% Adwin parameters
    pnorm = 2;
    confidence = 0.1;
    paramsPCA.usePCA_Adwin = true;
    %% GraphCuts parameters
paramsPCA.usePCA_GC = false;
window_len = 11;

W_unary = 0.1;      % 0 <= W_unary <= 1 for evalType == 1
W_pairwise = 0.5;   % 0 <= W_pairwise <= 1 for evalType == 1

nUnaryDivisions = 5; % number of equally spaces W_unary values for evalType == 2
nPairwiseDivisions = 5; % number of equally spaced W_pairwise values for evalType == 2

plotFigResults = false;
doEvaluation = false;




    %% Build paths for images, features and results
    fichero=strcat(directorio_im, '/', camera,'/imageSets/', folder);
    path_features = strcat(directorio_im, '/', camera, '/CNNfeatures/CNNfeatures_', folder, '.mat');
    path_features_PCA = strcat(directorio_im,'/', camera, '/CNNfeatures/CNNfeaturesPCA_informative', folder, '.mat');
    root_results = strcat(directorio_results,'/',folder);
    mkdir(char(root_results));


    %% Features
    if strcmp(paramsfeatures.type, 'CNN')
        load(char(path_features));
        features = features(indexes,:);
        Nframes = size(features,1);
        %PCA FEATURES
        if(exist(char(path_features_PCA)) > 0)
            load(char(path_features_PCA));
        else
            [features_norm] = signedRootNormalization(features);
            [ featuresPCA, ~, ~ ] = applyPCA( features_norm, paramsPCA ) ; 
            save(char(path_features_PCA), 'featuresPCA');
        end
    elseif strcmp(paramsfeatures.type, 'MOPCNN')
        load(char(path_features_MOPCNN));
        features_adwin = X;
        clearvars X;
        load(path_features_MOPCNNnoLSH);   
        features = X;
        clearvars X;
    end
    
    %% CLUSTERING 

    LH_Clus={};
    start_clus={};
    previousMethods = {};
            
    %% ADWIN
    if strcmp(clus_type,'Both1')||strcmp(clus_type,'Both2')

        disp(['Start ADWIN ' folder]);

        % PCA
        if(paramsPCA.usePCA_Adwin && strcmp(paramsfeatures.type, 'CNN'))
            [labels,dist2mean] = runAdwin(featuresPCA, confidence, pnorm); 
        elseif( strcmp(paramsfeatures.type, 'CNN'))
            [features_norm] = signedRootNormalization(features);
            [labels,dist2mean] = runAdwin(features_norm, confidence, pnorm); 
        else
            [labels,dist2mean] = runAdwin(features_adwin, confidence, pnorm); 
        end

        index=1;
        automatic2 = [];
        for pos=1:length(labels)-1
            if (labels(pos)~=labels(pos+1))>0
                automatic2(index)=pos;
                index=index+1;
            end
        end
        if (exist('automatic2','var')==0)
            automatic2=0;
        end
       
        % Normalize distances
        dist2mean = normalizeAll(dist2mean);
        %dist2mean = signedRootNormalization(dist2mean')';

        bound_GC{2}=automatic2;
        LH_Clus{2}=getLHFromDists(dist2mean);
        start_clus{2}=labels;
        previousMethods{2} = 'ADWIN';
    end % end Adwin
            
            
    %% Clustering
    if strcmp(clus_type,'Both1')||strcmp(clus_type,'Clustering')
        
        %% PCA
        if(paramsPCA.usePCA_Clustering &&   strcmp(paramsfeatures.type, 'CNN'))
            similarities=pdist(featuresPCA,'cosine');
                           [features_norm] = signedRootNormalization(features);
        elseif( strcmp(paramsfeatures.type, 'CNN'))
            similarities=pdist(features_norm,'cosine');
               [features_norm] = signedRootNormalization(features);
        else
            similarities=pdist(features,'euclidean');          
        end  
        
        for met_indx=1:length(methods_indx)
            
            method=methods_indx{met_indx};  
            
            

            %% Clustering 
            Z = linkage(similarities, method);

            %% Cut value
            for idx_cut=1:length(cut_indx)

                cut=cut_indx(idx_cut);
                disp(['Start Clustering ' folder ', method ' method ', cutval ' num2str(cut)]);

                clustersId = cluster(Z, 'cutoff', cut, 'criterion', 'distance');
                automatic = compute_boundaries(clustersId,Nframes);


                RPAF_Clustering.clustersIDs = clustersId;
               
                
                if( strcmp(paramsfeatures.type, 'CNN'))
                    P=getLHFromClustering(features_norm,clustersId);
                else
                    P=getLHFromClustering(features,clustersId);                
                end
                LH_Clus{1} = P;
                start_clus{1}=clustersId';
                bound_GC{1}=automatic;
                previousMethods{1} = 'AC';

                %% Graph Cut
                % Build and calculate the Graph-Cuts
                
                disp('Start GC');
                
                %% PCA
                if(paramsPCA.usePCA_GC && strcmp(paramsfeatures.type, 'CNN'))
                    features_GC = featuresPCA;
                else
                    features_GC = features;
                end
                
                [features_GC, ~, ~] = normalize(features_GC);

                [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W_pairwise, features_GC, tol, [], doEvaluation, previousMethods);
               
                %% SAVE
                save(char(strcat(root_results, '/', 'Rclutering')),'labels');
                close all;
             end%end cut

             
        end %end method
        clearvars LH_Clus start_clus
    end %end if clustering || both1  
end%function

