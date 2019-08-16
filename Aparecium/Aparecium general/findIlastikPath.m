function fullPath = findIlastikPath()
    [status,cmdout] = system('wmic logicaldisk get caption');
    drives = regexprep(cmdout, 'Caption', '');
    drivesList = strsplit(drives, '    ');
    suitableFolders = cell(1,0);
    suitableFolderVerCheck = cell(1,0);
    for drive = drivesList
       d = dir([drive{1}, '\Program Files']);
       for i = 1 : numel(d)
           if ~isempty(strfind(d(i).name, 'ilastik-')) && exist([drive{1}, '\Program Files\', d(i).name,'\ilastik.exe'], 'file') == 2 
               suitableFolders{end + 1} = [drive{1}, '\Program Files\', d(i).name];
               suitableFolderVerCheck{end + 1} = d(i).name;
           end
       end  
    end
    if isempty(suitableFolders)
        fullPath = [];
    else
        counter = 0;
        versionHierarchyTable = zeros(0, 3);
        for folder = suitableFolderVerCheck
            counter = counter + 1;
            versionHierarchy = sscanf(regexprep(folder{1}, 'ilastik-', ''), '%d.%d.%d');
            if numel(versionHierarchy) < 3
                versionHierarchy(3) = 0; % zero-fills to 3 elements
            end
            versionHierarchyTable(counter, :) = versionHierarchy;
        end

        for level = 1 : 3
            [x, index] = sort(versionHierarchyTable(:,level), 'descend');
            suitables = find(x==x(1));
            versionHierarchyTable = versionHierarchyTable(index(suitables), :);
            suitableFolders = suitableFolders(index(suitables));
        end
        fullPath = [suitableFolders{1}]; 
    end
end