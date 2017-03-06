%% Plot timeline of EDUB-Seg data
function main()

    addpath('Data_Loading');

    path_data = '/media/HDD_2TB/DATASETS/EDUB-Seg/Narrative/imageSets';
    datasets = {'Marc3'; 'Estefania1'; 'Estefania2'; 'Petia1'; 'Petia2'; 'Mariella'; ...
        'Estefania3'; 'Maya1'; 'Maya2'; 'Maya3'; 'Marc1';...
        'Estefania4'; 'Estefania5';'Marc2'; ...
        'Marc3'; 'Marc4'; 'MarcC1';...
        'Pedro1'; 'Pedro2'; 'Pedro3'; 'Pedro4'};

    path_gt = '/media/HDD_2TB/DATASETS/EDUB-Seg/Narrative/GT';

    % path_data = '/media/My_Book/Datos_Lifelogging/Narrative/Pedro/2016/08';
    % datasets = {'05', '06', '07', '08', '09'};

    format = 'jpg';

    sets_separation = 1;
    plot_hours = {'06:00'; '08:00'; '10:00'; '12:00'; '14:00'; '16:00'; '18:00'; '20:00'; '22:00'};

    path_results = './';

    max_distance_allowed = 600;  % in seconds


    %%%%%%%%%%%%%%%%%%

    figure1 = figure;
    n_datasets = length(datasets);
    for i = 1:n_datasets

        % List files in each directory
        dat = datasets{i};
        files = dir([path_data '/' dat '/*.' format]);
        files = files(arrayfun(@(x) x.name(1) ~= '.', files));
        n_files = length(files);

        % Get timestamps from file name
        timestamps = zeros(n_files,1);
        for j = 1:n_files
            name = getTimeFromName(files(j).name);

            % Convert timestamps to seconds
            timestamps(j) = timeToSeconds(name);
        end

        % Plot timeline
        scatter(timestamps, ones(n_files,1)*i*sets_separation, 'filled');
        hold on;

    end

    % Transform plot hours into seconds (figure coordinates)
    n_plot_hours = length(plot_hours);
    transformed_plot_hours = zeros(n_plot_hours, 1);
    for i = 1:n_plot_hours
        h = plot_hours{i};
        h = regexp(h, ':', 'split');
        time = str2num(h{1})*60*60 + str2num(h{2})*60;
        transformed_plot_hours(i) = time;
    end


    % Plot tick labels and store figure
    set(gca, 'Xtick', transformed_plot_hours, 'XtickLabel', plot_hours);
    set(gca, 'Ytick', [1:n_datasets]*sets_separation, 'YtickLabel', datasets);
    xlabel('Time of the day','FontSize',12);
    ylim([0,(n_datasets+1)*sets_separation]);
    set(gca,'FontSize',12);

    saveas(figure1, 'timeline_EDUB-Seg.jpg');


    %%%%%%%%%%%%%%%%%%

    % Calculate some data statistics
    time_length = zeros(1,n_datasets);
    num_segments = zeros(1, n_datasets);
    segm_length = cell(1, n_datasets);
    num_segments_gt = zeros(1, n_datasets);

    for i = 1:n_datasets

        segm_length{i} = [];

        % List files in each directory
        dat = datasets{i};
        files = dir([path_data '/' dat '/*.' format]);
        files = files(arrayfun(@(x) x.name(1) ~= '.', files));
        n_files = length(files);

        name_ini = getTimeFromName(files(1).name);
        name_fin = getTimeFromName(files(n_files).name);

        % Convert timestamps to seconds and calculate day length
        time_ini = timeToSeconds(name_ini);
        time_fin = timeToSeconds(name_fin);
        time_length(i) = time_fin-time_ini;


        % Get number and duration of artificially created segments in recorded data
        prev_time = time_ini;
        last_segment_time = time_ini;
        for j = 2:n_files
            name = getTimeFromName(files(j).name);
            time = timeToSeconds(name);
            if time - prev_time > max_distance_allowed
                num_segments(i) = num_segments(i) +1;
                segm_length{i} = [segm_length{i}, time - last_segment_time];
                last_segment_time = time;
            end
            prev_time = time;
        end
        num_segments(i) = num_segments(i) +1;
        segm_length{i} = [segm_length{i}, time - last_segment_time];

        % Read # segments in GT
        dat
        [~,~,cl_limGT, ~]=analizarExcel_Narrative([path_gt '/GT_' dat '.xls'], files);
        num_segments_gt(i) = length(cl_limGT);

    end


    % Average time per day
    mean_seconds = round(mean(time_length));
    [h,m,s] = secondsToTime(mean_seconds);
    disp(['Average time per day wearing the camera: ' num2str(h) 'h ' num2str(m) 'm ' num2str(s) 's.']);

    % Average # of continous segments per day
    mean_segments = mean(num_segments);
    disp(['Average number of continuous segments per day: ' num2str(mean_segments)]);

    % Average length of continous segments
    all_length = 0;
    count = 0;
    for i = 1:length(segm_length)
        for j = 1:length(segm_length{i})
            count = count+1;
            all_length = all_length + segm_length{i}(j);
        end
    end
    mean_seconds = round(all_length/count);
    [h,m,s] = secondsToTime(mean_seconds);
    disp(['Average time per continuous segment: ' num2str(h) 'h ' num2str(m) 'm ' num2str(s) 's.']);
    
    % Average # of GT segments per day
    mean_segments = mean(num_segments_gt);
    disp(['Average number of GT segments per day: ' num2str(mean_segments)]);
end


function time = timeToSeconds(name)
    time = [str2num(name(1:2)), str2num(name(3:4)), str2num(name(5:6))];
    time = time(1)*60*60 + time(2)*60 + time(3);
end

function name = getTimeFromName(name)
    name_aux = regexp(name, '_','split');
    if(length(name_aux) == 1)
        name_aux = regexp(name, '\.','split');
        name = name_aux{1};
    else
        name = name_aux{2};
    end
end

function [h,m,s] = secondsToTime(seconds)
    m = floor(seconds/60);
    s = mod(seconds,60);
    h = floor(m/60);
    m = mod(m, 60);
end