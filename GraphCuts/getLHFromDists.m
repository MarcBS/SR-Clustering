function [ LH ] = getLHFromDists( dists )

    tot = sum(dists,2);
    sim = 1./(dists+1);
    tot = sum(sim,2);
    LH = bsxfun(@ldivide,tot, sim);

end

