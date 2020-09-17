function histogramParameters = calculateImageStatisticsFromHistogram(histograms)

% Assume that the nonspot pixels of the image are representative of the
% noise level

histogramField = fields(histograms);
for i = 1 : numel(histogramField)
    histograms.(histogramField{i}) = reshape(histograms.(histogramField{i}), 1, numel(histograms.(histogramField{i})));
end
meanValue = sum(histograms.nonspotPixelHistogramHeights.*histograms.nonspotPixelHistogramX)/sum(histograms.nonspotPixelHistogramHeights);


normalizedFreq = cumsum(histograms.nonspotPixelHistogramHeights)/sum(histograms.nonspotPixelHistogramHeights);                            % Normalised Frequency Vector
medianIndex = find(normalizedFreq <= 0.5, 1, 'last');          % Index Of Normalised Frequencies <= 0.5

standardDeviation =sqrt(sum(histograms.nonspotPixelHistogramHeights.*(histograms.nonspotPixelHistogramX-meanValue).^2)./sum(histograms.nonspotPixelHistogramHeights)-1);

histogramParameters{1, 2} = meanValue;
histogramParameters{1, 3} = histograms.nonspotPixelHistogramX(medianIndex);
histogramParameters{1, 4} = standardDeviation;

