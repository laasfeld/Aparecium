function result = ExtendedRowLabels(varargin)
%UNTITLED Summary of this function goes here
%   maximum for 1536 well plates = 32 rows 48 columns
alpha = alphabet();
rowLabels = cell(32, 1);
for index = 1 : numel(alphabet)
   rowLabels{index} = alpha(index); 
end

counter = 0;
for index = numel(alphabet) + 1 : 32
   counter = counter + 1;
   rowLabels{index} = ['A', alpha(counter)]; 
end

if isequal(numel(varargin), 0)
    result = rowLabels;
    return
elseif isequal(numel(varargin), 1)
    index = varargin{1};
    result = rowLabels{index};
end

end

