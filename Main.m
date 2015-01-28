
%% Loads parameters
loadParameters;


%% Folders
for i_fold=1:length(folders)
    
    %% Build paths for images, excel, features and results
    folder=folders{i_fold};
    fichero=([directorio_im '/' camera{i_fold} '/imageSets/' folder]);
    path_excel = [directorio_im '/' camera{i_fold} '/GT/GT_' folder '.xls'];
    path_features = [directorio_im '/' camera{i_fold} '/CNNfeatures/CNNfeatures_' folder '.mat'];
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
    
    
    %% Methods
    if strcmp(clus_type,'Both')||strcmp(clus_type,'Clustering')
            
            LH_Clus={};
            start_clus={};
            
            %% ADWIN
            if strcmp(clus_type,'Both')%||strcmp(clus_type,'Adwin')
                
                [labels,dist2mean] = runAdwin(features, confidence, pnorm, folder);                
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
           
            % Features
            [features_clus] = normalizeL2(features);
            %PCA FEATURES
            [ featuresPCA, ~, ~ ] = applyPCA( features_clus, paramsPCA ) ;   
            similarities=pdist(featuresPCA,'cosine');
           
           
            for met_indx=1:length(methods_indx)
                
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

                            [rec,prec,acc,fMeasure_Clus]=Rec_Pre_Acc_Evaluation(delim,automatic,Nframes,tol);


                            RPAF_Clustering{idx_cut,1}=clustersId;
                            RPAF_Clustering{idx_cut,2}=bound;
                            RPAF_Clustering{idx_cut,3}=rec;
                            RPAF_Clustering{idx_cut,4}=prec;
                            RPAF_Clustering{idx_cut,5}=acc;
                            RPAF_Clustering{idx_cut,6}=fMeasure_Clus;

                P=getLHFromClustering(features_clus,clustersId);
                LH_Clus{1} = P;
                start_clus{1}=clustersId';
                bound_GC{1}=automatic;
       
    
                %% Graph Cut
                % Build and calculate the Graph-Cuts
                [features_norm, ~, ~] = normalize(features);
                if(evalType == 2)
                    [ fig , num_clus_GC, fMeasure_GC, eventsIDs ] = doIterativeTest(LH_Clus, start_clus, bound_GC, nTestsGrid, window_len, W_unary, W_pairwise, features_norm, tol, delim, clus_type,1, nPairwiseDivisions);

                    %% Store results
                    % Plot
                    fig_save = ([method '_cutVal_' num2str(cut_indx(idx_cut)) '.fig']);
                    saveas(fig,[root_results '/' fig_save]);
                    % Results Evaluation
                    Results{idx_cut}.cut_value = cut_indx(idx_cut);
                    Results{idx_cut}.RPAF_Clustering = RPAF_Clustering; 
                    Results{idx_cut}.num_clus_GC = num_clus_GC;
                    Results{idx_cut}.eventsIDs = eventsIDs;
                    Results{idx_cut}.fMeasure_GC = fMeasure_GC;
                    Results{idx_cut}.fMeasure_Clustering = fMeasure_Clus;
                    if strcmp(clus_type,'Both')
                        Results{idx_cut}.fMeasure_Adwin = fMeasure_Adwin;
                    end

                elseif(evalType == 1)
                    [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,window_len, W_unary, W2, features_norm, tol, delim, doEvaluation, clus_type);
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


