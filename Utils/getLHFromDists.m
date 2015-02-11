function [ LH ] = getLHFromDists( dists )

    %% Version 1
    sim = 1./(dists+1);

    %% Version 2
%     dists = dists.^2;
%     norm = mean(reshape(dists, 1, size(dists,1)*size(dists,2)));
%     sim = exp(-dists/2*norm);
    
    %% Normalize sum between 0 and 1
    tot = sum(sim,2);
    LH = bsxfun(@ldivide,tot, sim);
    
end

