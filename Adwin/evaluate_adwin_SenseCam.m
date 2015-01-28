function evaluate_adwin_SenseCam()
 %read all files in the folder CNNfeatures 
 path2CNN = '/home/mariella/MATLAB/Mariella/data/SenseCam/CNNfeatures/'
 path2GT= '/home/mariella/MATLAB/Mariella/data/SenseCam/GT/';
 files_CNN=dir([path2CNN '/*.mat']);
 files_GT=dir([path2GT '/*.xls']);
 eval_res= zeros(length(files_CNN),6);
 tol  = 5;
 figure,
 for i=1:length(files_CNN)
     filename = files_CNN(i).name;
     [w,automatic] = testCNN_adwin(strcat(path2CNN,filename));
     excelfile = strcat(path2GT,files_GT(i).name);
     [events,delim]=analizarExcel(excelfile);
     [prec,rec,acc,FPR,TPR,fm] = evaluation(delim,automatic,length(files_CNN),tol);
     eval_res(i,:) = [prec,rec,acc,FPR,TPR,fm];
     plot(rec, prec,'r*'); hold on;
 end
