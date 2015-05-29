function X = compute_word_document_matrix_unlabeled_concepts(path2concepts)
%each column is an image vector made of words

X = [];
%i=5
        files_folder =dir();
        for i=1:length(files_folder)
            if ~isempty(strfind(files_folder(i).name,'feat_concepts'))
                load([path2concepts  files_folder(i).name]);
                %find indices of not empty entries
                ind = find(~cellfun(@isempty,feat_concepts));
                %size(feat_concepts)
                x = zeros(size(feat_concepts,2),1);
                for j=1:length(ind)
                    x(ind(j)) = size(feat_concepts{ind(j)},1);
                end
                X = [X;x'];
            end
        end      
   


end
