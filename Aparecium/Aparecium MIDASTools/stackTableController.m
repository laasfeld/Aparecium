classdef stackTableController < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        midasControllerArray;
        stackTable;
        tableData;
    end
    
    methods
        function this = stackTableController(stackTable)
            this.stackTable = stackTable;
        end 
        
        function setMidasControllerArray(this, midasControllerArray)
            this.midasControllerArray = midasControllerArray;
        end
        
        function update(this)
            this.tableData = get(this.stackTable, 'data');
            numberOfMidasFiles = numel(this.midasControllerArray);
            
            for n = size(this.tableData, 1) + 1 : numberOfMidasFiles
                this.tableData{n, 1} = this.midasControllerArray{n}.getFileName();
                this.tableData{n, 2} = n;
                this.tableData{n, 3} = 0;
                this.tableData{n, 4} = 0;
                this.tableData{n, 5} = 0;
                this.tableData{n, 6} = false;
                this.tableData{n, 7} = false;
                eventData.Indices(2) = 4;
                eventData.Indices(1) = n;
                set(this.stackTable, 'data', this.tableData);
                this.updateTimeshifts(eventData);
            end
            set(this.stackTable, 'data', this.tableData);
        end
        
        function updateTimeshifts(this, eventData)
           
            this.tableData = get(this.stackTable, 'data');
            numberOfMidasFiles = numel(this.midasControllerArray);
            this.tableData = this.convertToNumerical(this.tableData);            
            if isequal(eventData.Indices(2), 5)
                this.tableData{1, 4} = this.tableData{1, 5};
                for n = 2 : numberOfMidasFiles
                    this.tableData{n, 4} = this.tableData{n, 5} - this.tableData{n - 1, 5};
                end
            elseif isequal(eventData.Indices(2), 4)
                this.tableData{1, 5} = this.tableData{1, 4};
                for n = 2 : numberOfMidasFiles
                    this.tableData{n, 5} = this.tableData{n, 4} + this.tableData{n - 1, 5};
                end              
            else
                
            end
            set(this.stackTable, 'data', this.tableData);
        end
        
        function handles = removeFilesFromTable(this, eventData, handles)
            if isequal(eventData.Indices(2), 7)
                this.midasControllerArray(eventData.Indices(1)) = [];
                handles.midasControllerArray = this.midasControllerArray;
                this.tableData(eventData.Indices(1), :) = [];
                %set(this.stackTable, 'data', this.tableData);
            end
            numberOfMidasFiles = numel(this.midasControllerArray);
            if numberOfMidasFiles > 1
                this.tableData{1, 4} = this.tableData{1, 5};
                for n = 2 : numberOfMidasFiles
                    this.tableData{n, 4} = this.tableData{n, 5} - this.tableData{n - 1, 5};
                end
            end
            set(this.stackTable, 'data', this.tableData);
        end
        
        function tableData = convertToNumerical(this, tableData)
            numberOfMidasFiles = numel(this.midasControllerArray);
            for n = 1 : numberOfMidasFiles
                if isnan(this.tableData{n, 4})
                    this.tableData{n, 4} = 0;
                end
                
                if isnan(this.tableData{n, 5})
                    this.tableData{n, 5} = 0;
                end
            end
        end
    end
    
end

