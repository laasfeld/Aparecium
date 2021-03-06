classdef PlateSimulatorInterface < handle
    properties
        microPlate
        javaMicroPlate
        PlateSimulator
        experiment
        widthOfFrame = 1250;
        heightOfFrame = 720;
        isPlateSimulatorInitialized = 0;
        installationAlreadyAttempted = 0;
        attemptMidasInitialize = 0;
    end
    methods
        function this = PlateSimulatorInterface()
            
        end
        
        function plateSimulator = getPlateSimulator(this)
           plateSimulator = this.PlateSimulator; 
        end
        
        function microPlate = getPlate(this)          
            microPlate = this.microPlate;      
        end
        
        function setPlateAndJavaPlate(this, microPlate)
            this.microPlate = microPlate;
            this.generateJavaMicroPlate(microPlate);
        end
        
        function results = getGroupStructure(this)
            results = this.PlateSimulator.getGroupStructure();
        end
        
        function subgroupNames = getSubgroupNames(this)
            subgroupNames = this.PlateSimulator.getSubgroupNames();
        end
        
        function sharedBlankStructure = getSharedBlankStructure(this)
            sharedBlankStructure = this.PlateSimulator.getSharedBlankStructure();
        end
        
        function timewiseBlankStructure = getTimewiseBlankStructure(this)
            timewiseBlankStructure = this.PlateSimulator.getTimewiseBlankStructure();
        end
        
        function timewiseBlankAlignment = getTimewiseBlankAlignment(this)
           timewiseBlankAlignment = char(this.PlateSimulator.getTimewiseBlankAlignment()); 
        end
        
        function regeneratePlateSimulatorFromGroupStructure(this, groupStructure, subgroupNames, sharedBlankStructure, timewiseBlankStructure, alignment)
            groupStructure
            this.PlateSimulator.regeneratePlateSimulatorFromGroupStructure(groupStructure, this.convertCellToJava2dimStringArray(subgroupNames), sharedBlankStructure, timewiseBlankStructure, java.lang.String(alignment));
        end
        
        function simPlateHandle = generatePlateSimulator(this, handles)
            if this.experiment.hasChanged || isempty(this.PlateSimulator)
                try
                    load javapath
                    if(strcmp(Path(end), '\'))
                       Path(end) = [];
                    end
                    javaaddpath(strcat(Path,'\Sim plate.jar'), '-end')
                    mode = this.experiment.getMode();

                    try
                        concentrations = this.convertCellToJava2dimStringArray(this.experiment.getConcentrations());
                    catch
                        warndlg('Concentrations seem to be empty or in wrong format');
                        return
                    end
                    units = this.experiment.getUnits();  
                    treatments = this.treatmentsAsStringArray(this.experiment.getTreatments());
                    wellNames = this.experiment.getWells();
                    inUse = this.experiment.getInUse();
                    cycles = this.experiment.getNumberOfCycles();
                    measurements = this.experiment.getMeasurements();
                    groups = this.experiment.getGroups();
                    [probableEventCycles, probableEventTimes, probableEventComments] = this.predictEvents(this.experiment.getStopwatchTimes(), this.experiment.getStopwatchLabels());
                    if strfind(mode, 'groupWells')   
                        this.PlateSimulator = plateSimulator.PlateSimulator(treatments, concentrations, units, mode, wellNames, inUse, cycles, measurements, groups);
                        timewiseBlankStructure = this.generateStandardTimewiseBlankStructure(inUse, cycles, measurements);
                        this.PlateSimulator.setTimewiseBlankStructure(timewiseBlankStructure);
                        this.experiment.setHasChanged(0);
                    elseif strfind(mode, 'addTreatments')
                        try
                            this.PlateSimulator = plateSimulator.PlateSimulator(treatments, concentrations, units, mode, wellNames, inUse, cycles, probableEventCycles, probableEventTimes, probableEventComments);
                        catch MException
                            this.PlateSimulator = plateSimulator.PlateSimulator(treatments, concentrations, units, mode, wellNames, inUse, cycles);
                        end
                        this.experiment.setHasChanged(0);
                    end

                catch MException
                    if strcmp(MException.identifier, 'MATLAB:undefinedVarOrClass') || strcmp(MException.identifier, 'MATLAB:load:couldNotReadFile')
                        if ~this.installationAlreadyAttempted
                            result = questdlg('It seem like Java installation has not been performed. Would you like to install Java from current folder?');
                            pause(0.5); % without this pause the program seems to successfully install java but crash right after it.
                            switch result
                                case 'Yes'
                                    try                            
                                        this.installationAlreadyAttempted = 1;
                                        toolboxLocation = fileparts(mfilename('fullpath'));
                                        Java_Installation
                                        this.generatePlateSimulator(handles);
                                        successBox('Java installation completed', 'Success');

                                    catch

                                    end
                                case 'No'
                                    warndlg('Java installation was not successful');
                            end               
                        else
                            warndlg('Java installation was not successful');   
                        end
                    else
                        warndlg('Something went wrong, could not open PlateSimulator'); 
                    end
                end
            else
                    
            end
            this.PlateSimulator.setVisible(true);
            width = handles.figure1.Position(3);
            height = handles.figure1.Position(4);
            [a, simPlateHandle] = javacomponent(this.PlateSimulator, [0, 0 , width, height], handles.figure1);

            this.isPlateSimulatorInitialized = 1;
        end
        
        function addExperiment(this, experiment)
            this.experiment = experiment;
            %experiment.setHasChanged(1);
        end
        
        function setUsedTreatments(this, treatments)
           this.PlateSimulator.setTreatments(treatments);
        end
        
        function setUsedTreatmentConcentrations(this, concentrations)
           concentrationsAsStringArray = this.convertCellToJava2dimStringArray(concentrations);
           this.PlateSimulator.setConcentrations(concentrationsAsStringArray); 
        end     
        
        function finalJavaArray = convertStringCellToJava2dimStringArray(wells)
            load javapath
            import java.lang.*;
            javaArray = cell(size(wells, 2),1);
            for treatment = 1 : size(wells, 2);
               for concentration = 1 : size(wells{treatment},2)
                   javaArray{treatment} = [javaArray{treatment},String(wells{treatment}(concentration))];
               end
            end
            finalJavaArray = javaArray{1};
            if(size(concentrations, 2) > 1) 
                for treatment = 2 : size(concentrations, 2)
                    finalJavaArray = [finalJavaArray; javaArray{treatment}];
                end
            end
        end
        
        function setUsedTreatmentUnits(this, units)
           this.PlateSimulator.setUnits(units); 
        end
        
        function displayPlateSimulator(this)
            import javax.swing.JFrame;
            PlateSimulatorFrame = JFrame('Plate Simulator');
            PlateSimulatorFrame.setSize(this.widthOfFrame,this.heightOfFrame);
            PlateSimulatorFrame.add(this.PlateSimulator);
            PlateSimulatorFrame.setVisible(true);
        end
            
        function generateJavaMicroPlate(this, plate)
            this.javaMicroPlate = plate.getAsJavaMicroPlate();
        end
        
        function treatmentStruct = getTreatmentStructure(this)
            try
                numberOfEvents = this.PlateSimulator.getNumberOfEvents();
            catch
                
            end
            treatmentStruct.eventStruct = cell(numberOfEvents, 1);
            treatmentStruct.eventTimes = this.PlateSimulator.getEventTimes();
            [treatmentStruct.eventTimes, sortedEventSequence] = sort(treatmentStruct.eventTimes);
            counter = 0;
            for event = sortedEventSequence'
                tic
                counter = counter + 1;
                treatments = this.PlateSimulator.getTreatmentStructure(event - 1);
                toc
                numberOfRows = size(this.experiment.inUse, 2);
                numberOfColumns = size(this.experiment.inUse, 1);
                results = cell(0,0);
                treatmentStruct.resultWells = cell(0,0);
                for row = 1 : numberOfRows
                    for column = 1 : numberOfColumns 
                        if(this.experiment.inUse(column, row))
                            numberOfTreatments = size(this.experiment.treatments, 2);
                            treatmentStruct.resultWells{end+1} = this.experiment.wells(column, row);
                            for treatment = 1 : numberOfTreatments
                                if isequal(treatments(column, row, treatment),0)
                                     results{numel(treatmentStruct.resultWells)}(treatment) = 0;
                                else
                                     results{numel(treatmentStruct.resultWells)}(treatment) = this.experiment.concentrations{treatment}(treatments(column, row, treatment)); 
                                end
                            end
                        end
                    end
                end
                treatmentStruct.eventStruct{counter} = results;
                toc
            end
            treatmentStruct.results = treatmentStruct.eventStruct{1};
        end
        
        function regeneratePlateSimulatorFromTreatmentStructure(this, treatmentStructure)
            import java.lang.*;
            eventTimes = treatmentStructure.eventTimes;
            eventsStructure = javaArray('java.lang.String', numel(treatmentStructure.eventStruct), numel(treatmentStructure.resultWells), 1);
            wells = this.treatmentsAsStringArray(treatmentStructure.resultWells);
            for eventIndex = 1 : numel(treatmentStructure.eventStruct)
               eventsStructure(eventIndex) = this.convertCellToJava2dimStringArray(treatmentStructure.eventStruct{eventIndex}); 
            end
            this.PlateSimulator.regeneratePlateSimulatorFromEventsStructure(eventsStructure, wells, eventTimes);
        end
        
        function [probableEventCycles, probableEventTimes, eventComment] = predictEvents(this, stopwatchTimes, stopwatchLabels)
            cycleTimeMoments = this.experiment.getCycleTimeMoments();
            probableEventCycles = [];
            probableEventTimes = [];
            if isempty(stopwatchTimes)
                eventComment = {'(cycle duration change)'};
                probableEventCycles(end + 1) = 1;

                if numel(cycleTimeMoments > 0)
                    probableEventTimes(end + 1) = cycleTimeMoments(1);

                    if(numel(cycleTimeMoments) > 1)
                        delta = 0;
                        expectingDelta = 0;
                        for i = 2 : numel(cycleTimeMoments)
                            newDelta = cycleTimeMoments(i) - cycleTimeMoments(i - 1);
                            if ~isequal(delta, newDelta) && isequal(expectingDelta, 0) 
                               expectingDelta = 1;
                               delta = newDelta;
                            elseif ~isequal(delta, newDelta) && isequal(expectingDelta, 1) 
                               probableEventCycles(end + 1) = i - 1;
                               eventComment{end + 1} = '(cycle duration change)';
                               probableEventTimes(end + 1) = cycleTimeMoments(i - 1);
                               delta = newDelta;
                               expectingDelta = 0;
                            else
                               expectingDelta = 0;
                            end
                        end
                    end
                end
                eventComment = PlateSimulatorInterface.treatmentsAsStringArray(eventComment);
                probableEventCycles = PlateSimulatorInterface.treatmentsAsStringArray(num2cell([probableEventCycles, nan(1, numel(stopwatchTimes))]));
            else
                probableEventCycles = cell(numel(stopwatchTimes), 1);
                for stopwatchIndex = 1 : numel(stopwatchTimes)
                    orderIndex = find(sort([this.experiment.timeMoments; stopwatchTimes(stopwatchIndex)]) == stopwatchTimes(stopwatchIndex));
                    if isequal(numel(orderIndex), 2)
                        probableEventCycles{stopwatchIndex} = ['at ',num2str(orderIndex(1))];
                    elseif isequal(numel(orderIndex), 1)
                        probableEventCycles{stopwatchIndex} = [num2str(orderIndex - 1), '->', num2str(orderIndex)];
                    end
                end
             
                probableEventTimes = stopwatchTimes';
                eventComment = stopwatchLabels';
            end
            if isempty(probableEventTimes)
               probableEventTimes = NaN; 
            end
        end             
    end
    
    methods(Static)
        
        function timewiseBlankStructure = generateStandardTimewiseBlankStructure(inUse, cycles, measurements)
            timewiseBlankStructure = zeros([size(inUse), cycles]);
            for i = 1 : size(measurements, 3)
                oneNonNaNPresent = ~min(min(min(isnan(measurements(:,:,i,:)))));
                if isequal(oneNonNaNPresent, 1)
                    timewiseBlankStructure(:, :, i) = 1;
                    break;
                end
            end        
        end
        
        function finalJavaArray = convertCellToJava2dimStringArray(concentrations)
            load javapath
            import java.lang.*;
            jArray = cell(numel(concentrations),1);
            for treatment = 1 : numel(concentrations);
               jArray{treatment} = javaArray('java.lang.String', numel(concentrations{treatment}));
               for concentration = 1 : numel(concentrations{treatment})
                   if isnumeric(concentrations{treatment}(concentration))
                       jArray{treatment}(concentration) = java.lang.String(num2str(concentrations{treatment}(concentration)));
                   else
                       % this part is a bit messy and not well generalized.
                       % Try to make it more general so it would work with
                       % different cell arrays
                       try
                            jArray{treatment}(concentration) = java.lang.String(concentrations{treatment}{concentration});
                       catch MException
                          if strcmp(MException.identifier, '[MATLAB:Java:GenericException;]')
                              jArray{treatment}(concentration) = java.lang.String('Blank');
                          end                          
                       end
                   end
               end
            end
            finalJavaArray = javaArray('java.lang.String', numel(concentrations), 1);
            finalJavaArray(1) = jArray{1};
            if(numel(concentrations) > 1) 
                for treatment = 2 : numel(concentrations)
                    finalJavaArray(treatment) = jArray{treatment};
                end
            end
        end
        
        function string = treatmentsAsStringArray(treatments)
            import java.lang.*;
            string = javaArray( 'java.lang.String', size(treatments, 2));
            for treatment = 1 : size(treatments, 2)
                string(treatment) = java.lang.String(treatments{treatment});
            end           
        end
    end
end