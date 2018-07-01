function pooledSTD = pooledSTD(N, means, STDs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% calculate sum of samples - number of samples
sum_sam = sum(N);
% calculate sum of sampleSize*std^2
sum_sam_X_STD_squared = sum(N.*(STDs.^2));
% calculate sum of SUM i<j over Nxi*Nxj (uxi - uxj)^2
sumOfMeanDifferences = 0;
for j = 2 : numel(N)
    for i = 1 : j - 1
        sumOfMeanDifferences = sumOfMeanDifferences + N(i)*N(j)*(means(i) - means(j))^2;
    end
end

% calculate pooledSTD
pooledSTD = sqrt( (sum_sam_X_STD_squared/sum_sam) +  sumOfMeanDifferences/(sum_sam^2));

end