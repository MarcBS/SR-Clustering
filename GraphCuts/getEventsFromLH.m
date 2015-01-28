function [ labels_event, start_event, num_event ] = getEventsFromLH(LH)
    nSamples = size(LH,1);
    [~, classes_clus] = max(LH, [], 2);
    
    % Separation in events
    labels_event = zeros(1, nSamples); labels_event(1) = 1;
    start_event = [];
    prev = 1;
    for i = 1:nSamples
        if(classes_clus(i) == 0)
            labels_event(i) = 0;
        else
            if(classes_clus(i) == classes_clus(prev))
                labels_event(i) = labels_event(prev);
            else
                labels_event(i) = labels_event(prev)+1;
                start_event = [start_event i];
            end
            prev = i;
        end
    end
    num_event = max(labels_event);

end

