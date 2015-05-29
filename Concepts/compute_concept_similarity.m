function s = compute_concept_similarity(CNN1,CNN2,objects1,objects2)
%this is for a pair of images
n = 0;
s=0;


%for all objects that are contained in all, compute the similarity
for i=1:length(objects2)%for each object i in image 1
    if ~isempty(objects1{i})%if object i is not empty
        for j=1:size(objects1{i},1)%for each instances of object i 
                if  ~isempty(objects2{i})%if object i is not empty   in image 2       
                    for k=1:size(objects2{i},1)%for each instances of object i in image 2
                        n=n+1;
                        obj1 = normalizeL2(objects1{i}(j,:));
                        obj2 = normalizeL2(objects2{i}(k,:));
                        %i
                        %a = sumcum(objects1{i});
                        %obj1 = a(end,:)/size(a,1);
                        %b = sumcum(objects2{k});
                        %obj2 = b(end,:)/size(b,1); 
                        %exp(-norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2*norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2)           
                        %s = s + weight*exp(-norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2*norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2);
                        s = s + 1 - dot(obj1,obj2)/(norm(obj1)*norm(obj2));
                    end
                end
        end      
    end
end
global_dists =  1 - dot(CNN1,CNN2)/(norm(CNN1)*norm(CNN2));
if n==0
% s = 1./(global_dists+1);
 
s = global_dists;%la distancia debe aumentar, le anado un termino de penalizacion (no le anado nada)-> similaridad màs pequena
else
 %s = 1./(global_dists - s/n +1);
s = -s/n + global_dists;%la distancia debe disminuir, le subtrayo el termino que viene de los objetos en comun 
end
end
