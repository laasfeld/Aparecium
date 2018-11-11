classdef CopasiPanelController < ExportPanelController
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        experimentParamNameTable = [];
        tableHandle = [];
        experimentParamsNames = [];
        groups = [];
        tableData = [];
    end
    
    methods
        
        function this = CopasiPanelController()
            
        end
        
        function addExperiment(this, experiment, varargin)
            this.experiment = experiment;
            this.experimentParamsNames = this.experiment.getTreatments();
            treatments = this.convertToCellArrayOfStrings(this.experiment.getTreatments());
            data = [treatments', treatments'];
            set(this.experimentParamNameTable, 'data', data);
        end
        
        function setTableHandle(this, tableHandle)
           this.tableHandle = tableHandle;           
        end
        
        function setExperimentParamNameTable(this, tableHandle)
            this.experimentParamNameTable = tableHandle;
        end
        
        function getNewExperimentParamsNames(this)
            data = get(this.experimentParamNameTable, 'Data');
            this.experimentParamsNames = data(:,2);
        end
        
        function calculateNewTable(this, exportMode, outputVariable)

           [data, this.groups] = this.calculationMethod.calculate(this.experiment, this.groupStructure, this.sharedBlankStructure, this.timewiseBlankStructure);
           if isequal(this.subgroupNames, [])
                this.subgroupNames = generateStandardSubgroupNames(data, 1);
           end
           channelNames = this.calculationMethod.getChannelNames();
           data = this.mergeOrAverage(data, exportMode);
           this.convertDataToCopasiFormat(data, this.groups, channelNames, outputVariable, exportMode);
        end
        
        function convertDataToCopasiFormat(this, data, groups, channelNames, outputValue, exportMode)
            return % buggy, this function is turned off 24.10.2018
            finalTable = cell(1,1);
            rowCounter = 1;
            headerWritten = 0;
            for group = 1 : numel(data)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    if ~headerWritten
                        finalTable{rowCounter, 1} = 'Time';
                    end
                    finalTable(rowCounter + 1 : rowCounter + numel(data{group}{subgroup}.timePoints), 1) = num2cell(data{group}{subgroup}.timePoints'); % add time column
                    
                    columnCounter = 1;
                    columnCounter = columnCounter + 1;
                    % define independent variables 
                    for independentVariableIndex = 1 : numel(data{group}{subgroup}.initialConditionsValue)
                        if ~headerWritten
                            finalTable{rowCounter, columnCounter} = data{group}{subgroup}.initialConditionsTreatment{independentVariableIndex};
                        end
                        finalTable(rowCounter + 1 : rowCounter + numel(data{group}{subgroup}.timePoints), columnCounter) = num2cell(ones(numel(data{group}{subgroup}.timePoints), 1)...
                            * str2num(data{group}{subgroup}.initialConditionsValue{independentVariableIndex}));
                        columnCounter = columnCounter + 1;
                    end
                    
                    for dependentVariableIndex = 1 : size(data{group}{subgroup}.average, 2)
                        formulae = this.calculationMethod.getFormulae();
                        if ~headerWritten
                            finalTable{rowCounter, columnCounter} = formulae{end}.acronyme;
                            
                        end
                        finalTable(rowCounter + 1 : rowCounter + numel(data{group}{subgroup}.timePoints), columnCounter) = num2cell(data{group}{subgroup}.average(:, dependentVariableIndex));
                        columnCounter = columnCounter + 1;
                    end                    
                    
                    rowCounter = rowCounter + numel(data{group}{subgroup}.timePoints) + 2;
                    if ~headerWritten
                        headerWritten = 1;
                    end
                end
                
            end
            set(this.tableHandle, 'data', finalTable);
            this.tableData = finalTable;
        end
        
        function paramNames = readParamsNames(this)
           data = get(this.experimentParamNameTable, 'data'); 
           paramNames = data(:, 2);          
        end
        
        function showTableData(this, group, subgroup)
            data = this.outputTableStruct{group}{subgroup}.CopasiTable;
            % TODO-implement visuals
        end
        
        function exportWithName(this, name)
            cell2csv(name,  this.tableData, '	');
        end
        
        function exportWithDialogue(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            % TODO - create separate path variable
            startingPath = settings.Excel;
            filters = {'.txt';'.csv'};
            [FileName,FilePath,FilterIndex] = uiputfile(filters, '', startingPath);
            
            this.exportWithName([FilePath, FileName]);
        end
        
        function sendToWorkspace(this)
            %TODO - implement function
        end
        
        function updateExperimentParamNameTable(this)
            originalParameterNames =  this.experiment.getTreatments();
            tableData = {originalParameterNames', this.experimentParamsNames'};
            set(this.experimentParamNameTable, 'data', tableData);
        end
        
        
    end
    
end

