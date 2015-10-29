function [ dists ] = chi2_dist( X, Y )

    % No 0s allowed
    X(X==0) = 1e-10; Y(Y==0) = 1e-10;

    nSamples = size(Y,1);
    dists = zeros(1, nSamples);
    for i = 1:nSamples
        dists(i) = sum( (X-Y(i,:)).^2 ./ (X+Y(i,:)) ) / 2;
    end

end

