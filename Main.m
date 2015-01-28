
%% Loads parameters
loadParameters;


%% Folders
for i_fold=1:length(folders)
    
    %% Paths images and excel
    folder=folders{i_fold};
    fichero=([directorio_im '/' camera{i_fold} '/imageSets/' folder]);
    path_excel = [directorio_im '/' camera{i_fold} '/GT/GT_' folder '.xls'];
    path_features = [directorio_im '/' camera{i_fold} '/CNNfeatures/CNNfeatures_' folder '.mat'];
    
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
                [~,~,~,fMeasure_Ad]=Rec_Pre_Acc_Evaluation(delim,automatic2,Nframes,tol);
                    

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

                            [rec,prec,acc,fMeasure]=Rec_Pre_Acc_Evaluation(delim,automatic,Nframes,tol);


                            RPAF{idx_cut,1}=clustersId;
                            RPAF{idx_cut,2}=bound;
                            RPAF{idx_cut,3}=rec;
                            RPAF{idx_cut,4}=prec;
                            RPAF{idx_cut,5}=acc;
                            RPAF{idx_cut,6}=fMeasure;

                P=getLHFromClustering(features_clus,clustersId);
                LH_Clus{1} = P;
                start_clus{1}=clustersId';
                bound_GC{1}=automatic;
       
    
                %% Graph Cut
                % Build and calculate the Graph-Cuts
                [features_norm, ~, ~] = normalize(features);
                if(evalType == 2)
                    [ fig ,vec_numC,vec_perC,clusterIds ] = doIterativeTest(LH_Clus, start_clus, bound_GC, maxTest, win_len, W, W2, features_norm, tol, delim, clus_type,1);

                    aux_save2=([sfigureGC folder '_' method '_' clus_type '_' num2str(idx_cut) '.fig']);
                    saveas(fig,aux_save2);

                    Results{idx_cut,1}=RPAF; 
                    Results{idx_cut,2}=0;%vec_numC;
                    Results{idx_cut,3}=0;%vec_perC;
                    Results{idx_cut,4}=0;%clusterIds;
                    Results{idx_cut,5}=fMeasure; 
                    Results{idx_cut,6}=0;%fMeasure_Ad;

                elseif(evalType == 1)
                    [ labels, start_GC ] = doSingleTest(LH_Clus, start_clus, bound_GC ,win_len, W, W2, features_norm, tol, delim, doEvaluation, clus_type);
                end % end GC

                close all;
                clearvars bound clustersId
             end%end cut
              
%     sfigure=(['/media/lifelogging/Shared SSD/IBPRIA/Sets/Im_' folder '/']);
%     sfigureRPAF=(['D:\IBPRIA\Sets\GC\GCPrueba_' folder '\']);
%     sfigureGC=(['D:\IBPRIA\Sets\GC\GCPrueba_' folder '\']);
             
             %% SAVE
             aux_save3=([sfigureGC folder '_' method '_Res_' clus_type '_' num2str(idx_cut) '.mat']);
             save(aux_save3,'Results');
             aux_Save=([sfigureRPAF 'RPAF_' folder '_' method]);
             save(aux_Save,'RPAF')
             clearvars Results vec_numC vec_perC clusterIds RPAF
             
        end %end method
        clearvars LH_Clus start_clus
    end %end if clustering || both     
end %end folder


