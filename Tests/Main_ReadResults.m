%MAIN LEER Results
clc, close all, clear all
addpath('GraphCuts');

doPlot = false;
doVarColormap = false;
text=20; text_leg = 15;

doPlotClus = false;
text=25; text_leg = 15;

set_used = 'Both';

% Pair-wise weight
nPairwiseWeights = 5;
pairwise_weights = linspace(0,1,nPairwiseWeights);
pairwise_weights(1) = 1e-99;

% Unary weight
nUnaryWeights = 5;
unary_weights = linspace(0,1,nUnaryWeights);

%% Data loading
% directorio_im = 'D:/LIFELOG_DATASETS'; % SHARED PC
directorio_im = '/Volumes/SHARED HD/Video Summarization Project Data Sets/R-Clustering'; % MARC PC
% directorio_im='/Users/estefaniatalaveramartinez/Desktop/LifeLogging/IbPRIA/Sets'; % EST PC

% directorio_im = ''; % put your own datasets location

camera = {'Narrative', 'Narrative', 'Narrative', 'Narrative', 'Narrative', 'SenseCam', 'SenseCam', 'SenseCam', 'SenseCam', 'SenseCam'};
% folders={'Estefania1', 'Estefania2', 'Petia1', 'Petia2', 'Mariella', 'Day1','Day2','Day3','Day4','Day6'};
folders={'Estefania1', 'Estefania2', 'Petia1', 'Petia2', 'Mariella', 'Day1', 'Day2'};
formats={'.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.JPG','.JPG','.JPG','.JPG','.JPG'};

% directorio_results = 'D:/R-Clustering_Results'; % SHARED PC
directorio_results = '/Volumes/SHARED HD/R-Clustering Results'; % MARC PC
% directorio_results = '/Users/estefaniatalaveramartinez/Desktop/LifeLogging/IbPRIA/Results'; % EST PC
% directorio_results = ''; % put your own results location


final_results = [directorio_results '/FinalResults/'];
mkdir(final_results);


%% Clustering parameters
methods_indx={'ward','centroid','complete','weighted','single','median','average'};
% methods_indx={'ward'};
cut_indx=(0.2:0.2:1.2);
% cut_indx = [0.2];


%% Plot colours
white = ones(nUnaryWeights,nPairwiseWeights,3);        
red = white; red(:,:,[2 3]) = 0;
green = white; green(:,:,[1 3]) = 0;
orange = white; orange(:,:,3) = 0; orange(:,:,2) = 0.65;
if(doPlotClus)
%       col_clus = colormap(hsv); close(gcf);
%       col_clus = col_clus(round(linspace(1,size(col_clus,1)-10,length(methods_indx))),:);
    colors = {'k*-', 'b*-', 'm*-', 'g*-', 'r*-', 'c*-', 'y*-'};
  f_clus = figure; hold all;
end

%% Results variables
max_mean = 0;
max_mean_metGC = zeros(1,length(methods_indx));
max_mean_metClus = zeros(1,length(methods_indx));
max_mean_metAdwin = zeros(1,length(methods_indx));

 
%% Start evaluation
for i_met=1:length(methods_indx)
     method=methods_indx{i_met};
     accMean_cut = zeros(nUnaryWeights,nPairwiseWeights,length(cut_indx));
     for i_ind=1:length(cut_indx)
        Matrix_aux=zeros(nUnaryWeights,nPairwiseWeights,length(folders));
        fMeasureClus = zeros(1,length(folders));
        fMeasureAdwin = zeros(1,length(folders));
        for i_fold=1:length(folders)
            folder=folders{i_fold};
            
            load([directorio_results '/' folder '/Results_' method '_Res_Both_' folder '.mat']);
        
            n_cut = 1;
            while(abs(Results{n_cut}.cut_value - cut_indx(i_ind)) > 0.0001)
                n_cut = n_cut+1;
                if(n_cut > length(Results))
                    error(['Wrong cut indices!!! folder ' folder ' cutvalue ' num2str(cut_indx(i_ind))]);
                end
            end
            
            Matrix_aux(:,:,i_fold)=Results{n_cut}.fMeasure_GC;
            
            fMeasureClus(i_fold)=Results{n_cut}.fMeasure_Clustering;
            fMeasureAdwin(i_fold)=Results{n_cut}.fMeasure_Adwin;
            
        end%End_folder
        
%         % Correct NaNs for 0s
%         Matrix_aux(isnan(Matrix_aux)) = 0;
        
        % Calculate Means
        %Matrix_aux=Matrix_aux./length(folders);
        mean_M=mean(Matrix_aux,3);
        accMean_cut(:,:,i_ind)=mean_M;
        std_M = std(Matrix_aux,1,3);
        mean_fm_clus(i_ind)=mean(fMeasureClus);
        mean_fm_adwin=mean(fMeasureAdwin);
        
        
        %Figure 
        if(doPlot)
            %% Prepare std dev plot
            round_std = round(std_M*100);
            max_std = max(max(round_std));
            min_std = min(min(round_std));
            c = colormap(jet);close(gcf);
            col = c(round(linspace(1,size(c,1),max_std-min_std+1)),:);
            round_std = round_std-min_std+1;
            col = reshape(col(reshape(round_std,1,size(round_std,1)*size(round_std,2)),:),[nUnaryWeights,nPairwiseWeights,3]);
            
            fig=figure; hold all;
            if(~doVarColormap)
                surf(pairwise_weights, unary_weights,  mean_M, green) % GC accuracy
            else
                surf(pairwise_weights, unary_weights,  mean_M, col) % GC accuracy
            end
            surf(pairwise_weights, unary_weights, repmat((ones(1,nPairwiseWeights)*mean_fm_clus(i_ind)),nUnaryWeights,1), red) % Clustering accuracy
            surf(pairwise_weights, unary_weights, repmat((ones(1,nPairwiseWeights)*mean_fm_adwin),nUnaryWeights,1), orange) % Clustering2 accuracy

            colors = [reshape(green(1,1,:), 1, 3); reshape(red(1,1,:), 1, 3); reshape(orange(1,1,:), 1, 3)];
            h(1) = scatter3([], [], [], 50, colors(1,:), 'filled');
            h(2) = scatter3([], [], [], 50, colors(2,:), 'filled');
            h(3) = scatter3([], [], [], 50, colors(3,:), 'filled');
            legend(h, {'GC F-Measure'; 'Clustering F-Measure'; 'Adwin F-Measure'}, 3);

            %% Set other text
%             set(gca,'XTick', [1:nPairwiseWeights]-1 ); % x axis labels positions
%             xticklabel_rotate([1:nPairwiseWeights]-1,90,num2cell(flip(([1:nPairwiseWeights]-1).*W+offset)), 'FontSize', text,'interpreter','none');
            title([set_used ' Mean F-Measure   '], 'FontSize', text);
            zlabel('F-Measure  ', 'FontSize', text);
            ylabel('LH weighting term  ', 'FontSize', text);
            xlabel('GC tuning value  ', 'FontSize', text);
            set(gca,'FontSize',text);
            set(gca, 'ZLim', [0 1]);
            aux_save2=([final_results folder '_' method '_' num2str(i_ind) '.fig']);
            saveas(fig,aux_save2);
%             close all;
        end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %% Get cluster indices of best narrative result
%         clusIds = [Results{4}(1,7,:)];
%         clusIds = reshape(clusIds,[1 size(clusIds,3)]);
%         nFrames = length(clusIds);
%         event = zeros(1, nFrames); event(1) = 1;
%         prev = 1;
%         for i = 1:nFrames
%             if(clusIds(i) == 0)
%                 event(i) = 0;
%             else
%                 if(clusIds(i) == clusIds(prev))
%                     event(i) = event(prev);
%                 else
%                     event(i) = event(prev)+1;
%                 end
%                 prev = i;
%             end
%         end
%         num_clusters = max(event);
%         
%         result_data = {};
%         for i = 1:num_clusters
%             result_data{i} = [];
%         end
%         for i = 1:nFrames
%             if(event(i) ~= 0)
%                 result_data{event(i)} = [result_data{event(i)} i];
%             end
%         end
%         path_source = '/Volumes/SHARED HD/Segmentation_Adwin_Cluster_GC/GC_IBPRIA/petia_2';
%         file_list = dir([path_source '/*.jpg']);
%         clearvars fileList
%         count = 1;
%         for i = 1:length(file_list)
%             if(file_list(i).name(1) ~= '.')
%                 fileList(count) = file_list(i);
%                 count = count+1;
%             end
%         end
%         img_ex = imread([path_source '/' fileList(1).name]);
%         prop_div = 20;
%         props = round([size(img_ex,1)/prop_div, size(img_ex,2)/prop_div]);
% %         gen_image = summaryImage(props, num_clusters, 15, result_data, fileList, path_source, 'images', '', []);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Get max GC
        [v,max_row] = max(mean_M);
        [max_this,max_col] = max(v);
        if(max_this > max_mean)
            max_method = methods_indx{i_met};
            max_cut = cut_indx(i_ind);
            max_unary = unary_weights(max_row(max_col));
            max_pairwise = pairwise_weights(max_col);
            max_mean = max_this;
            max_std = std_M(max_row(max_col));
        end
        disp(['cut value '  num2str(method) ' ' num2str(cut_indx(i_ind)) ' '  num2str(max_this)])
        disp(['mean f-measure clus: ' num2str(mean_fm_clus(i_ind))]);
        disp(['mean f-measure adwin: ' num2str(mean_fm_adwin)]);
   
    end %Endcut
    disp(' ')
    
    if(doPlotClus)
%         plot(cut_indx, mean_fm1, 'Color', col_clus(i_met,:), 'LineWidth', 3);
        plot(cut_indx, mean_fm_clus, colors{i_met}, 'LineWidth', 3);
    end
    
    % Best for GC
    [v,max_row] = max(accMean_cut);
    [v,max_col] = max(v);
    [max_this,max_depth] = max(v);
    if(max_this > max_mean_metGC(i_met))
        max_cut_metGC(i_met) = cut_indx(max_depth);
        max_unary_metGC(i_met) = unary_weights(max_row(max_col(max_depth)));
        max_pairwise_metGC(i_met) = pairwise_weights(max_col(max_depth));
        max_mean_metGC(i_met) = max_this;
    end
    
    % Best for Clus
    [max_thisClus,max_depth] = max(mean_fm_clus);
    if(max_thisClus > max_mean_metClus(i_met))
        max_cut_metClus(i_met) = cut_indx(max_depth);
        max_mean_metClus(i_met) = max_thisClus;
    end
    
    max_mean_metAdwin(i_met) = mean_fm_adwin;

end %EndMet

if(doPlotClus)
    title([set_used ' Mean F-Measure Both Sets   '], 'FontSize', text);
    xlabel('Cut Value   ', 'FontSize', text);
    ylabel('F-Measure   ', 'FontSize', text);
    ylim([0 1]);xlim([cut_indx(1) cut_indx(end)]);
    leg=legend(methods_indx,1);
    leg = findobj(leg,'type','text');
    set(leg,'FontSize',text_leg);
    set(gca,'FontSize',text);
end
    

disp([num2str(max_method) ' ' num2str(max_cut) ' '  num2str(max_mean)])
disp(['std_dev = ' num2str(max_std)]);
disp(['unary: ' num2str(max_unary) ' pair-wise: ' num2str(max_pairwise)]);
disp('Done');

