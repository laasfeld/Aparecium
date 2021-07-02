function pointerVector = find2DOutliers(spotVector, totalAnalysisVector, pointerVector)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
spotVector = spotVector - min(spotVector);
spotVector = spotVector/max(spotVector);

totalAnalysisVector = totalAnalysisVector - min(totalAnalysisVector);
totalAnalysisVector = totalAnalysisVector/max(totalAnalysisVector);

NaNIndices = isnan(totalAnalysisVector);
spotVector(NaNIndices) = [];
totalAnalysisVector(NaNIndices) = [];
pointerVector(:, NaNIndices) = [];
try
    plot(spotVector, totalAnalysisVector, '*');
    p = polyfit(spotVector,totalAnalysisVector,2);
    polyvec = [min(spotVector):max(spotVector)/1000:max(spotVector); polyval(p, min(spotVector):max(spotVector)/1000:max(spotVector))]';
    pointvec = [spotVector, totalAnalysisVector];
    t = delaunayn(polyvec);
    l = dsearchn(polyvec, t, pointvec);
    distVec = sqrt(((polyvec(l, 1) - pointvec(:, 1)).^2 + (polyvec(l, 2) - pointvec(:, 2)).^2));
    goodPointIndices = distVec < mean(distVec) + 2*std(distVec);
    outlierIndices = distVec >= mean(distVec) + 2*std(distVec);
    hold on
    plot(spotVector(goodPointIndices), totalAnalysisVector(goodPointIndices), '*');
    %pointerVector(:, outlierIndices) = [];


    dirVec = polyvec(l, 1) - pointvec(:, 1) + polyvec(l, 2) - pointvec(:, 2);

    c=-1/(sqrt(2)*erfcinv(3/2));

    MAD = c*median(abs(distVec.*sign(dirVec)-median(distVec.*sign(dirVec))));
    med = median(distVec.*sign(dirVec));
    outVec = distVec > med+3*MAD;
    if sum(abs(outVec - outlierIndices)) > 0
     sign(sum(outVec - outlierIndices))*sum(abs(outVec - outlierIndices))/sum(outlierIndices)
     '';
    end
    outlierIndices = outVec;
    pointerVector(:, outlierIndices) = [];
catch
    ''
end
%(sum(outlierIndices)/numel(outlierIndices))*100
end

