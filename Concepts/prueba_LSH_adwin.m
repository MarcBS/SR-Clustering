function prueba_LSH_adwin(featuresPCA)
%load features of a sequence
features_ori = featuresPCA;
for i=1:size(features,1)
    %put to all zero 
    if rand(1)>0.5
        featuresPCA(featuresPCA<0)=0;
    else
        featuresPCA(featuresPCA>0)=0;
    end
end

    [labels,dist2mean] = runAdwin(featuresPCA, confidence, pnorm); 
end
