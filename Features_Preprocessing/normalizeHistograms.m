function [ X ] = normalizeHistograms( X )
%NORMALIZEHISTOGRAMS Normalizes row-wise.
%   Normalizes the values of the input matrix row-wise instead of
%   column-wise.

    minimum = min(X);
    maximum = max(X);
    X = (X-minimum)/(maximum-minimum);
end

