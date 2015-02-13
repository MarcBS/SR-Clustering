function [ dists ] = normalizeAll( dists, range )

    if nargin < 2
        range = [0 1];
    end

    maximum = max(max(dists));
    minimum = min(min(dists));
    dists = (dists-minimum)*(range(2)-range(1))/(maximum-minimum);

end
