function [ blankedValues ] = BlankFunction(valuesToBeBlanked, blankValue)
%UNTITLED Blank your values
%   First argument is a vector or matrix of values to be blanked, second
%   argument is a vector of replicate values of blank, which will be
%   averaged using arithmetic mean and then substracted from each value to
%   be blanked.
blankValue = mean(blankValue, 1);
if isempty(blankValue)
    blankedValues = valuesToBeBlanked;
else
    blankedValues = valuesToBeBlanked - blankValue';
end

end

