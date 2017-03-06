function [ dists ] = color_dist( X, Y )
    
    % Get extra information from vector X
    t = X(end);
    chi2_mean = X(end-1);
    chi2_distancesX = X(2:end-2);
    
    X = X(1);
    Y = Y(:,1);
    
    w = max(0, t - abs(X-Y))/t;
    dists = 1 - w' .* exp(-chi2_distancesX(Y) ./ chi2_mean);

end

