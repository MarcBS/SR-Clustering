function [JaccardIndex_result,fMeasure_Clus,automatic]=evaluationClustIDs(clustersId,tol,delim,clust_manId,files)

Nframes=length(files);
bound = [];
                    index=1;
                    for pos=1:length(clustersId)-1
                        if (clustersId(pos)~=clustersId(pos+1))>0
                            bound(index)=pos;
                            index=index+1;
                        end
                    end
                    if (isempty(bound)==1)
                        bound=0;
                        automatic=bound;
                    else
                        automatic=bound;
                        if automatic(1) == 1
                            automatic=automatic(2:end);
                        end
                    end

                    % clust_man & clust_auto = array of cells     
                    % LH MATRIX: Nos permite aplicar el mismo criterio que hemos
                    % aplicado con FMeasuer-> separar cuando imagenes consecutivas
                    % con coinciden
                    LH=[]; clust_autoId=[];
                    for i_cl=1:max(clustersId)
                        [~,val_pos]=find(clustersId==i_cl);
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
                    [JaccardIndex_result,JaccardVar,~,~,~]=JaccardIndex(clust_man_ImagName,clust_auto_ImagName); 