function [TP,TN,FP,FN] = TP_TN_FP_FN(GT,automatic,Nframes,tol) 
%the inputs are vectors whose elements are the event boundaries
%tol is the tolerance: tol = 3 is a good option
%Nframes is the total number of frames, needed for computing the true negatives

%initialization
TP = 0;
TN = 0;
FP = 0;
FN = 0;

%compute FP and TP
for i=1:size(automatic,2)
	%check if a boundary found automatically is a true boundaries
	nofound = 'true';
	for j=1:size(GT,2)
        
		if abs(automatic(i)-GT(j))<tol
			TP = TP + 1;
			nofound = 'false';
        end
    end
	if strcmp(nofound,'true')  
			FP = FP + 1;
	end
end

%compute FN 
for i=1:size(GT,2)
	%check if a true boundary has been found automatically
	nofound = 'true';
	for j=1:size(automatic,2)
		if abs(automatic(j)-GT(i))<tol%abs(automatic(i)-GT(j))<tol
			nofound = 'false';
		end

    end
	if strcmp(nofound,'true') 
			FN = FN + 1;%missed
	end
    

end

%compute TN (correctly rejected as not boundaries): number of not boundaries (Nframes - size(GT,2)), less the number of false positive
TN = (Nframes - size(GT,2))-FP;

