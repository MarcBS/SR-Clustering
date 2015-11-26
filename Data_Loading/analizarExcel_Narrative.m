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

%%% Read GT file segments
[~,~,format] = fileparts(excelfile);

if(strcmp(format, '.xls'))
	[~,textA] = xlsread(excelfile);
	[f,c]=size(textA);
	eventsString = textA(2:f,2);
	eventsString = eventsString(arrayfun(@(x) ~strcmp(x,''),eventsString));
elseif(strcmp(format, '.csv') || strcmp(format, '.txt'))
	textA = fileread(excelfile);
	eventsString = regexp(textA, '\n', 'split');
	eventsString = regexprep(eventsString, ',', ' ');
	if(isempty(eventsString{end}))
		eventsString = {eventsString{1:end-1}};
	end
	eventsString = eventsString';
else
	error('Incorrect GT file format. Only .csv, .txt or .xls are valid formats.');
end
num_clustauto_def=length(eventsString);



for i=1:num_clustauto_def
eString=eventsString{i,1};
a=str2num(eString);
p=1;
% %Buscamos si hay coincidencia en la carpeta de imagenes
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
cl_limGT(i+1) = cl_limGT(i) + size(events{i},2);
end
%Comprobar que lee todas las imágenes
sum=0;
for i=1:length(events)
sum=sum+ size(events{i},2);
end
end

   
