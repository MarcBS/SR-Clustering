directorio_im = '/media/HDD_3TB/DATASETS/EDUB-Seg/Narrative/imageSets';
format = 'jpg';

folders = {'Pedro4', 'Estefania5', 'Marc2', 'Marc3', 'Marc4', 'MarcC1', ...
        'Pedro1', 'Pedro2', 'Pedro3', 'Maya1', 'Maya2', 'Maya3', 'Marc1', ...
        'Estefania3', 'Estefania4', 'Estefania1', 'Estefania2', 'Petia1', 'Petia2', 'Mariella'};
        
        
c = 0;
for f = folders
    imgs = dir([directorio_im '/' f{1} '/*.' format]);
    imgs = imgs(arrayfun(@(x) x.name(1) ~= '.', imgs));
    c = c+length(imgs);
end

disp(['Total images count: ' num2str(c)]);