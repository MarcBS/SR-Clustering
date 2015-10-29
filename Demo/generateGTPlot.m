
addpath('../Data_Loading;..;../Tests;../Features_Extraction');

path_GT = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/Narrative/GT';
folders = {'Maya1', 'Marc1', 'MAngeles1', 'MAngeles2', 'MAngeles3'};
path_images = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS/Narrative/imageSets';

props = [50 50];

nFolders = length(folders);
for f = 1:nFolders
    
    path_excel = [path_GT '/GT_' folders{f} '.xls'];
    fichero = [path_images '/' folders{f}];
    
    %% Images
    files_aux=dir([fichero '/*.jpg']);
    count = 1;
	files = struct('name', []);
    for n_files = 1:length(files_aux)
        if(files_aux(n_files).name(1) ~= '.')
            files(count).name = files_aux(n_files).name;
            count = count+1;
        end
    end
    Nframes=length(files);

    %% Excel
    [clust_man,clustersIdGT,cl_limGT, ~]=analizarExcel_Narrative(path_excel, files);
   
     
    clustIDs = {};
    off = 0;
    for i = 1:length(clust_man)
        clustIDs{i} = off+1:off+length(clust_man{i});
        off = off+length(clust_man{i});
    end
    
                disp('Starting plot whole summary image...');
                    gen_image = summaryImage(props, length(clust_man), 30, clustIDs, files, fichero, 'images', '', []);
                    imwrite(gen_image, ['GTmosaic_' folders{f} '.jpg']);
end
disp('Done');
exit
