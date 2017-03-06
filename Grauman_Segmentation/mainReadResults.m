

results_file = 'Results_Grauman.mat';

load(results_file); % Results


nSets = length(Results);
iniSets = 1;

% selSets = iniSets:nSets; % ALL
% selSets = [1 2 4 5 10]; % Narrative old (Set 1)
% selSets = [3 6:9]; % Narrative new (Set 2)
% selSets = 11:15; % SenseCam
selSets = 1:10; % Narrative All 

t_vals = [Results(1).t(:)];
nT = length(t_vals);
avrg_FMeasure = zeros(1, nT);

for t = 1:nT
	nSets = length(selSets);
	f_measures = zeros(1, nSets);
	count_sets = 1;
	for s = selSets
		f_measures(count_sets) = Results(s).fMeasure(t);	
		count_sets = count_sets+1;
	end
	avrg_FMeasure(t) = mean(f_measures);
end

disp(avrg_FMeasure)
disp(t_vals)

disp('Done');
exit;
