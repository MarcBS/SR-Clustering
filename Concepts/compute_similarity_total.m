function s = compute_similarity_total(similarities_global,similarities_concepts)
%this is for a pair of images
alpha = 0.5;
s = zeros(size(similarities_global));
%for all objects that are contained in all, compute the similarity
for i=1:length(similarities_global)%for each object i in image 1          
        s(i)   = (1-alpha)*similarities_global(i) + alpha*similarities_global(i);  
  
end
end
