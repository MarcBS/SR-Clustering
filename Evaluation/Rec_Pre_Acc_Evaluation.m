function [rec,prec,acc,fMeasure]=Rec_Pre_Acc_Evaluation(GT,automatic,Nframes,tol)

%TP,TN,FP,FN

[TP,TN,FP,FN] = TP_TN_FP_FN(GT,automatic,Nframes,tol); 

%Precision
if TP+FP == 0
    prec = 0;
else 
    prec = TP/(TP+FP);  
end
%Recall
if TP+FN == 0
    rec=0;
else
    rec = TP/(TP+FN);
end
%Accuracy
if TP+TN+FP+FN == 0a
    acc=0;
else
    acc = (TP+TN)/(TP+TN+FP+FN);
end

% Fm
if (rec+prec) ~= 0 
    fMeasure = 2*(rec*prec)/(rec+prec);
else
    fMeasure = 0; 
end