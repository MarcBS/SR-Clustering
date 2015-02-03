
%% Loads parameters
loadParameters;


%% Folders
for i_fold=1:length(folders)
    
    %% Build paths for images, excel, features and results
    folder=folders{i_fold};
    fichero=([directorio_im '/' camera{i_fold} '/imageSets/' folder]);
    path_excel = [directorio_im '/' camera{i_fold} '/GT/GT_' folder '.xls'];
    path_features = [directorio_im '/' camera{i_fold} '/CNNfeatures/CNNfeatures_' folder '.mat'];
    path_features_PCA = [directorio_im '/' camera{i_fold} '/CNNfeatures/CNNfeaturesPCA_' folder '.mat'];
    root_results = [directorio_results '/' folder];
    mkdir(root_results);
    
    %% Images
    files_aux=dir([fichero '/*' formats{i_fold}]);
    count = 1;
    for n_files = 1:length(files_aux)
        if(files_aux(n_files).name(1) ~= '.')
            files(count) = files_aux(n_files);
            count = count+1;
        end
    end
    Nframes=length(files);

    %% Excel
    [clust_man,clustersIdGT,cl_limGT, ~]=analizarExcel_Narrative(path_excel, files);
    delim=cl_limGT';
    if delim(1) == 1, delim=delim(2:end); end
    for i=1:length(clust_man)
         [a,b]=find(clustersIdGT==i);
         clust_manId{i,1}=b;
    end     
      

    %% Features
	load(path_features);
    
    % Features
    [features_norm] = signedRootNormalization(features);

    %PCA FEATURES
    if(exist(path_features_PCA) > 0)
        load(path_features_PCA);
    else
        [ featuresPCA, ~, ~ ] = applyPCA( features_norm, paramsPCA ) ; 
        save(path_features_PCA, 'featuresPCA');
    end
    
    %% Methods
    if strcmp(clus_type,'Both')||strcmp(clus_type,'Clustering')
            
            LH_Clus={};
            start_clus={};
            
            %% ADWIN
            if strcmp(clus_type,'Both')%||strcmp(clus_type,'Adwin')
                
                %% PCA
                if(paramsPCA.usePCA_Adwin)
                    [labels,dist2mean] = runAdwin(featuresPCA, confidence, pnorm); 
                else
                    [labels,dist2mean] = runAdwin(features_norm, confidence, pnorm); 
                end
          
                index=1;
                for pos=1:length(labels)-1
                    if labels(pos)~=labels(pos+1)
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

                bound_GC{2}=automatic2;
                LH_Clus{2}=getLHFromDists(dist2mean);
                start_clus{2}=labels;
            end % end Adwin
            
            
        %% Clustering

        for met_indx=1:length(methods_indx)
            
            %% PCA
            if(paramsPCA.usePCA_Clustering)
                similarities=pdist(featuresPCA,'cosine');
            else
                similarities=pdist(features_norm,'cosine');
            end
            
            %% Clustering
            method=methods_indx{met_indx};    
            Z = linkage(similarities, method);

            %% Cut value
            for idx_cut=1:length(cut_indx)

                cut=cut_indx(idx_cut);
                clustersId = cluster(Z, 'cutoff', cut, 'criterion', 'distance');

                index=1;
                for pos=1:length(clustersId)-1
                    if clustersId(pos)~=clustersId(pos+1)
                        bound(index)=pos;
                        index=index+1;
                    end
                end
                if (exist('bound','var')==0)
                    bound=0;
                end

                automatic=bound;
                if automatic(1) == 1
                    automatic=automatic(2:end);
                end
            
                % clust_man & clust_auto = array of cells     
                % LH MATRIX: Nos permite aplicar el mismo criterio que hemos
                % aplicado con FMeasuer-> separar cuando imagenes consecutivas
                % con coinciden
                for i_cl=1:max(clustersId)
                    [val_pos,~]=find(clustersId==i_cl);
                    for pos_LH=1:length(val_pos)
                        LH(val_pos(pos_LH),i_cl)=1;
                    end
                end 
                [ labels_event, ~, ~ ] = getEventsFromLH(LH);
                %Agrupamos por etiqueta
                for i_lab=1:max(labels_event)
                    [~,b]=find(labels_event==i_lab);
                    clust_autoId{i_lab,1}=b;
                end 

                % Asignar el nombre de la imagen
                clust_auto_ImagName=image_assig(clust_autoId,files);
                clust_man_ImagName=image_assig(clust_manId,files);
                
                [rec,prec,acc,fMeasure_Clus]=Rec_Pre_Acc_Evaluation(delim,automatic,Nframes,tol);
                [JaccardIndex,JaccardVar,~,~,~]=JaccardIndex(clust_man_ImagName,clust_auto_ImagName);  

                RPAF_Clustering.clustersIDs = clustersId;
                RPAF_Clustering.boundaries = bound;
                RPAF_Clustering.recall = rec;
                RPAF_Clustering.precision = prec;
                RPAF_Clustering.accuracy = acc;
                RPAF_Clustering.fMeasure = fMeasure_Clus;
                RPAF_Clustering.JaccardIndex = JaccardIndex;
                RPAF_Clustering.JaccardVariance = JaccardVar;               
                RPAF_Clustering.NumClusters = length(clust_auto_ImagName);
                
                
                P=getLHFromClustering(features_norm,clustersId);
                LH_Clus{1} = P;
                start_clus{1}=clustersId';
                bound_GC{1}=automatic;


                %% Graph Cut
                % Build and calculate the Graph-Cuts
                
                %% PCA
                if(paramsPCA.usePCA_GC)
                    features_GC = featuresPCA;
                else
                    features_GC = features;
                end
                
                [features_GC, ~, ~] = normalize(features_GC);
                if(evalType == 2)
                    [ fig , num_clus_GC, fMeasure_GC, eventsIDs, W_u_tested, W_p_tested ] = doIterativeTest(LH_Clus, start_clus, bound_GC, nTestsGrid, window_len, W_unary, W_pairwise, features_GC, tol, delim, clus_type,1, nPairwiseDivisions);

                    %% Store results
                    
                    % Plot
                    fig_save = ([method '_cutVal_' num2str(cut) '.fig']);
                    saveas(fig,[root_results '/' fig_save]);
                    
                    % Results Evaluation
                    Results{idx_cut}.cut_value = cut;
                    Results{idx_cut}.RPAF_Clustering = RPAF_Clustering; 
                    Results{idx_cut}.num_clus_GC = num_clus_GC;
                    Results{idx_cut}.Wunary_tested = W_u_tested;
                    Results{idx_cut}.Wpairwise_tested = W_p_tested;
                    Results{idx_cut}.eventsIDs = eventsIDs;
                    Results{idx_cut}.fMeasure_GC = fMeasure_GC;
                    Results{idx_cut}.fMeasure_Clustering = fMeasure_Clus;
                    if strcmp(clus_type,'Both')
                        Results{idx_cut}.fMeasure_Adwin = fMeasure_Adwin;
                    end

                elseif(evalType == 1)
                    [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W2, features_GC, tol, delim, doEvaluation, clus_type);
                end % end GC

                close all;
                clearvars bound clustersId
             end%end cut


             %% SAVE
             if(evalType == 2)
                file_save=(['Results_' method '_Res_' clus_type '.mat']);
                save([root_results '/' file_save], 'Results');
             end
             
        end %end method
        clearvars LH_Clus start_clus
    end %end if clustering || both     
end %end folder


