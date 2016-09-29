
%% Plot timeline of EDUG-Seg data

path_data = '/media/HDD_2TB/DATASETS/EDUB-Seg/Narrative/imageSets';
%datasets = {'Petia1'; 'Petia2'; 'Mariella'; 'Estefania1'; 'Estefania2'; ...
%    'Estefania3'; 'Maya1'; 'Maya2'; 'Maya3'; 'Marc1'};
%datasets = {'Petia3'; 'Petia4'; 'Petia5'; 'Estefania4'; 'Estefania5';'Estefania6';'Marc2'; ...
%    'Marc3'; 'Marc4'; 'Marc5'; 'Marc6'; 'MarcC1'};
    
path_data = '/media/My_Book/Datos_Lifelogging/Narrative/Pedro/2016/08';
datasets = {'05', '06', '07', '08', '09'};
    
format = 'jpg';

sets_separation = 1;
plot_hours = {'06:00'; '08:00'; '10:00'; '12:00'; '14:00'; '16:00'; '18:00'; '20:00'; '22:00'};

path_results = './';


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
        name = files(j).name;
        name_aux = regexp(name, '_','split');
        if(length(name_aux) == 1)
            name_aux = regexp(name, '\.','split');
            name = name_aux{1};
        else
            name = name_aux{2};
        end
        
        % Convert timestamps to seconds
        time = [str2num(name(1:2)), str2num(name(3:4)), str2num(name(5:6))];
        time = time(1)*60*60 + time(2)*60 + time(3);
        timestamps(j) = time;
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
