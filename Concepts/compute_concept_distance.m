function s = compute_concept_distance(CNN1,CNN2,objects1,objects2)
%this is for a pair of images

delta = 1;


n = 0;
s=0;


%for i=1:size(objects2,1)%for each object i
%                n=n+1;
%                %exp(   -norm( objects1(i,:)-objects2(i,:)  )/sigma   ) 
%                s = s + weight*exp(   -norm( objects1(i,:)-objects2(i,:) )/sigma   );
%end


%for all objects that are contained in all, compute the similarity
for i=1:length(objects2)%for each object i in image 1
    if ~isempty(objects1{i})%if object i is not empty
        for j=1:size(objects1{i},1)%for each instances of object i 
                if  ~isempty(objects2{i})%if object i is not empty   in image 2       
                    for k=1:size(objects2{i},1)%for each instances of object i in image 2
                        n=n+1;
                        %i
                        %a = sumcum(objects1{i});
                        %obj1 = a(end,:)/size(a,1);
                        %b = sumcum(objects2{k});
                        %obj2 = b(end,:)/size(b,1); 
                        %exp(-norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2*norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2)           
                        %s = s + weight*exp(-norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2*norm(objects1{i}(j,:)-objects2{i}(k,:))/sigma2);
                        s = s + norm(objects1{i}(j,:)-objects2{i}(k,:));
                    end
                end
        end      
    end
end
if n==0
s = norm(CNN1-CNN2);%la distancia debe aumentar, le anado un termino de penalizacion (no le anado nada)-> similaridad màs pequena
else
s = abs(-s/n + norm(CNN1-CNN2));%la distancia debe disminuir, le subtrayo el termino que viene de los objetos en comun 
end
end
