function nonredundantChannels = removeRedundantChannels(originalChannels, formula)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

splitters = [{'+'},{'*'},{'\.'},{'-'},{'/'},{'\('},{'\)'},{'\^'}];

for a = 1 : numel(splitters)
    formula = regexprep(formula, splitters{a}, 'uniqueApareciumSplitString');
end
possibleChannels = strsplit(formula, 'uniqueApareciumSplitString');
nonredundantChannels = cell(0, 0);
for possibleChannelIndex = 1 : numel(possibleChannels)
    for originalChannelIndex = 1 : numel(originalChannels)
        if strcmp(possibleChannels{possibleChannelIndex}, originalChannels{originalChannelIndex})
            nonredundantChannels{end+1} = originalChannels{originalChannelIndex};
        end
    end
end
nonredundantChannels = unique(nonredundantChannels);
end