

addpath('../Features_Preprocessing');


%% Parameters
path_dest = '/media/lifelogging/HDD_2TB/LIFELOG_DATASETS';
folders = {'Petia1', 'Petia2', 'Mariella', 'Estefania1', 'Estefania2'};
cameras = {'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative'}; 
versions = [1, 2, 3];   % 1 --> only pick max scoring class per detection
                        % 2 --> pick all scores > 0 per detection
                        % 3 --> sum of scores greater than 0

path_src = '/media/lifelogging/HDD_2TB/LSDA/Test_Output_AllClasses';

doplot = false;

% top_plots = {'all', 50, 20, 10};
top_plots = {50,10};
                
                
nFolders = length(folders);
for i = 1:nFolders
    if(~exist([path_dest '/' cameras{i} '/LSDAfeatures']))
        mkdir([path_dest '/' cameras{i} '/LSDAfeatures']);
    end
    for v = versions
        disp(['Extracting features version ' num2str(v) ' for dataset ' folders{i} '...']);
        extractLSDAFeatures( path_src, ['results_' folders{i} '.mat'], [path_dest '/' cameras{i} '/LSDAfeatures'], v, doplot, top_plots );
    end
end

disp('Done');
exit;
