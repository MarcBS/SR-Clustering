
%% Loads parameters
loadParameters;


%% Folders
for i_fold=1:length(folders)
    
    %% Build paths for images, excel, features and results
    folder=folders{i_fold};
    fichero=([directorio_im '/' camera{i_fold} '/imageSets/' folder]);
    path_excel = [directorio_im '/' camera{i_fold} '/GT/GT_' folder '.xls'];
    path_features_MOPCNNnoLSH = [directorio_im '/' camera{i_fold} '/CNNfeatures/' folder '/MOPCNNnoLSH.mat'];
    path_features_MOPCNN = [directorio_im '/' camera{i_fold} '/CNNfeatures/' folder '/MOPCNN.mat'];
    path_features = [directorio_im '/' camera{i_fold} '/CNNfeatures/CNNfeatures_' folder '.mat'];
    path_features_PCA = [directorio_im '/' camera{i_fold} '/CNNfeatures/CNNfeaturesPCA_' folder '.mat'];
    root_results = [directorio_results '/' folder];
    mkdir(root_results);
    
    %% Images
    files_aux=dir([fichero '/*' formats{i_fold}]);
    count = 1;
	files = struct('name', []);
    for n_files = 1:length(files_aux)
        if(files_aux(n_files).name(1) ~= '.')
            files(count).name = files_aux(n_files).name;
            count = count+1;
        end
    end
    Nframes=length(files);

    %% Excel
    [clust_man,clustersIdGT,cl_limGT, ~]=analizarExcel_Narrative(path_excel, files);
    delim=cl_limGT';
    if delim(1) == 1, delim=delim(2:end); end
    clust_manId = {};
    for i=1:length(clust_man)
         [a,b]=find(clustersIdGT==i);
         clust_manId{i,1}=b;
    end
      

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
        [~,~,~,fMeasure_Adwin]=Rec_Pre_Acc_Evaluation(delim,automatic2,Nframes,tol);


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
        elseif( strcmp(paramsfeatures.type, 'CNN'))
            similarities=pdist(features_norm,'cosine');
        else
            similarities=pdist(features,'euclidean');          
        end  
        
        for met_indx=1:length(methods_indx)
            
            method=methods_indx{met_indx};  
            
            %% Load Results file if exists
            if(evalType == 2)
                file_save=(['Results_' method '_Res_' clus_type '_' folder '.mat']);
%                 if(exist([root_results '/' file_save]) > 0)
%                     load([root_results '/' file_save]);
%                     offset_results = length(Results);
%                 else
                    offset_results = 0;
%                 end
            end
            

            %% Clustering 
            Z = linkage(similarities, method);

            %% Cut value
            for idx_cut=1:length(cut_indx)

                cut=cut_indx(idx_cut);
                disp(['Start Clustering ' folder ', method ' method ', cutval ' num2str(cut)]);

                clustersId = cluster(Z, 'cutoff', cut, 'criterion', 'distance');

                %% AFTER IDs EXTRACTION - Evaluation
                [JIndex,fMeasure,automatic]=evaluationClustIDs(clustersId,tol,delim,clust_manId,files);

                RPAF_Clustering.clustersIDs = clustersId;
                RPAF_Clustering.fMeasure = fMeasure;
                RPAF_Clustering.JaccardIndex = JIndex;
                
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
                    
                    % Results Evaluation
                    Results{idx_cut+offset_results}.cut_value = cut;
                    Results{idx_cut+offset_results}.RPAF_Clustering = RPAF_Clustering; 
                    Results{idx_cut+offset_results}.num_clus_GC = num_clus_GC;
                    Results{idx_cut+offset_results}.Wunary_tested = W_u_tested;
                    Results{idx_cut+offset_results}.Wpairwise_tested = W_p_tested;
                    Results{idx_cut+offset_results}.eventsIDs = eventsIDs;
                    Results{idx_cut+offset_results}.fMeasure_GC = fMeasure_GC;
                    Results{idx_cut+offset_results}.fMeasure_Clustering = fMeasure;
                    if strcmp(clus_type,'Both1')
                        Results{idx_cut+offset_results}.fMeasure_Adwin = fMeasure_Adwin;
                    end

                elseif(evalType == 1)
                    [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W_pairwise, features_GC, tol, delim, doEvaluation, previousMethods);
                end % end GC

                close all;
             end%end cut


             %% SAVE
             if(evalType == 2)
                save([root_results '/' file_save], 'Results');
             end
             
        end %end method
        clearvars LH_Clus start_clus
    end %end if clustering || both1  
    
    %% Spectral Clustering
    if strcmp(clus_type,'Both2')||strcmp(clus_type,'Spectral')

        %% PCA
        if(paramsPCA.usePCA_Spect && strcmp(paramsfeatures.type, 'CNN') )
            features_Sp = featuresPCA;
        elseif(strcmp(paramsfeatures.type, 'CNN'))
            [features_Sp] = signedRootNormalization(features);
        else
            features_Sp = features;    
        end
    
        for matrix_indx=1:length(sim_matrix)
            SimM=sim_matrix{matrix_indx};

            if strcmp(SimM,'NN')==1,
                sigmaNN=0.5; Type_NN=1;
                Spectral_Param=NN;
                W = SimGraph_NearestNeighbors(features_Sp', NN, Type_NN, sigmaNN);

            elseif strcmp(SimM,'Sigma')==1,
                Spectral_Param=Sig;
                W = SimGraph_Full(features_Sp', Sig);

            elseif strcmp(SimM,'Epsilon')==1,
                Spectral_Param=Eps;
                W = SimGraph_Epsilon(features_Sp', Eps);    

            end

            %%SpectralClust Type
            for Type=1:3
                Results={};
                
                
                %% Load Results file if exists
                if(evalType == 2)
                    file_save=(['Results_'  SimM '_Type_' num2str(Type) '_Parm_' num2str(Spectral_Param) '_' folder '.mat']);
%                     if(exist([root_results '/' file_save]) > 0)
%                         load([root_results '/' file_save]);
%                         offset_results = length(Results);
%                     else
                        offset_results = 0;
%                     end
                end
             
                %%Kvalue
                for k_indx=1:length(k_valuesSp)
                    k_Sp=k_valuesSp(k_indx);

                    disp([folder ' Clusters Id - ' SimM ' k=' num2str(k_Sp) ' Type=' num2str(Type) ' & Val=' num2str(Spectral_Param)])
                    [C, L, U] = SpectralClustering(W, k_Sp, Type);

                    clustersId=[];
                    for num_k=1:k_Sp
                       vect_pos=find(C(:,num_k)==1)'; 
                       clustersId(1,vect_pos)=num_k; 
                    end

                    %% AFTER IDs EXTRACTION - Evaluation
                    [JIndex,fMeasure,automatic]=evaluationClustIDs(clustersId,tol,delim,clust_manId,files);
 
                    RPAF_Spectral.clustersIDs = clustersId;
                    RPAF_Spectral.fMeasure = fMeasure;
                    RPAF_Spectral.JaccardIndex = JIndex;
                    if(strcmp(paramsfeatures.type, 'CNN'))
                        P=getLHFromClustering(features_norm,clustersId);
                    else
                        P=getLHFromClustering(features,clustersId);                   
                    end
                    LH_Clus{1} = P;
                    start_clus{1}=clustersId';
                    bound_GC{1}=automatic;
                    previousMethods{1} = 'Spectral';

                    %% Graph Cut
                    % Build and calculate the Graph-Cuts

                    disp('Start GC');

                    %% PCA
                    if(paramsPCA.usePCA_GC && strcmp(paramsfeatures.type, 'CNN') )
                        features_GC = featuresPCA;
                    elseif(strcmp(paramsfeatures.type, 'CNN'))
                        [features_GC] = signedRootNormalization(features);
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
                                fig_save = ([SimM '_Type_' num2str(Type) '_Parm_' num2str(Spectral_Param) '_k_' num2str(k_Sp) '.fig']);
                            end
                            saveas(fig,[root_results '/' fig_save]);
                        end

                        % Results Evaluation
                        Results{k_indx+offset_results}.Similarity_Matrix = SimM;
                        Results{k_indx+offset_results}.RPAF_Clustering = RPAF_Spectral; 
                        Results{k_indx+offset_results}.Type = Type;
                        Results{k_indx+offset_results}.k_valueSP = k_Sp;
                        Results{k_indx+offset_results}.num_clus_GC = num_clus_GC;
                        Results{k_indx+offset_results}.Wunary_tested = W_u_tested;
                        Results{k_indx+offset_results}.Wpairwise_tested = W_p_tested;
                        Results{k_indx+offset_results}.eventsIDs = eventsIDs;
                        Results{k_indx+offset_results}.fMeasure_GC = fMeasure_GC;
                        Results{k_indx+offset_results}.fMeasure_Clustering = fMeasure;
                        if strcmp(clus_type,'Both2')
                            Results{idx_cut+offset_results}.fMeasure_Adwin = fMeasure_Adwin;
                        end

                    elseif(evalType == 1)
                        [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W_pairwise, features_GC, tol, delim, doEvaluation, previousMethods);
                    end % end GC

                    close all;
                 end%end k value

                 %% SAVE
                 if(evalType == 2)
                    save([root_results '/' file_save], 'Results');
                 end

            end %end Type
        end%similarity matrices
        
    end %end if spectral clustering || both2 
end %end folder


