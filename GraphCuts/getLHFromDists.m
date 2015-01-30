function [ LH ] = getLHFromDists( dists )

    sim = 1./(dists+1);
    tot = sum(sim,2);
    LH = bsxfun(@ldivide,tot, sim);

%     exp(-dists)
    
end

