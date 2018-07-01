function [ height,width, wellID, inUse] = generateGhostplate(ID)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    alphabet = ExtendedRowLabels();
    height = 0;
    width = 0;
    for index = 1 : size(ID,1)
       ID(index) = regexprep(ID(index), ' ',''); % in some cases there may be a space in the ID, we don´t want it there since in most cases it was not there in the first place 
    end
    for index = 1 : size(ID,1)
        for row = 1 : numel(alphabet)
            if isequal(strfind(ID{index}, alphabet{row}), 1) && row > height
                height = row;
            end
        end

        currentWellID = ID{index};
        for row = 1:numel(alphabet)
            column = str2double(regexprep(currentWellID, alphabet{row}, ''));
            if ~strcmp(regexprep(currentWellID, alphabet{row}, ''), currentWellID)
               break; 
            end
        end
        if width < column
            width = column;
        end
    end

    wellID = cell(width, height);
    wellID2 = cell(width, height);% for neo format where numbers are written as 1 2 3 not 01 02 03
    inUse = zeros(width, height);
    for i=1:width
        for j=1:height
            if i>9
                wellID{i, j} = strcat(alphabet{j},num2str(i));
                wellID2{i, j} = strcat(alphabet{j},num2str(i));
            else
                wellID{i, j} = strcat(alphabet{j},'0',num2str(i)); 
                wellID2{i, j} = strcat(alphabet{j},num2str(i));
            end
            for index = 1 : size(ID,1)
               if strcmp(wellID(i, j), ID(index))
                   inUse(i, j) = 1;
                   break;
               elseif strcmp(wellID2(i, j), ID(index))
                   inUse(i, j) = 1;
                   wellID(i, j) = ID(index);
                   break;
               end
            end      
        end
    end
end