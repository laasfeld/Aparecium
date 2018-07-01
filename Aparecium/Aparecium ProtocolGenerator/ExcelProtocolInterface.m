classdef ExcelProtocolInterface < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        activeExcelHandle
        workbookHandle
        sheetHandle
    end
    
    methods
        
        function this = ExcelProtocolInterface()
            try
                this.activeExcelHandle = actxGetRunningServer('Excel.Application');
                this.activeExcelHandle.visible = 1;
            catch MException
               if isequal(MException.message, 'The server ''Excel.Application'' is not running on this system.') 
                  this.activeExcelHandle = actxserver('Excel.Application');
                  this.activeExcelHandle.visible = 1;
                  this.activeExcelHandle.Workbooks.Add();
                  this.workbookHandle = this.activeExcelHandle.Workbooks.Item(1);
                  this.sheetHandle = this.activeExcelHandle.Sheets.Item(1);
               end
            end
        end
        
        function createNewSheet(this)
            
        end
        
        function [row, column] = sendTableToActiveCell(this, table)
            range = this.activeExcelHandle.Selection.Cells.Item(1);
            row = range.row;
            column = range.column;
            range = ExcelProtocolInterface.rangeGenerator([row, row+size(table, 1)-1, column, column+size(table, 2)-1]);
            this.sendTableToRange(table, range);
        end
        
        function sendTableToPredefinedCell(this, table, cell)
            range = ExcelProtocolInterface.rangeGenerator([cell.row, cell.row+size(table, 1)-1, cell.column, cell.column+size(table, 2)-1]);
            this.sendTableToRange(table, range);
        end
        
        function sendTableToRange(this, table, range)
            rangeObject = this.sheetHandle.Range(range);
            rangeObject.Value = table;
        end
        
    end
    
    methods(Static)
        function formulaTable = xlsReadFormulae(fileName)
            % can´t replace with ~ since it seems to give errors with
            % previous versions of MATLAB
            excelHandle = actxserver('Excel.Application');
            fileHandle = excelHandle.Workbooks(1).Open(fileName);
            sheet = excelHandle.Workbooks.Item(1).Sheets.Item(1);
            DataRange = sheet.UsedRange.Address;
            DataRange = regexprep(DataRange, '\$', '');
            range = ['A1:', DataRange(strfind(DataRange, ':')+1:end)];
            formulaTable = sheet.Range(range).Formula;
            invoke(excelHandle, 'Quit');
            release(excelHandle);
            release(sheet);                        
        end
        
        function range = rangeGenerator(rangeVector)
            % rangeVector(1) = starting column, rangeVector(2) = ending
            % column, rangeVector(3) = starting row, rangeVector(4) =
            % endingRow
            
            startingRow = rangeVector(1);
            endingRow = rangeVector(2);
            startingColumn = rangeVector(3);
            endingColumn = rangeVector(4);
            range = [ExcelProtocolInterface.columnToLetters(startingColumn), num2str(startingRow), ':', ExcelProtocolInterface.columnToLetters(endingColumn), num2str(endingRow)];
        end
        
        function letters = columnToLetters(d)
            % modified from dec2base

            b = numel(alphabet());
            n = max(1,round(log2(max(d)+1)/log2(b)));
            while any(b.^n <= d)
                n = n + 1;
            end
            s(:,n) = rem(d,b);
            % any(d) must come first as it short circuits for empties
            while any(d) && n >1
                n = n - 1;
                d = floor(d/b);
                s(:,n) = rem(d,b);
            end
            symbols = alphabet();
            letters = reshape(symbols(s),size(s));
        end
    end
    
end

