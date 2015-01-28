
%% function standarize

function [ std_matrix, meanD, stdDev ] = standarize( matrix, meanD, stdDev )
%STANDARIZERS Returns a standarized version of the data with the missing
%values substituted with the mean of the attribute

    if nargin < 3
        %Compute the mean of each column (NaNs no compute)
        meanD = mean(matrix);
        stdDev = std(matrix);
    end
    
%     std_matrix = bsxfun(@rdivide, bsxfun(@minus, matrix, meanD), stdDev);
    
    
    %Logical matrix with ones in the place of NaNs and 0 the rest
    matrixNaNs = isnan(matrix);
    
    %Inter. matrix, with the mean in the place of NaNs
    matrixIntermediate = matrixNaNs * diag(meanD);
    
    %Join inter. matrix with original matrix. Substitude missing
    %values(NaNs) for the mean of the attribute
    matrix(matrixNaNs) = matrixIntermediate(matrixNaNs);
   
    %Get a standarized matrix
    std_matrix = zscore(matrix);

end

