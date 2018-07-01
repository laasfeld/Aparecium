function mainMidasTableController = mergeMIDASFiles(stackTableController, mainMidasTableController)
%UNTITLED merges all midas table controllers in midasTableControllers into
%one midas table controller object
%   Detailed explanation goes here
midasTableControllers = stackTableController.midasControllerArray;
if numel(midasTableControllers) > 1
    mergedMidasTableController = midasTableControllers{1};
    for tableNumber = 2 : numel(midasTableControllers)
        tableToMerge = midasTableControllers{tableNumber};
        columnsOfFirstTable = mergedMidasTableController.getColumnHeaders;
        columnsOfSecondTable = tableToMerge.getColumnHeaders;
        
        [mergedMidasTableController, tableToMerge] = guaranteeAllWellsPresent(mergedMidasTableController, tableToMerge);
        
        matchNotFound = 0;
        
        if isequal(numel(columnsOfFirstTable), numel(columnsOfSecondTable)) 
            for column = 1 : numel(columnsOfFirstTable)
                if strcmp(columnsOfFirstTable(column), columnsOfSecondTable(column))

                else
                    matchNotFound = 1;
                    break;
                end
            end
        else  
            matchNotFound = 1;
        end
        
        if isequal(matchNotFound,1)
        % let the user determine the layout that should be used for the combined
        % MIDAS format
            [noOfCols, combinedHeaders] = cellAligner(numel(columnsOfFirstTable), numel(columnsOfSecondTable), columnsOfFirstTable,...
            columnsOfSecondTable);
        else

        % loop through all the columns and generate combinedHeaders variable
        % for them
            noOfCols = numel(columnsOfFirstTable);
            for col = 1 : noOfCols
               combinedHeaders{col, 1}.name =  columnsOfFirstTable{col};
               combinedHeaders{col, 1}.index =  col;
               combinedHeaders{col, 2}.name =  columnsOfSecondTable{col};
               combinedHeaders{col, 2}.index =  col;
            end
        
        end
        originalColumn = 0;
        for column = 1 : noOfCols
            if ~isequal(combinedHeaders{column, 1}, [])% if there is data assotiated with that column
                originalColumn = originalColumn + 1;
                columnData = mergedMidasTableController.getEventTableColumnData(originalColumn);
                finalTextData(1 : numel(columnData), column) = columnData;
                columnData = [];
            else
                columnData = mergedMidasTableController.getEventTableColumnData(originalColumn);
                noOfRows = numel(columnData);
                columnData = cell(noOfRows, 1);
                [columnData{:}] = deal(0);
                finalTextData(1 : noOfRows, column) = columnData;
            end
        end
        
        noOfRowsOfFirstTable = size(finalTextData, 1);
        columnOfTable = 0;
        for column = 1 : noOfCols
            if ~isequal(combinedHeaders{column, 2}, [])% if there is data assotiated with that column
                columnOfTable = columnOfTable + 1;
                columnData = tableToMerge.getEventTableColumnData(columnOfTable);
                finalTextData(noOfRowsOfFirstTable + 1 : noOfRowsOfFirstTable + numel(columnData), column) = columnData;
                columnData = [];
            else
                columnData = tableToMerge.getEventTableColumnData(columnOfTable);
                noOfRows = numel(columnData);
                columnData = cell(noOfRows, 1);
                [columnData{:}] = deal(0);
                finalTextData(noOfRowsOfFirstTable + 1 : noOfRowsOfFirstTable + noOfRows, column) = columnData;
            end
        end
        
        noOfRowsOfSecondTable = size(finalTextData, 1) - noOfRowsOfFirstTable ;
        
        finalHeader = cell(0,0);
        for column = 1 : size(combinedHeaders, 1)
            if isfield(combinedHeaders{column, 1}, 'name')
                finalHeader{end + 1} = combinedHeaders{column, 1}.name;
            else
                finalHeader{end + 1} = combinedHeaders{column, 2}.name;
            end
        end
        
        for col = 1:noOfCols
           if isequal(strfind(finalHeader{col},'DA:All'), 1)||isequal(strfind(finalHeader{col}, 'DA:ALL'), 1)
               timestring = finalTextData{1, col};
           end
        end

        timeShift = stackTableController.tableData{tableNumber, 5};

        % search for the column where the time is represented
        for col = 1:noOfCols
           if isequal(strfind(finalHeader{col},'DA:All'),1)||isequal(strfind(finalHeader{col},'DA:ALL'), 1)
               % loop through all the cells containing measuring time
               % moments for the seccond file and add the time shift
               for row = (noOfRowsOfFirstTable + 1 : noOfRowsOfFirstTable + noOfRowsOfSecondTable)
                   finalTextData{row, col} = finalTextData{row, col} + timeShift; 
               end
               break;
           end
        end
        mergedMidasTableController = MidasTableController('empty');
        mergedMidasTableController.setFullMidasTable(finalHeader, finalTextData);
    end
else
    finalHeader = midasTableControllers{1}.getColumnHeaders();
    finalTextData = midasTableControllers{1}.getEventData();
end
mainMidasTableController.setFullMidasTable(finalHeader, finalTextData);