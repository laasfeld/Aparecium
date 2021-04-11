function [statisticsResults] = spotHistogramStatistics(threshold, histograms)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

histogramField = fields(histograms);
for i = 1 : numel(histogramField)
    histograms.(histogramField{i}) = reshape(histograms.(histogramField{i}), 1, numel(histograms.(histogramField{i})));
end
histograms.spotHistogramHeights = histograms.spotHistogramHeights(histograms.spotHistogramX > threshold);
histograms.spotHistogramX = histograms.spotHistogramX(histograms.spotHistogramX > threshold);

histograms.spotPixelHistogramHeights = histograms.spotPixelHistogramHeights(histograms.spotPixelHistogramX > threshold);
histograms.spotPixelHistogramX = histograms.spotPixelHistogramX(histograms.spotPixelHistogramX > threshold);

histograms.nonspotPixelHistogramHeights = histograms.nonspotPixelHistogramHeights(histograms.nonspotPixelHistogramX > threshold);
histograms.nonspotPixelHistogramX = histograms.nonspotPixelHistogramX(histograms.nonspotPixelHistogramX > threshold);

histograms.imagePixelHistogramHeights = histograms.imagePixelHistogramHeights(histograms.imagePixelHistogramX > threshold);
histograms.imagePixelHistogramX = histograms.imagePixelHistogramX(histograms.imagePixelHistogramX > threshold);

meanValue = sum(histograms.spotPixelHistogramHeights.*histograms.spotPixelHistogramX)/sum(histograms.spotPixelHistogramHeights);
normalizedFreq = cumsum(histograms.spotPixelHistogramHeights)/sum(histograms.spotPixelHistogramHeights);                            % Normalised Frequency Vector
medianIndex = find(normalizedFreq <= 0.5, 1, 'last');          % Index Of Normalised Frequencies <= 0.5

standardDeviation =sqrt(sum(histograms.nonspotPixelHistogramHeights.*(histograms.nonspotPixelHistogramX-meanValue).^2)./sum(histograms.nonspotPixelHistogramHeights)-1);

statisticsResults{1, 2} = sum(histograms.spotHistogramHeights)/histograms.imageCount;
statisticsResults{1, 3} = (sum(histograms.spotPixelHistogramHeights.*histograms.spotPixelHistogramX) + sum(histograms.nonspotPixelHistogramHeights.*histograms.nonspotPixelHistogramX)) / (sum(histograms.spotPixelHistogramHeights)+sum(histograms.nonspotPixelHistogramHeights));
statisticsResults{1, 4} = meanValue;
statisticsResults{1, 5} = sum(histograms.spotPixelHistogramHeights.*histograms.spotPixelHistogramX)/histograms.imageCount;



end

