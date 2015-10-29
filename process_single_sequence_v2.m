function events = process_single_sequence_v2(folder, params)

    %% Load paths
    addpath('Adwin;Data_Loading;Evaluation;Features_Preprocessing');
    addpath('GCMex;GraphCuts;PCA;Tests;Utils;SpectralClust');

    load_features = true;

    %% Parameters loading
    fichero = params.files_path;               
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
    [~, folder_name, ~] = fileparts(folder);
    path_features = [params.features_path '/CNNfeatures/CNNfeatures_' folder_name '.mat'];
    path_features_PCA = [params.features_path '/CNNfeatures/CNNfeaturesPCA_' folder_name '.mat'];
    path_semantic_features = [params.features_path '/SemanticFeatures/SemanticFeatures_' folder_name '.mat'];
    
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


    %% Global Features
    if strcmp(paramsfeatures.type, 'CNN')
        if(load_features)
            load(path_features);
            [features_norm] = signedRootNormalization(features);
        end

        %PCA FEATURES
        if(exist(path_features_PCA) > 0)
            load(path_features_PCA);
        else
            [ featuresPCA, ~, ~ ] = applyPCA( features_norm, paramsPCA ) ; 
            if(load_features) % if we wanted to load the stored features, then we will also store PCA features
                save(path_features_PCA, 'featuresPCA');
            end
        end
    end
    
    %% Semantic Features
    if(params.use_semantic)
        if(load_features)
            load(path_semantic_features); % 'tag_matrix'
        end
    else
        tag_matrix = [];
    end
    
    
    %% CLUSTERING 

    LH_Clus={};
    start_clus={};
    previousMethods = {};
            
    %% ADWIN
    if strcmp(clus_type,'Both1')||strcmp(clus_type,'Both2')

        disp(['Start ADWIN ' folder_name]);

        % PCA
        if(paramsPCA.usePCA_Adwin && strcmp(paramsfeatures.type, 'CNN'))
            [labels,dist2mean] = runAdwin([featuresPCA, tag_matrix'], confidence, pnorm); 
        elseif( strcmp(paramsfeatures.type, 'CNN'))
            [features_norm] = signedRootNormalization(features);
            [labels,dist2mean] = runAdwin([features_norm, tag_matrix'], confidence, pnorm); 
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
            similarities=pdist([featuresPCA, tag_matrix'],'cosine');
        elseif( strcmp(paramsfeatures.type, 'CNN'))
            similarities=pdist([features_norm, tag_matrix'],'cosine');    
        end  
        
        for met_indx=1:length(methods_indx)
            
            method=methods_indx{met_indx};  


            %% Clustering 
            Z = linkage(similarities, method);

            %% Cut value
            for idx_cut=1:length(cut_indx)

                cut=cut_indx(idx_cut);
                disp(['Start Clustering ' folder_name ', method ' method ', cutval ' num2str(cut)]);

                clustersId = cluster(Z, 'cutoff', cut, 'criterion', 'distance');
                automatic = compute_boundaries(clustersId,files);
               
                
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
                    features_GC = [featuresPCA, tag_matrix'];
                else
                    features_GC = [features, tag_matrix'];
                end
                
                [features_GC, ~, ~] = normalize(features_GC);

                [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W_pairwise, features_GC, tol, GT, doEvaluation, previousMethods);
                
                close all;
             end%end cut

             
        end %end method
        clearvars LH_Clus start_clus
    end %end if clustering || both1  

    
    nFrames = length(labels);
    events = zeros(1, nFrames); events(1) = 1;
    prev = 1;
    for i = 1:nFrames
        if(labels(i) == 0)
            events(i) = 0;
        else
            if(labels(i) == labels(prev))
                events(i) = events(prev);
            else
                events(i) = events(prev)+1;
            end
            prev = i;
        end
    end
