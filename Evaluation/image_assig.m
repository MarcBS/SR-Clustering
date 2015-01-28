function clust_auto_ImagName=image_assig(cluster_agrupados,files)



for l=1:length(cluster_agrupados)
    a=cluster_agrupados(l);
    for p=1:length(a{1})       
        filenumber=strread(files(a{1}(p)).name,'%s','delimiter','.');
        number=str2num(filenumber{1});
        clust_auto_ImagName{l,1}(p)=number;
        
    end
end


