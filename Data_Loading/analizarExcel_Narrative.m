function [events,clustersId,cl_limGT,sum]=analizarExcel_Narrative(excelfile, files_images)
% Numero/Nombre de las imagenes con las que estamos trabajando

    % Check if using filename version 1 or version 2
    name = regexp(files_images(1).name, '_', 'split');
    if length(name) == 3
        v = 2;
    elseif length(name) == 1
        v = 1;
    else
        error('The filenames of the images are not a valid file name.')
    end

    m = 1;
    for i=1:(length(files_images))
        filenumber=strread(files_images(i).name,'%s','delimiter','.');
        if v == 1
            filenumber=str2double(filenumber{1});
        elseif v == 2
            filenumber = regexp(filenumber{1}, '_', 'split');
            filenumber = str2double(filenumber{2});
        end
        if (isempty(filenumber)==0)
            array(m) = filenumber;
            m = m+1;
        end
    end

    %%% Read GT file segments
    [~,~,format] = fileparts(excelfile);

    if(strcmp(format, '.xls') || strcmp(format, '.xlsx'))
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
        eString=strtrim(eventsString{i,1});
        if v == 1
            if(~isempty(findstr(eString, '-')))
                a = regexp(eString, '-', 'split');
            elseif(~isempty(findstr(eString, ',')))
                a = regexp(eString, ',', 'split');
            elseif(~isempty(findstr(eString, ' ')))
                a = regexp(eString, ' ', 'split');
            else
                error(['Incorrect init-final images separator used in line ' eString])
            end
            a = str2double(a);
        elseif v == 2
            if(~isempty(findstr(eString, '-')))
                a = regexp(eString, '-', 'split');
            elseif(~isempty(findstr(eString, ',')))
                a = regexp(eString, ',', 'split');
            elseif(~isempty(findstr(eString, ' ')))
                a = regexp(eString, ' ', 'split');
            else
                error(['Incorrect init-final images separator used in line ' eString])
            end
            a1 = regexp(a{1}, '_', 'split');
            a2 = regexp(a{2}, '_', 'split');
            a = [str2double(a1{2}) str2double(a2{2})];
        end
        p=1;

        % Buscamos si hay coincidencia en la carpeta de imagenes
        try
            for j=a(1):1:a(2)
                if(find(array==j)>0)
                    aux_Eve2(1,p)=j;
                    p=p+1;
                end
            end
            events{i,1}=aux_Eve2;
            clearvars aux_Eve2 a
        catch
            disp(a);
            error(['Error found on the shown line.']);
        end
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
