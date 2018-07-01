function [ blankedValues ] = TimewiseBlankNormalizeFunction(valuesToBeBlanked, blankValue)
%UNTITLED Blank your values
%   First argument is a vector or matrix of values to be blanked, second
%   argument is a vector of replicate values of blank, which will be
%   averaged using arithmetic mean and then substracted from each value to
%   be blanked.
nonNaNIndices = ~isnan(blankValue);
blankValue = mean(blankValue(nonNaNIndices));
blankedValues = (valuesToBeBlanked - blankValue')./(blankValue');

end

