classdef ApareciumExperimentInput < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        treatments = cell(0,0);
        concentrations
        units
        mode
        measurements
        wells
        inUse
        numberOfCycles  
        numberOfChannels
        numberOfMeasurements
        channelNames
        predefinedConcentrations
        timeMoments
        groups = {''};
        eventTimes = [];
        concentrationChangeEvents = [];
        fastKinetics = 0;
        hasChanged = 1;
    end
    
    methods
        function this = ApareciumExperimentInput()
            
        end
        
        function setHasChanged(this, change)
           this.hasChanged = change; 
        end
        
        function setPredefinedConcentrations(this, predefinedConcentrations)
           this.predefinedConcentrations = predefinedConcentrations;
           this.hasChanged = 1;
        end
        
        function setFastKinetics(this, fastKinetics)
           this.fastKinetics = fastKinetics; 
        end
        
        function fastKinetics = getFastKinetics(this)
            fastKinetics = this.fastKinetics;
        end
        
        function updateTreatments(this, treatmentsTabel)
            newTreatments = cell(1, size(treatmentsTabel, 1));
            newConcentrations = cell(1, size(treatmentsTabel, 1));
            newUnits = cell(1, size(treatmentsTabel, 1));
            
            for treatment = 1 : size(treatmentsTabel, 1)
                newTreatments{treatment} = treatmentsTabel{treatment, 1};
                treatmentsTabel{treatment, 2} = regexprep(treatmentsTabel{treatment, 2}, ',', '.');
                newConcentrations{treatment} = str2num(treatmentsTabel{treatment, 2});
                newUnits{treatment} = treatmentsTabel{treatment, 3};
            end
            
            this.setTreatments(newTreatments);
            this.setConcentrations(newConcentrations);
            this.setUnits(newUnits);
            this.hasChanged = 1;
        end
        
        function updateUnits(this, units)
           this.units = units; 
           this.hasChanged = 1;
        end
        
        function updateConcentrations(this, concentrations)
           this.concentrations = concentrations; 
           this.hasChanged = 1;
        end
        
        function setTreatments(this, treatments)
            this.treatments = treatments;
            this.hasChanged = 1;
        end
        
        function addTreatment(this, treatment)
            this.treatments = [this.treatments, treatment]; 
            this.hasChanged = 1;
        end
        
        function treatments = getTreatments(this)
            treatments = this.treatments;
        end
        
        function numberOfTreatments = getNumberOfTreatments(this)
           numberOfTreatments = numel(this.treatments); 
        end
        
        function setGroups(this, groups)
           this.groups = groups; 
           this.hasChanged = 1;
        end
        
        function setCycleTimeMoments(this, timeMoments)
           this.timeMoments = timeMoments; 
           this.hasChanged = 1;
        end
        
        function timeMoments = getCycleTimeMoments(this)
           timeMoments = this.timeMoments; 
        end
        
        function groups = getGroups(this)
            groups = this.groups;
        end
        
        function setConcentrations(this, concentrations)
            this.concentrations = concentrations; 
            this.hasChanged = 1;
        end
        
        function concentrations = getConcentrations(this)
            concentrations = this.concentrations;
        end
        
        function setUnits(this, units)
           this.units = units; 
           this.hasChanged = 1;
        end
        
        function units = getUnits(this)
            units = this.units;
        end
        
        function setMode(this, mode)
           this.mode = mode; 
           this.hasChanged = 1;
        end
        
        function mode = getMode(this)
           mode = this.mode; 
        end
        
        function setWells(this, wells)
           this.wells = wells; 
           this.hasChanged = 1;
        end
        
        function wells = getWells(this)
           wells = this.wells; 
        end            
        
        function setInUse(this, inUse)
           this.inUse = inUse; 
           this.hasChanged = 1;
        end
        
        function inUse = getInUse(this)
           inUse = this.inUse; 
        end
        
        function setNumberOfCycles(this, numberOfCycles)
           this.numberOfCycles = numberOfCycles; 
           this.hasChanged = 1;
        end
        
        function cycles = getNumberOfCycles(this)
           cycles = this.numberOfCycles; 
        end
        
        function setMeasurements(this, measurements)
           this.measurements = measurements;
           this.numberOfChannels = size(measurements, 4);
           this.hasChanged = 1;
        end
        
        function measurements = getMeasurements(this)
           measurements = this.measurements; 
        end
        
        function measurements = getMeasurementsOfWell(this, wellID, channel)
            [rowIndex, columnIndex] = this.getRowAndColumnIndecesOfWell(wellID);
            measurements = reshape(this.measurements(rowIndex, columnIndex, :, channel), numel(this.measurements(rowIndex, columnIndex, :, channel)), 1);
        end
        
        function [rowIndex, columnIndex] = getRowAndColumnIndecesOfWell(this, wellID)
            [rowIndex, columnIndex] = find((strcmp(this.wells, wellID)==1));
        end
        
        function wellIndex = getIndexOfWell(this, wellID)
            [rowIndex, columnIndex] = this.getRowAndColumnIndecesOfWell(wellID);
            wellIndex = (columnIndex - 1) * size(this.wells, 1) + rowIndex;
        end
        
        function wellIndex = getIndexOfUsedWell(this, wellID)
            wellIndex = this.getIndexOfWell(wellID);
            subtract = 0;
            for counter = 1 : wellIndex
                if isequal(this.inUse(counter), 0)
                    subtract = subtract + 1;
                end
            end
            wellIndex = wellIndex - subtract;
        end
        
        function numberOfRows = getNumberOfRows(this)
            numberOfRows = size(this.wells, 2);
        end
        
        function numberOfColumns = getNumberOfColumns(this)
            numberOfColumns = size(this.wells, 1);
        end
        
        function wellIndex = getIndexOfUsedWellInGroup(this, wellID, groups)
            wellIndex = this.getIndexOfWell(wellID);
            subtract = 0;
            for counter = 1 : wellIndex
                if isequal(this.wellBelongsToGroupDefinedByWellID(wellID, counter, groups), 0)
                    subtract = subtract + 1;
                end
            end
        end
        
        function result = wellBelongsToGroupDefinedByWellID(this, wellID, counter, groups)
            
            groupIndex = 0;
            for group = 1 : numel(groups)
                for subgroup = 2 : numel(groups{group})
                    for subgroupElement = 1 : numel(groups{group}{subgroup})
                        if strcmp(groups{group}{subgroup}{subgroupElement}, wellID)
                            groupIndex = group;
                            subgroup = numel(groups{group});
                            subgroupElement = numel(groups{group}{subgroup});
                            group = numel(groups);
                            break;
                        end
                    end
                end
            end
            
            group = groupIndex;
            searchWellID = this.wells(counter);
            for subgroup = 2 : numel(groups{group})
                for subgroupElement = 1 : numel(groups{group}{subgroup})
                    if strcmp(groups{group}{subgroup}{subgroupElement}, searchWellID)
                        result = 1;
                        return
                    end
                end
            end
            result = 0;
        end
        
        function [treatments, treatmentConcentrations] = getTreatmentsOfWell(this, wellID, cycle)
            [rowIndex, columnIndex] = this.getRowAndColumnIndecesOfWell(wellID);
            treatmentConcentrations = this.predefinedConcentrations(columnIndex, rowIndex, cycle, :);
            treatments = this.getTreatments();
        end
        
        function treatmentConcentrations = getTreatmentsConcentrationsOfGroup(this, group, cycle)
            isFirst = 0;
            for subgroup = 1 : numel(group)
                for subgroupElement = 1 : numel(group{subgroup})
                    if isequal(isFirst, 0)
                        [unneeded, treatmentConcentrations] = this.getTreatmentsOfWell(group{subgroup}(subgroupElement), cycle);
                        isFirst = 1;
                    else
                        [unneeded, tempConcs] = this.getTreatmentsOfWell(group{subgroup}(subgroupElement), cycle);
                        treatmentConcentrations = cat(3, treatmentConcentrations, tempConcs);
                    end
                end
            end
            treatmentConcentrations = squeeze(treatmentConcentrations);
        end
        
        function treatmentConcentrations = getTreatmentsConcentrationsOfSubgroup(this, groups, subgroupIndex, cycle)
            isFirst = 0;
            for groupIndex = 1 : numel(groups)
                for subgroupElement = 1 : numel(groups{groupIndex}{subgroupIndex})
                    if isequal(isFirst, 0)
                        [unneeded, treatmentConcentrations] = this.getTreatmentsOfWell(groups{groupIndex}{subgroupIndex}(subgroupElement), cycle);
                        isFirst = 1; 
                    else
                        [unneeded, tempConcs] = this.getTreatmentsOfWell(groups{groupIndex}{subgroupIndex}(subgroupElement), cycle);
                        treatmentConcentrations = cat(3, treatmentConcentrations, tempConcs);
                    end
                end              
            end
        end
        
        
        function numberOfChannels = getNumberOfChannels(this)
            numberOfChannels = this.numberOfChannels;
        end
        
        function setChannelNames(this, channelNames)
           this.channelNames = channelNames; 
           this.hasChanged = 1;
        end
        
        function channelNames = getChannelNames(this)
            channelNames = this.channelNames;
        end
        
        function setConcentrationChangeEvents(this, concentrationChangeEvents)
           this.concentrationChangeEvents = concentrationChangeEvents;
           this.hasChanged = 1;
        end
        
        function events = getConcentrationChangeEvents(this)
           events = this.concentrationChangeEvents; 
        end
        
        function setEventTimes(this, eventTimes)
           this.eventTimes = eventTimes; 
           this.hasChanged = 1;
        end
        
        function eventTimes = getEventTimes(this)
            eventTimes = this.eventTimes;
        end
        
        function revertToPreMIDASImport(this)
            newTreatments = cell(0,0);
            newUnits = cell(0,0);
            for treatmentIndex = 1 : numel(this.treatments)
                splitIndex = strfind(this.treatments{treatmentIndex}{1}, '_');
                newTreatments{end+1} = this.treatments{treatmentIndex}{1}(1 : splitIndex-1);
                newUnits{end+1} = this.treatments{treatmentIndex}{1}(splitIndex + 1 : end);
            end
            this.treatments = newTreatments;
            this.units = newUnits;
        end
    end
end