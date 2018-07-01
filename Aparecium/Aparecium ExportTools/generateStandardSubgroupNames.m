function [subgroupNames] = generateStandardSubgroupNames(data, firstSubgroupToShow)
subgroupNames = cell(1, size(data, 2));
for group = 1 : size(data, 2)
    subgroupNames{group} = cell(1, numel(data{group}));
    for subgroup = firstSubgroupToShow : numel(data{group})
        if isequal(subgroup, 1)
            subgroupNames{group}(subgroup) = {'Blank'};
        else
            subgroupNames{group}(subgroup) = {['Subgroup ',num2str(subgroup - 1)]};
        end
    end
end

end

