function [JImean,JIvar,U,P,long]=JaccardIndex(clust_man_ImagName,clust_auto_ImagName)


	% Number of clusters 
    events_result=length(clust_auto_ImagName); %Result of automatic segmentation
    events_ground_truth=length(clust_man_ImagName); % Reference segmentation
    
    %% JD : Computing the similarity between the two segmentations, the
    % automatic and ground truth.
    
    for i_m=1:length(clust_man_ImagName)
        for i_a=1:length(clust_auto_ImagName)
            intersec=0;
            %Union = contador con numero de imagenes compartidas
            for j=1:length(clust_man_ImagName{i_m})
               if find(clust_auto_ImagName{i_a}==clust_man_ImagName{i_m}(j))
                intersec=intersec+1;
               end
            end
            %cont_aux(i_m,i_a)=cont;
            
            %union          
            union=length(clust_man_ImagName{i_m})+length(clust_auto_ImagName{i_a})-intersec; 
            
            %JI=union/interseccion
            JI(i_m,i_a)=intersec/union;
            
            clearvars max1_length max2_length interseccion
        end
    end

        for i=1:size(JI,1)
            JImax(i,1)=max(JI(i,:));
        end

        long(1)=length(find(JImax>0.20));long(2)=length(find(JImax>0.30));
        long(3)=length(find(JImax>0.40));long(4)=length(find(JImax>0.50));
        long(5)=length(find(JImax>0.60));long(6)=length(find(JImax>0.70));
        long(7)=length(find(JImax>0.80));long(8)=length(find(JImax>0.90));
        JImean  = mean(JImax);
        JIvar   = std(JImax);
    % U : Reflecting how well events are recovered without being broken into
    % several events or wrongly merged. Is a ratio of the number of events in
    % the result and in the ground truth.

        U = events_result/events_ground_truth;

    % P : The purity of the story reflecting whether identified events are
    % correct, is defined as the ratio of segments of clust_auto correctly
    % identified in events of the ground truth.

        num=length(find(JImax>0.50));

        P=num/events_result;  
 