function s = compute_distance_adwin(CNN1,CNN2,objects1,objects2)
%this is for a pair of images


n = 0;
s=0;
p=norm(CNN1-CNN2);%penalization
%for all objects that are contained in the image, compute the similarity
for i=1:size(objects2,1)%for each object i
                if  min(objects1(i,:))~=max(objects1(i,:)) & min(objects2(i,:))~=max(objects2(i,:))
                    n=n+1;
                    s = s + norm( objects1(i,:)-objects2(i,:)  );
                end
                    
end
%we assume that the norm of the difference between the global features is always larger that the norm of the difference between objects that belong to the same class, so we use p as penalization term 
if n==0 
    s = p +  norm(CNN1-CNN2);%no objects in common-> big penalization
else

    s = s/n + norm(CNN1-CNN2);%objects in common -> reduce the penalization: more similar are the objects in common, smaller will be s/n and less 
end

%s/n
%norm(CNN1-CNN2)




end
