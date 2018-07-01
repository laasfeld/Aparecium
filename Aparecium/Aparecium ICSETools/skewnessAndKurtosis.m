function [s, k] = skewnessAndKurtosis(x)
%UNTITLED calculates both skewness and kurtosis sligtly faster than the two
%   used separately
%   When you want to calculate both skewness and kurtosis then this function avoids some
%   duplication and is therefore faster


% The output size for [] is a special case, handle it here.
if isequal(x,[])
    k = NaN;
    s = NaN;
    return;
end;
dim = find(size(x) ~= 1, 1);

% Need to tile the output of nanmean to center X.
%tile = ones(1,max(ndims(x),dim));
%tile(dim) = size(x,dim);

nonNaNIndices = ~isnan(x);
%x0 = x - repmat(mean(x(nonNaNIndices)), tile); % older slower version
x0 = x - mean(x(nonNaNIndices));
x02 = x0.*x0;
x03 = x02.*x0;
x04 = x03.*x0;
s2 = mean(x02(nonNaNIndices));
m3 = mean(x03(nonNaNIndices));
s = m3 ./ s2.^(1.5);
m4 = mean(x04(nonNaNIndices));
k = m4 ./ s2.^2;

end

