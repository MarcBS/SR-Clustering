function labels = process_single_sequence(camera, folder, params)  
    %% Load paths
    addpath('Adwin;Data_Loading;Evaluation;Features_Preprocessing');
    addpath('GCMex;GraphCuts;PCA;Tests;Utils;SpectralClust');

    %% Parameters loading
    if nargin < 3
        directorio_im = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS'; 
        directorio_results = '/media/lifelogging/HDD_2TB/R-Clustering_Results_Informative';
        formats = '.jpg';
        
        doEvaluation = false;
        GT = [];
        
        %% Clustering parameters
        methods_indx={'single'};
        % methods_indx={'centroid'};
        cut_indx=(0.5:0.1:0.5);
        % cut_indx = [0.45];
        paramsPCA.usePCA_Clustering = true;
        %% R-Clustering parameters
        clus_type = 'Both1';
        %% GraphCuts parameters
        W_unary = 0.1;      % 0 <= W_unary <= 1 for evalType == 1
        W_pairwise = 0.5;   % 0 <= W_pairwise <= 1 for evalType == 1

        evalType = 2;
        
        nUnaryDivisions = 5; % number of equally spaces W_unary values for evalType == 2
        nPairwiseDivisions = 5; % number of equally spaced W_pairwise values for evalType == 2
    else
        directorio_im = params.files_path; 
        directorio_results = params.RC_results_path;                    
        formats = params.formats;
        
        doEvaluation = params.doEvaluation;
        if(doEvaluation);
            GT = params.GT;
        else
            GT = [];
        end
        
        %% Clustering parameters
        methods_indx= params.methods_indx;
        cut_indx= params.cut_indx_use;
        paramsPCA.usePCA_Clustering = true;
        
        %% R-Clustering parameters
        clus_type = params.clus_type;
        
        %% GraphCuts parameters
        evalType = 1;
        W_unary = params.W_unary;      % 0 <= W_unary <= 1
        W_pairwise = params.W_pairwise;   % 0 <= W_pairwise <= 1
    end
    paramsfeatures.type = 'CNN'; %CNN ....
    paramsPCA.minVarPCA=0.95;
    paramsPCA.standarizePCA=false;
    paramsPCA.usePCA_Clustering = true;
    
    plotFigResults = false;
    %% Adwin parameters
    pnorm = 2;
    confidence = 0.1;
    paramsPCA.usePCA_Adwin = true;
    %% GraphCuts parameters
    paramsPCA.usePCA_GC = false;
    window_len = 11;
    %% Evaluation parameters
    tol=5; % tolerance for the final evaluation  



    %% Build paths for images, features and results
    fichero=([directorio_im '/' camera '/imageSets/' folder]);
    path_features = [directorio_im '/' camera '/CNNfeatures/CNNfeatures_' folder '.mat'];
    path_features_PCA = [directorio_im '/' camera '/CNNfeatures/CNNfeaturesPCA_' folder '.mat'];
    root_results = [directorio_results '/' folder];
    mkdir(root_results);
    %% Images
    files_aux=dir([fichero '/*' formats]);
    count = 1;
	files = struct('name', []);
    for n_files = 1:length(files_aux)
        if(files_aux(n_files).name(1) ~= '.')
            files(count).name = files_aux(n_files).name;
            count = count+1;
        end
    end
    Nframes=length(files);


    %% Features
    if strcmp(paramsfeatures.type, 'CNN')
        load(path_features);
   

        %PCA FEATURES
        if(exist(path_features_PCA) > 0)
            load(path_features_PCA);
        else
            [features_norm] = signedRootNormalization(features);
            [ featuresPCA, ~, ~ ] = applyPCA( features_norm, paramsPCA ) ; 
            save(path_features_PCA, 'featuresPCA');
        end
    elseif strcmp(paramsfeatures.type, 'MOPCNN')
        load(path_features_MOPCNN);
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
            
            %% Load Results file if exists
            if(evalType == 2)
                file_save=(['Results_' method '_Res_' clus_type '_' folder '.mat']);
                offset_results = 0;
            end
            

            %% Clustering 
            Z = linkage(similarities, method);

            %% Cut value
            for idx_cut=1:length(cut_indx)

                cut=cut_indx(idx_cut);
                disp(['Start Clustering ' folder ', method ' method ', cutval ' num2str(cut)]);

                clustersId = cluster(Z, 'cutoff', cut, 'criterion', 'distance');
                automatic = compute_boundaries(clustersId,files);


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
                if(evalType == 2)
                    [ fig , num_clus_GC, fMeasure_GC, eventsIDs, W_u_tested, W_p_tested ] = doIterativeTest(LH_Clus, start_clus, bound_GC, window_len, features_GC, tol, delim,1, nUnaryDivisions, nPairwiseDivisions, previousMethods, plotFigResults);

                    %% Store results
                    
                    % Plot
                    if(plotFigResults)
                        if(~isempty(fig))
                            fig_save = ([method '_cutVal_' num2str(cut) '.fig']);
                        end
                        saveas(fig,[root_results '/' fig_save]);
                    end

                elseif(evalType == 1)
                    [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W_pairwise, features_GC, tol, GT, doEvaluation, previousMethods);
                end % end GC
                             %% SAVE
        save([root_results '/' folder '_' num2str(idx_cut)],'automatic');
                close all;
             end%end cut


             %% SAVE
     
             if(evalType == 2)
                save([root_results '/' file_save], 'Results');
             end
             
        end %end method
        clearvars LH_Clus start_clus
    end %end if clustering || both1  

