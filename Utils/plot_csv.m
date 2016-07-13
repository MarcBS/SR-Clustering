

im_list = [105 112 137 141 62 90];
for im = im_list
    im = num2str(im);

    path_result = ['/media/My_Book/Datos_Lifelogging/Narrative/Nick_Florida/GT _segments/presegmentation_' im '.csv'];
    folder = ['/media/My_Book/Datos_Lifelogging/Narrative/Nick_Florida/Full_folders/' im '_full_Crop'];
    im_name = ['~/Desktop/' im '.jpg'];

    res = fileread(path_result);
    res = regexp(res,'\n', 'split');
    res = {res{1:end-1}};
    for i = 1:length(res)
        res{i} = regexp(res{i}, ',', 'split');
    end
    
    res_ids = {};
    count = 1; 
    for i = 1:length(res)      
        res_ids{i} = count:(length(res{i})-1+count);
        count = count+(length(res{i})-1);           
    end

    count = 1;
    files = struct();
    for i = 1:length(res)
        for j = 2:length(res{i})
            files(count).name = res{i}{j};
            count = count+1;
        end
    end

    im = summaryImage([50 50], length(res), 30, res_ids, files, folder, 'images', '', [], [], []); 
    imwrite(im, im_name);
    
    disp(['finished folder ' im]);
end

