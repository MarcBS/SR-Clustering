function [labels,dist2mean]=evaluate_adwin_Narrativem(fi,p,features)
%p=2; %L2 norm
%fi=0.1; %delta
 %read all files in the folder CNNfeatures 
 %path2CNN = '/home/mariella/MATLAB/Mariella/data/Narrative/CNNfeatures/'
 %path2imageSets = '/home/mariella/MATLAB/Mariella/data/Narrative/imageSets/';
 %path2GT= '/home/mariella/MATLAB/Mariella/data/Narrative/GT/';
% files_CNN=dir([path2CNN '/*.mat']);
 %files_GT=dir([path2GT '/*.xls']);
 %imageSets=dir(path2imageSets);
 %eval_res= zeros(length(files_CNN),6);
 %tol=5;
 %h=figure,

     [w,automatic,labels,dist2mean] = testCNN_adwin(features,fi,p);
     %g = figure,
     %plot(w)
     %saveas(g,strcat('adwin_Narrative_fi_',num2str(fi),'.png')); 
     %disp(automatic)
     %excelfile = files_GT(i).name;
     %[events,delim]=analizarExcel_Narrative(strcat(path2GT,excelfile),strcat(path2imageSets,imageSets(i+2).name));

     %delim has to be a row vector
%      [a,b] = size(delim);
%      if a>b 
%          delim = delim';
%      end
%      
%      if automatic(1) == 1
%          automatic=automatic(2:end);
%      end
%      
%         
%      Nframes = length(dir([strcat(path2imageSets,imageSets(i+2).name)]));
%      if delim(end) == Nframes
%          delim = delim(1:end-1);
%      end
     %[prec,rec,acc,FPR,TPR,fm] = evaluation(delim,automatic,Nframes,tol);
      %VisualBinFunction(imageSets(i+2).name,Nframes,'0', delim,automatic);
     %eval_res(i,:) = [prec,rec,acc,FPR,TPR,fm];
     %disp(prec)
     %plot(rec, prec,'r*'); axis([0 1 0 1]); hold on;saveas(h,strcat('PRadwin_Narrative_fi_',num2str(fi),'.png'));
 %end for
  
 
