function h = LSH_adwin(feature_concepts_adwin)
    h = zeros(size(feature_concepts_adwin,1),128,size(feature_concepts_adwin,3));
    for i=1:size(feature_concepts_adwin,3)
        h(:,:,i) = LSH(feature_concepts_adwin(:,:,i));
    end

end
