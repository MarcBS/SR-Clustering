function [ dists ] = normalizeAll( dists )

    maximum = max(max(dists));
    minimum = min(min(dists));
    dists = (dists-minimum)/(maximum-minimum);

end
