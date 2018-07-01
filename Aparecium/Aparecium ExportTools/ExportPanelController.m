classdef ExportPanelController < handle
    % ExportPanelController This class acts as an abstract class for all Aparecium export
    % tabs. It is not declared abstract since older versions of matlab do
    % not allow it
    %   This class should be used as a base for all export controllers of
    %   Aparecium ExportTools
    
    properties
        experiment = [];
        groupStructure = [];
        timeString = ' s';
        calculationMethod;
        timeController = [];
        subgroupNames;
        sharedBlankStructure;
        timewiseBlankStructure;
        subgroupStartValue = 1;
    end
    
    methods
        
        function addExperiment(this, experiment) % ApareciumExperimentInput
            this.experiment = experiment;
        end
        
        function addTimeController(this, timeController)
           this.timeController = timeController; 
        end
        
        function addGroupStructure(this, groupStructure)
            this.groupStructure = groupStructure;
        end

        function addSubgroupNames(this, subgroupNames)
            this.subgroupNames = subgroupNames;
        end
        
        function addSharedBlankStructure(this, sharedBlankStructure)
           this.sharedBlankStructure = sharedBlankStructure; 
        end
        
        function addTimewiseBlankStructure(this, timewiseBlankStructure)
           this.timewiseBlankStructure = timewiseBlankStructure; 
        end
        
        function setCalculationMethod(this, calculationMethod)
            this.calculationMethod = calculationMethod;
        end
        
        function setSubgroupStartValue(this, subgroupStartValue)
            this.subgroupStartValue = subgroupStartValue;
        end
        
        function uniquenessTable = createTreatmentUniquenessTable(this, numberOfGroups, groups, data)
            concentrationsOfGroup = cellfun(@str2num, this.experiment.getTreatmentsConcentrationsOfGroup(groups{1}, 1));
            for group = 2 : numberOfGroups
                concentrationsOfGroup = cat(1, concentrationsOfGroup, cellfun(@str2num, this.experiment.getTreatmentsConcentrationsOfGroup(groups{group}, group)));
            end
            uniquenessTable = cell(numberOfGroups, 1);
            for group = 1 : numberOfGroups
                uniquenessTable{group} = cell(numel(data{group}), 1);
                for subgroup = subgroupStartValue : numel(data{group})
                    [unneeded, treatmentConcentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(1), 1);
                    treatmentConcentrations = cellfun(@str2num, treatmentConcentrations);
                    for treatment = 1 : numel(treatmentConcentrations)
                        uniquenessTable{group}{subgroup}(treatment) = numel(find(concentrationsOfGroup(:,treatment)==treatmentConcentrations(treatment))); 
                    end
                end              
            end            
        end
        
        function exportData = mergeOrAverage(this, data, exportMode)
        this.experimentParamsNames = this.readParamsNames();
        timePoints = this.timeController.getCycleTimes();
            switch exportMode
                case 'Average'
                    for group = 1 : size(data, 2)
                        for subgroup = this.subgroupStartValue : numel(data{group})
                            measurements = [];
                            for subgroupElement = 1 : numel(data{group}{subgroup})
                                measurements = [measurements, cell2mat(data{group}{subgroup}{subgroupElement})];
                            end
                            cycles = this.experiment.getNumberOfCycles();
                            exportData{group}{subgroup}.minimum = min(measurements', [], 1)';
                            exportData{group}{subgroup}.maximum = max(measurements', [], 1)';
                            exportData{group}{subgroup}.average = mean(measurements', 1)';
                            %exportData{group}{subgroup}.timePoints = this.experiment.getCycleTimeMoments();
                            time = [];
                            if this.experiment.getFastKinetics()
                                for subgroupElement = 1 : numel(data{group}{subgroup})
                                    wellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{subgroupElement}); 
                                    time = [time; timePoints(wellIndex, :)];
                                end
                            else
                                for subgroupElement = 1 : numel(data{group}{subgroup})
                                    %wellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{subgroupElement}); 
                                    time = [time; timePoints(1, :)];
                                end 

                            end
                            exportData{group}{subgroup}.timePoints = mean(time, 1);
                            treatments = this.experiment.getTreatments();
                            for subgroupElement = 1 : numel(data{group}{subgroup})
                                [treatmentsOfWell, concentrationsOfWell] = this.experiment.getTreatmentsOfWell(this.groups{group}{subgroup}{subgroupElement}, 1);
                                for treatment = 1 : numel(treatments)
                                    exportData{group}{subgroup}.initialConditions{treatment} = [this.experimentParamsNames{treatment},'(0) = ',num2str(concentrationsOfWell{treatment})];
                                    exportData{group}{subgroup}.initialConditionsValue{treatment} = num2str(concentrationsOfWell{treatment});
                                    exportData{group}{subgroup}.initialConditionsTreatment{treatment} = this.experimentParamsNames{treatment};
                                end
                            end
                        end
                    end
            case 'Merge'
                for group = 1 : size(data, 2)
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        measurements = [];
                        for subgroupElement = 1 : numel(data{group}{subgroup})
                            measurements = cell2mat(data{group}{subgroup}{subgroupElement});
                            cycles = this.experiment.getNumberOfCycles();
                            exportData{group}{subgroup}{subgroupElement}.minimum = measurements;
                            exportData{group}{subgroup}{subgroupElement}.maximum = measurements;
                            exportData{group}{subgroup}{subgroupElement}.average = measurements;
                            %exportData{group}{subgroup}.timePoints = this.experiment.getCycleTimeMoments();
                            wellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{subgroupElement}); 
                            if this.experiment.getFastKinetics()
                                exportData{group}{subgroup}{subgroupElement}.timePoints = timePoints(wellIndex, :);
                            else
                                exportData{group}{subgroup}{subgroupElement}.timePoints = timePoints(1, :);
                            end
                            treatments = this.experiment.getTreatments();

                            [treatmentsOfWell, concentrationsOfWell] = this.experiment.getTreatmentsOfWell(this.groups{group}{subgroup}{subgroupElement}, 1);
                            for treatment = 1 : numel(treatments)
                                exportData{group}{subgroup}{1}.initialConditions{treatment} = [this.experimentParamsNames{treatment},'(0) = ',num2str(concentrationsOfWell{treatment})];
                                exportData{group}{subgroup}{1}.initialConditionsValue{treatment} = num2str(concentrationsOfWell{treatment});
                                exportData{group}{subgroup}{1}.initialConditionsTreatment{treatment} = this.experimentParamsNames{treatment};
                            end                            
                        end
                    end
                end                
            end
        end

    end
    
    methods (Abstract)
 
        calculateNewTable(this, configuration) % calculate the new output data and update graphical representation if needed
        
        exportWithName(this, name) % export the data from this exporter with the specified name
        
        exportWithDialogue(this) % provide the user with a dialogue for choosing export file/folder name and location and proceed to export with exportWithName
        
        sendToWorkspace(this) % send the table table/figure/structure/object to matlab main workspace

    end
    
    methods (Static)
        
        function convertedTreatments = convertToCellArrayOfStrings(treatments)
            convertedTreatments = cell(1, numel(treatments));
            for treatment = 1 : numel(treatments)
               convertedTreatments{treatment} = char(treatments{treatment}); 
            end
        end
    end
    
end

