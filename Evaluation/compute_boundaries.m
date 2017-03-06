function [automatic]=compute_boundaries(clustersId,Nframes)


bound = [];
                    index=1;
                    for pos=1:length(clustersId)-1
                        if (clustersId(pos)~=clustersId(pos+1))>0
                            bound(index)=pos;
                            index=index+1;
                        end
                    end
                    if (isempty(bound)==1)
                        bound=0;
                        automatic=bound;
                    else
                        automatic=bound;
                        if automatic(1) == 1
                            automatic=automatic(2:end);
                        end
                    end
end
