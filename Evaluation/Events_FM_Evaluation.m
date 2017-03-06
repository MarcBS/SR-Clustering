function [ FM , U ] = Events_FM_Evaluation( GT_ids , cluster_ids , Nframes )
%EVENTS_FM_EVALUATION Summary of this function goes here
%the inputs are vectors whose elements are the ids per images
%Nframes is the total number of frames, needed for computing the true negatives

% Examples
% GT_ids=[1 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4];
% cluster_ids=[1 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4];
% cluster_ids=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% cluster_ids=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]
% Nframes=18;

%% F - MEASURE
%initialization
TN = 0;
FP = 0;
FN = 0;

for clust_id=1:max(cluster_ids)

    % posiciones que pertenecen al cluster numero clust_id del clustering
    [~,auto_event]=find(cluster_ids==clust_id);
        
    %matrix N events by 4 (TP-TN-FP-FN)
    for man_ind = 1:max(GT_ids)
             
        [~,manual_event] = find(GT_ids==man_ind);

        % TP: images shared by the GT and the event
        TP_aux = 0;
        for j=1:length(manual_event)
               if find( auto_event == manual_event(j) )
                   TP_aux = TP_aux + 1;
               end
        end
        TP(clust_id,man_ind) = TP_aux;
        FP(clust_id,man_ind) = length(auto_event) - TP_aux; % FP: Event - TP
        FN(clust_id,man_ind) = length(manual_event) - TP_aux; % FN: GT-TP
        %compute TN (correctly rejected): number of not boundaries (Nframes - size(GT,2)), less the number of false positive
        TN(clust_id,man_ind) = Nframes - FN(clust_id,man_ind) - FP(clust_id,man_ind) - TP_aux;
        
    end%end gt ids  
end%end clust ids
        
FM_auxmatrix = (2*TP)./((FP+FN)+2*TP);
FM_max       = max(FM_auxmatrix,[],2);
FM           = mean(FM_max);

%% U MEASURE Relation between the number of automac vs manual events founded
U= max(cluster_ids) / max(GT_ids);
    
%%%%% ------ 
%
% TP: images shared by the GT and the event
% FN: GT-TP
% FP: Event - TP
% TN: Nframes-FN-TP-FP