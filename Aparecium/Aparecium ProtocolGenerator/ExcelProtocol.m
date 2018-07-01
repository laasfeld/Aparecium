classdef ExcelProtocol < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        listOfTables
        templateTableIndex = 0;
    end
    
    methods
        function this = ExcelProtocol()
            
        end
        
        function addNewTable(this, singleExcelTable)
           this.listOfTables = [this.listOfTables, singleExcelTable]; 
        end
        
        function setTemplateTable(this, singleExcelTable)
           if isequal(this.templateTableIndex, 0)
               this.listOfTables = [this.listOfTables, singleExcelTable];
               this.templateTableIndex = numel(this.listOfTables);
           else
               this.listOfTables(this.templateTableIndex) = singleExcelTable; 
           end
           
        end
        
        function numberOfSingleTables =  getNumberOfSingleTables(this)
            numberOfSingleTables = numel(this.listOfTables);
        end
        
        function createTables(this, experimentProtocol)
            for tableIndex = 1 : this.getNumberOfSingleTables()
                excelTable = this.getTableAtIndex(tableIndex);
                excelTable.createTableFromExperiment(experimentProtocol);
            end
        end
        
        function maxRow = calculateMaxRow(this)
            maxRowVector = zeros(this.getNumberOfSingleTables(), 1);
            for tableIndex = 1 : this.getNumberOfSingleTables()
                excelTable = this.getTableAtIndex(tableIndex);
                maxRowVector(tableIndex) = excelTable.getMaxRow(); 
            end
            maxRow = max(maxRowVector);
        end
        
        function maxColumn = calculateMaxColumn(this)
            maxColumnVector = zeros(this.getNumberOfSingleTables(), 1);
            for tableIndex = 1 : this.getNumberOfSingleTables()
                excelTable = this.getTableAtIndex(tableIndex);
                maxColumnVector(tableIndex) = excelTable.getMaxRow(); 
            end
            maxColumn = max(maxColumnVector);
        end
        
        function table = getTableAtIndex(this, tableIndex)
           try
               table = this.listOfTables(tableIndex);
           catch MException
              disp('Error: Table index out of bounds. Max value = ', num2str(this.numberOfSingleTables()));
              disp(MException);
              table = [];
           end
        end
        
        function templateTable = getTemplateTable(this)
            templateTable = this.listOfTables(this.templateTableIndex);
        end
    end
    
end

