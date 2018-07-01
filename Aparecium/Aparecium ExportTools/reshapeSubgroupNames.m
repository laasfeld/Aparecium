function finalSubgroupNames = reshapeSubgroupNames(groupingStructure, subgroupNames, sharedBlankStructure)
    % make a cell array out of java two dimensional string array
    
    for group = 1 : numel(subgroupNames)
        for subgroup = 1 : numel(subgroupNames(group))
            subgroupNamesAsCell{group}{subgroup} = char(subgroupNames(group, subgroup));
        end
    end
       
    for group = 1 : numel(subgroupNames)
        % find wells in the particular group
       [groupRow, groupColumn] = find(groupingStructure(:,:,1)==group);
       presentSubgroups = zeros(1, numel(groupRow));
       % find the subgroup of all the wells present
       for wellIndex = 1 : numel(groupRow)
           presentSubgroups(wellIndex) = groupingStructure(groupRow(wellIndex), groupColumn(wellIndex), 2);
       end
       % find the unique subgroups present in this group
       for row = 1 : size(sharedBlankStructure, 2)
           for col = 1 : size(sharedBlankStructure, 1)
               if isequal(sharedBlankStructure(col, row, group), 1)
                   presentSubgroups(end + 1) = 0;
               end
           end
       end
       
       uniquePresentSubgroups = unique(presentSubgroups);
       % make a new reshaped subgroupNames so that when a subgroup is
       % missing then empty cell will be added in that place
       correctCounter = 0;
       for subgroupIndex = 0 : max(uniquePresentSubgroups)
          if isempty(find(uniquePresentSubgroups == subgroupIndex, 1))
             finalSubgroupNames{group}{subgroupIndex + 1} = []; 
          else
             correctCounter = correctCounter + 1;
             finalSubgroupNames{group}{subgroupIndex + 1} = subgroupNamesAsCell{group}{correctCounter};
           end
       end
    end
end

