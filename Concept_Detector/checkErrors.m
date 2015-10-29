
function checkErrors(path_tags, folders, errors_file_path)

    error_files = fopen(errors_file_path, 'w');

    nFolders = length(folders);
    for f = 1:nFolders
        jsons = dir([path_tags '/' folders{f} '/*.json']);
        jsons = jsons(arrayfun(@(x) x.name(1) ~= '.', jsons));
    
        nJsons = length(jsons);
        for j = 1:nJsons
            [~, filename, ~] = fileparts(jsons(j).name);
            t = fileread([path_tags '/' folders{f} '/' jsons(j).name]);
            if(~isempty(regexp(t, '"status": "error"', 'match')))
                fprintf(error_files, [folders{f} ' ' filename '\n']);
            end
        end
    end

    fclose(error_files);
end
