classdef SingleExcelTable < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        preferredExcelCell
        table = cell(0,0)
        doTranspose
        tag
        treatmentName
        experimentProtocol
        preferredCell % has two fields: "row" - a number that represents the uppermost cell of the table. "column" - a number that represents the leftmost cell of the table
        type
        tableParameters
    end
    
    methods
        function this = SingleExcelTable()
        end
        
        function createTableFromExperiment(this, experimentProtocol)
            this.experimentProtocol = experimentProtocol;
            switch this.type
                case 'Experiment name'
                    this.createExperimentNameTable();
                case 'Height'
                    this.createHeightTable();
                case 'Width'
                    this.createWidthTable();
                case 'Treatment names'
                    this.createTreatmentNamesTable();
                    this.setCorrectTranspose();
                case 'Treatment names with concentrations'
                    this.createTreatmentNamesWithConcTable();
                    this.setCorrectTranspose();
                case 'Treatment names with concentrations and units'
                    this.createTreatmentNamesWithConcAndUnitsTable();
                    this.setCorrectTranspose();
                case 'Plate layout with treatments'
                    this.createPlateLayoutWithTreatmentsTable();
                    this.setCorrectTranspose();
                case 'Plate layout with groups'
                    this.createPlateLayoutWithGroupsTable();
                    this.setCorrectTranspose();
                case 'Plate layout with subgroups'
                    this.createPlateLayoutWithSubgroupsTable();
                    this.setCorrectTranspose();
                case 'List of exports'
                    this.createListOfExportsTable();
                    this.setCorrectTranspose();
                case 'Template protocol'
                    this.createTemplateProtocolTable();
                case 'Pipeting sequence'
                    this.createPipetingSequenceTable();
            end
        end
        
        function createPipetingSequenceTable(this)
            pipetingSimulatorInterface = this.experimentProtocol.pipetingSimulatorInterface;
            pipetingSimulatorInterface.calculateNewVolumes(this.experimentProtocol);
            this.table = pipetingSimulatorInterface.createPipetingTable();
            %this.table = 
        end
        
        function createExperimentNameTable(this)
            this.table = {this.experimentProtocol.experimentName};
        end
        
        function createHeightTable(this)
            this.table = this.experimentProtocol.plateHeight;
        end
        
        function createWidthTable(this)
            this.table = this.experimentProtocol.plateWidth;
        end
        
        function createTreatmentNamesTable(this)
            this.table = this.experimentProtocol.getTreatmentNames();
        end
        
        function createTreatmentNamesWithConcTable(this)
            treatmentNames = this.experimentProtocol.getTreatmentNames();
            concentrations = this.experimentProtocol.getTreatmentConcentrations();
            this.table = cell(1, numel(treatmentNames));
            this.table(1, :) = treatmentNames;
            for treatment = 1 : numel(treatmentNames)
               this.table(2:numel(concentrations{treatment})+1, treatment) = num2cell(concentrations{treatment}); 
            end
        end
        
        function createTreatmentNamesWithConcAndUnitsTable(this)
            treatmentNames = this.experimentProtocol.getTreatmentNames();
            concentrations = this.experimentProtocol.getTreatmentConcentrations();
            units = this.experimentProtocol.getTreatmentUnits();
            this.table = cell(1, numel(treatmentNames));
            this.table(1, :) = treatmentNames;
            for treatment = 1 : numel(treatmentNames)
               this.table{1, treatment} = [this.table{1, treatment}, '(', units{treatment},')'];
               this.table(2 : numel(concentrations{treatment})+1, treatment) = num2cell(concentrations{treatment}); 
            end
        end
        
        function createPlateLayoutWithTreatmentsTable(this)
            treatmentNames = this.experimentProtocol.getTreatmentNames();
            units = this.experimentProtocol.getTreatmentUnits();
            this.table = generatePlateTable(this.experimentProtocol.plateHeight, this.experimentProtocol.plateWidth);
            activeTreatmentName = this.tableParameters.treatmentName;
            for treatmentIndex = 1 : numel(treatmentNames)
                if strcmp(activeTreatmentName, treatmentNames{treatmentIndex})
                   activeTreatmentIndex = treatmentIndex;
                   break;
                end
            end
            this.table{1, 1} = [treatmentNames{activeTreatmentIndex}, '(', units{activeTreatmentIndex}, ')'];
            treatmentStructure = this.experimentProtocol.treatmentStructure;
            for wellIndex = 1 : numel(treatmentStructure.resultWells)
                [row, column] = this.experimentProtocol.apareciumExperimentInput.getRowAndColumnIndecesOfWell(treatmentStructure.resultWells{wellIndex});
                this.table{column + 1, row + 1} = treatmentStructure.results{wellIndex}(activeTreatmentIndex);
            end
        end
        
        function createPlateLayoutWithGroupsTable(this)
            listOfExports = this.experimentProtocol.getListOfExports();
            exportNames = this.experimentProtocol.getExportNames();
            indexOfActiveExport = this.tableParameters.exportIndex;
            groupNames = listOfExports{indexOfActiveExport}.getGroupNames();
            groupStructure = listOfExports{indexOfActiveExport}.getGroupStructure();
            this.table = generatePlateTable(this.experimentProtocol.plateHeight, this.experimentProtocol.plateWidth);
            this.table{1, 1} = ['Group stucture of ', exportNames{indexOfActiveExport}];
            treatmentStructure = this.experimentProtocol.treatmentStructure;
            for wellIndex = 1 : numel(treatmentStructure.resultWells)
                [row, column] = this.experimentProtocol.apareciumExperimentInput.getRowAndColumnIndecesOfWell(treatmentStructure.resultWells{wellIndex});
                this.table{column + 1, row + 1} = groupNames{groupStructure(row, column, 1)};
            end
        end
        
        function createPlateLayoutWithSubgroupsTable(this)
            listOfExports = this.experimentProtocol.getListOfExports();
            exportNames = this.experimentProtocol.getExportNames();
            indexOfActiveExport = this.tableParameters.plateLayoutWithSubgroupsStruct.exportIndex;
            subgroupNames = listOfExports{indexOfActiveExport}.getSubgroupNames();
            groupStructure = listOfExports{indexOfActiveExport}.getGroupStructure();
            this.table = generatePlateTable(this.experimentProtocol.plateHeight, this.experimentProtocol.plateWidth);
            this.table{1, 1} = ['Subgroup stucture of ', exportNames{indexOfActiveExport}];
            treatmentStructure = this.experimentProtocol.treatmentStructure;
            for wellIndex = 1 : numel(treatmentStructure.resultWells)
                [row, column] = this.experimentProtocol.apareciumExperimentInput.getRowAndColumnIndecesOfWell(treatmentStructure.resultWells{wellIndex});
                this.table{column + 1, row + 1} = subgroupNames{groupStructure(row, column, 1)}{groupStructure(row, column, 2)+1};
            end
        end
        
        function createListOfExportsTable(this)
            this.table = this.experimentProtocol.getExportNames();
        end
        
        function createTemplateProtocolTable(this)
            this.table = this.experimentProtocol.getTemplateTable();
        end
        
        function createStandardTable(this)
            
        end
        
        function setCorrectTranspose(this)
            if this.tableParameters.transpose
                this.table = this.table';
            end
        end
        
        function replaceVariableNameTags(this)
            
        end
        
        function table = getTable(this)
            table = this.table;
        end
        
        function setPreferredCell(this, cell)
            this.preferredCell = cell;
        end
        
        function preferredCell = getPreferredExcelCell(this)
            preferredCell = this.preferredCell;
        end
        
        function setTableParameters(this, tableParameters)
            this.tableParameters = tableParameters;
        end
        
        function setType(this, type)
            this.type = type;
        end
        
        function startingRow = getStartingRow(this)
           startingRow = this.preferredCell.row; 
        end
        
        function startingColumn = getStartingColumn(this)
           startingColumn = this.preferredCell.column; 
        end
        
        function maxRow = getMaxRow(this)
           maxRow = this.preferredCell.row + size(this.table, 1) - 1; 
        end
        
        function maxColumn = getMaxColumn(this)
           maxColumn = this.preferredCell.column + size(this.table, 2) - 1; 
        end
    end
    
end

