function [events,clustersId,cl_limGT,sum]=analizarExcel_Narrative(excelfile, files_images)

    % Numero/Nombre de las imagenes con las que estamos trabajando
    m=1;
    for i=1:(length(files_images))
        filenumber=strread(files_images(i).name,'%s','delimiter','.');
        filename{i,1}=filenumber{1};        
        aux2=str2num(filenumber{1});
        if (isempty(aux2)==0)
            array(m)= str2num(filenumber{1});
            m=m+1;
        end
    end
  
    [~,textA] = xlsread(excelfile);
    [f,c]=size(textA);
    eventsString=textA(3:f,2);
    
    num_clustauto_def=f-2;
    
    for i=1:num_clustauto_def
        eString=eventsString{i,1};
        a=str2num(eString);
        p=1;
       
        %Buscamos si hay coincidencia en la carpeta de imagenes
        for j=a(1):1:a(2)
            if(find(array==j)>0)
                aux_Eve2(1,p)=j;
                p=p+1;
            end
        end
        events{i,1}=aux_Eve2;
        clearvars aux_Eve2 a
    end

    %Generar array Ids
    clustersId=zeros(1,length(array));
    pos=0;
    for i=1:num_clustauto_def
        clust_length=length(events{i,1});
        clustersId(1,pos+1:(pos+clust_length))=i;
        pos=pos+clust_length;
    end

        %Generar límites F-Measure
        cl_limGT = zeros(size(events,1),1);
        cl_limGT(1)=1;
        for i=1:(size(events,1)-1)
               cl_limGT(i+1) =  cl_limGT(i) + size(events{i},2);    
        end       
        
        %Comprobar que lee todas las imágenes
         sum=0;
         for i=1:length(events)
             sum=sum+ size(events{i},2);
         end
  
end