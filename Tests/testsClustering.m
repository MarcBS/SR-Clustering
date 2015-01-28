clear all, close all
addpath('Code');
addpath('ResultsMainClustering');
addpath('Code/GCMex;Code/GraphCuts');
addpath('Features');addpath('GTruth');
addpath('Code/GCMex;Code/GraphCuts');

% PC MESA
directorio_im='';
    % Save    
    saveResults=('');

folders={'Petia1','Petia2','Mariella','Estefania1','Estefania2','Day1','Day2','Day3','Day4','Day6'};
formats={'.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.JPG','.JPG','.JPG','.JPG','.JPG'};
methods_indx={'ward','centroid','complete','weighted','single','median','average'};
cut_indx=(0.2:0.05:2); 

%Tolerance
tol=5;

%% Clustering
for i_fold=1:length(folders)
    
    % Images
    folder=folders{i_fold};
    fichero=([directorio_im folder]);
    
    files_aux=dir([fichero '/*' formats{i_fold}]);
    count = 1;
    for n_files = 1:length(files_aux)
        if(files_aux(n_files).name(1) ~= '.')
            files(count) = files_aux(n_files);
            count = count+1;
        end
    end
    Nframes=length(files);
    
    % Read GroundTruth - Excel    
    excel_filename=(['GT_' folder '.xls']);
    [clust_man,clustersIdGT,cl_limGT, ~]=analizarExcel_Narrative(excel_filename,files, formats{i_fold});
     delim=cl_limGT';
        if delim(1) == 1, delim=delim(2:end); end
        for i=1:length(clust_man)
             [a,b]=find(clustersIdGT==i);
             clust_manId{i,1}=b;
        end     
        
    % Images Features
	load(['CNNfeatures_' folder '.mat']);
        [features_time] = normalizeL2(features); %sin añadir tiempo
        %PCA FEATURES
        params.minVarPCA=0.95;
        params.standarizePCA=true;
        [ featuresPCA, ~, ~ ] = applyPCA( features_time, params ) ;   
        similarities=pdist(featuresPCA,'cosine');        

    
    % Apply Methods         
    for met_indx=1:length(methods_indx)
        method=methods_indx{met_indx};    
        
        Z = linkage(similarities, method);
                
        % Cut value
        for idx_cut=1:length(cut_indx)
            cut=cut_indx(idx_cut);
            clust_auto_ini = cluster(Z, 'cutoff', cut, 'criterion', 'distance');
            
                        index=1;
                        for pos=1:length(clust_auto_ini)-1
                            if clust_auto_ini(pos)~=clust_auto_ini(pos+1)
                                bound(index)=pos;
                                index=index+1;
                            end
                        end
                        if (exist('bound','var')==0), bound=0; end
                        automatic_aux=bound;
                        if automatic_aux(1) == 1, automatic=automatic_aux(2:end);end
            
            % clust_man & clust_auto = array of cells     
            % LH MATRIX: Allow us to apply the same criteria that we have
            % applied to the FMeasure-> separate consecutive images when
            % they are not with the same identification
            for i=1:max(clust_auto_ini)
                [a,~]=find(clust_auto_ini==i);
                for pos=1:length(a)
                    LH(a(pos),i)=1;
                end
            end 
            [ labels_event, ~, ~ ] = getEventsFromLH(LH);
            %Cluster by identification
            for i=1:max(labels_event)
                [~,b]=find(labels_event==i);
                clust_autoId{i,1}=b;
            end 

            % Assign the original image name
            clust_auto_ImagName=image_assig(clust_autoId,files);
            clust_man_ImagName=image_assig(clust_manId,files);
            
            % Evaluation  
            disp(['Evaluando ' num2str(cut) ' del metodo ' method ' de la carpeta ' folder ])

            [rec,prec,acc,fMeasure]=Rec_Pre_Acc_Evaluation(delim,automatic,Nframes,tol);
            [JImean,JIvar,U,P,long]=JaccardIndex(clust_man_ImagName,clust_auto_ImagName);  
                            
                            %Create Results Array
                            RPAF{idx_cut,1}=clust_auto_ini;
                            RPAF{idx_cut,2}=fMeasure;
                            
                            RPAF{idx_cut,3}=rec;
                            RPAF{idx_cut,4}=prec;
                            RPAF{idx_cut,5}=acc;
                            
                            RPAF{idx_cut,6}=JImean;
                            RPAF{idx_cut,7}=JIvar;
                            RPAF{idx_cut,8}=long;
                            RPAF{idx_cut,9}=length(clust_auto_ImagName);
                            
            clearvars bound clustersId long automatic_aux automatic
        end%end cut             
             % SAVE Results
             disp(['Guardamos ' method ' de la carpeta ' folder ])
             aux_Save=([saveResults 'RPAF_' folder '_' method]);
             save(aux_Save,'RPAF')
    end %end method
    clearvars similarities files delim 
end %end folder


