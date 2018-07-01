classdef PipetingSimulatorInterface < handle
    properties
        microPlate
        javaMicroPlate
        PipetingSimulator
        experiment
        widthOfFrame = 1300;
        heightOfFrame = 800;
        isPlateSimulatorInitialized = 0;
        installationAlreadyAttempted = 0;
        consistencyChecker;
        
        
    end
    methods
        function this = PipetingSimulatorInterface()
            
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
        
        function openExistingPipetingSimulator(this)
            
        end
        
        function simPlateHandle = generatePipetingSimulator(this, handles)
            if isempty(this.consistencyChecker) || ~this.consistencyChecker.check(this.experiment)
                try
                    load javapath
                    if(strcmp(Path(end), '\'))
                       Path(end) = [];
                    end
                    javaaddpath(strcat(Path,'\Sim plate.jar'), '-end')
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
                    %measurements = this.experiment.getMeasurements();
                    %groups = this.experiment.getGroups();
                    mode = '';
                    this.PipetingSimulator = pipetingSimulator.PipetingSimulator(treatments, concentrations, units, mode, wellNames, inUse, cycles);
                    
                    this.addCallbackToVolumeCalc();
                    this.experiment.setHasChanged(0);
                catch
                    if ~this.installationAlreadyAttempted
                        result = questdlg('It seem like Java installation has not been performed. Would you like to install Java from current folder?');
                        pause(0.5); % without this pause the program seems to successfully install java but crash right after it.
                        switch result
                            case 'Yes'
                                try                            
                                    this.installationAlreadyAttempted = 1;
                                    toolboxLocation = fileparts(mfilename('fullpath'));
                                    Java_Installation
                                    this.generatePipetingSimulator(handles);
                                    successBox('Java installation completed', 'Success');

                                catch

                                end
                            case 'No'
                                warndlg('Java installation was not successful');
                        end               
                    else
                        warndlg('Java installation was not successful');   
                    end
                end
            else

            end
            this.PipetingSimulator.setVisible(true);
            [a, simPlateHandle] = javacomponent(this.PipetingSimulator, [0, -72 , 1300, 700], handles.figure1);
            this.isPlateSimulatorInitialized = 1;
            this.consistencyChecker = PipetingSimulatorConsistencyChecker(this.experiment);
        end
        
        function addCallbackToVolumeCalc(this)
           callbackHandle = @volumeLinearEquationsSolver.calculateVolumes;
           doneHandler(this.PipetingSimulator.getCalculateVolumesButton(), this, callbackHandle);
        end
        
        function addExperiment(this, experiment)
            this.experiment = experiment;
            experiment.setHasChanged(1);
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
                counter = counter + 1;
                treatments = this.PlateSimulator.getTreatmentStructure(event);
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
            this.PipetingSimulator.regeneratePlateSimulatorFromEventsStructure(eventsStructure, wells, eventTimes);
        end
        
        function pipetingTable = createPipetingTable(this)
            eventNames = cell(this.PipetingSimulator.getEventLabels());
            %inContainerNames = cell(this.PipetingSimulator.getInContainerNames());
            %outContainerNames = cell(this.PipetingSimulator.getOutContainerNames());
            %inWellNames = cell(this.PipetingSimulator.getInWellStrings());
            %outWellNames = cell(this.PipetingSimulator.getOutWellStrings());
            %volumes = cell(this.PipetingSimulator.getVolumes());
            pipetingTable = eventNames;
        end
        
        function sequence = getPipetingSequence(this)
            inContainerNames = cell(this.PipetingSimulator.getEventInContainers());
            outContainerNames = cell(this.PipetingSimulator.getEventOutContainers());
            inWellNames = cell(this.PipetingSimulator.getEventInWells());
            outWellNames = cell(this.PipetingSimulator.getEventOutWells());
            if size(outWellNames, 2) > 1
                newOutWellNames = cell(size(outWellNames, 1), 1);
                for eventIndex = 1 : size(outWellNames, 1)
                   newOutWellNames{eventIndex} = outWellNames(1,:)';
                end
                outWellNames = newOutWellNames;
            end
            volumes = cell(this.PipetingSimulator.getEventVolumes());
            sequence = cell(0,0);
            pipettes = {
                'E1-ClipTip 1-ch 0.5-12.5 µl'...
                'E1-ClipTip 1-ch 2-125 µl'...
                'E1-ClipTip 1-ch 10-300 µl'...
                'E1-ClipTip 1-ch 15-1250 µl'...
                'E1-ClipTip 8-ch 0.5-12.5 µl'...
                'E1-ClipTip 8-ch 2-125 µl'...
                'E1-ClipTip 8-ch 10-300 µl'...
                'E1-ClipTip 8-ch 15-1250 µl'...
                'E1-ClipTip 12-ch 0.5-12.5 µl'...
                'E1-ClipTip 12-ch 2-125 µl'...
                'E1-ClipTip 12-ch 10-300 µl'...
                'E1-ClipTip 12-ch 15-1250 µl'...
                'E1-ClipTip 16-ch 0.5-12.5 µl'...
                'E1-ClipTip 16-ch 1-30 µl'...
                'E1-ClipTip 16-ch 2-125 µl'...
                'E1-ClipTip Equalizer 384 6-ch 15-1250 µl'...
                'E1-ClipTip Equalizer 384 8-ch 0.5-12.5 µl'...
                'E1-ClipTip Equalizer 384 8-ch -30 µl'...
                'E1-ClipTip Equalizer 8-ch 2-125 µl'...
                'E1-ClipTip Equalizer 384 8-ch 2-125 µl'...
                'E1-ClipTip Equalizer 8-ch 10-300 µl'...
                'E1-ClipTip Equalizer 8-ch 15-1250 µl'...
                'E1-ClipTip Equalizer 384 12-ch 0.5-12.5 µl'...
                'E1-ClipTip Equalizer 384 12-ch 1-30 µl'...
                'E1-ClipTip Equalizer 384 12-ch 2-125 µl'};
            channels = [1 1 1 1 8 8 8 8 12 12 12 12 16 16 16 6 8 8 8 8 8 8 12 12 12];
            [Selection, ok] = listdlg('ListString' ,pipettes,'ListSize',[600 300],'SelectionMode','single','Name','Select pipette');
            if ~ok
                return
            end
            maxPipettingChannels = channels(Selection);
            speed = 10;
            excess = 0;
            for eventNumber = 1 : numel(inContainerNames)
                pipettingChannels = max([numel(inWellNames{eventNumber}), numel(outWellNames{eventNumber})]);
                if pipettingChannels > maxPipettingChannels
                    error('Impossible pipeting sequence with this pipette. Use another pipette with more channels or change the pipetting sequence');
                end
                
                if iscell(outWellNames{eventNumber})
                    
                else
                    outWellNames{eventNumber} = {outWellNames{eventNumber}};% wrap to another cell for consistensy reasons
                end
                
                if isequal(pipettingChannels, 1)                
                    for outWellIndex = 1 : numel(outWellNames{eventNumber})
                        noteText = ['In: ', inContainerNames{eventNumber},' ', inWellNames{eventNumber}, ',Out: ', outContainerNames{eventNumber},' ', outWellNames{eventNumber}{outWellIndex}];     

                        sequence{end + 1} = definePipettingStep(speed, str2double(volumes{eventNumber}), excess, noteText);
                    end
                elseif isequal(pipettingChannels, numel(inWellNames{eventNumber})) || isequal(pipettingChannels, numel(outWellNames{eventNumber}))
                    
                    if isequal(pipettingChannels, numel(inWellNames{eventNumber})) && isequal(pipettingChannels, numel(outWellNames{eventNumber}))
                        % usual case when dilutions or pipetting is done
                        % from one row to another
                        
                        % search for common row in inWells
                        
                        [inRowName, inRowSuccess, minInRow, maxInRow] = PipetingSimulatorInterface.findCommonRow(inWells);                       
                        
                        % search for common column in inWells
                        
                        [inColumnIndex, inColSuccess, minInCol, maxInCol] = PipetingSimulatorInterface.findCommonColumn(inWells);
                        
                        if inColSuccess && inRowSuccess
                            %all well names are the same or it is one
                            %channel pipette, something is wrong
                            error('Impossible pipetting event: pipetting in form several wells with the same name');
                        elseif inColSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                inSentence = ['In: ', inContainerNames{eventNumber},' col ', num2str(inColumnIndex)];
                            else
                                inSentence = ['In: ', inContainerNames{eventNumber},' col ', num2str(inColumnIndex), ' ', minInRow, '-', maxInRow];
                            end
                        elseif inRowSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                inSentence = ['In: ', inContainerNames{eventNumber} ' row ', inRowName];
                            else
                                inSentence = ['In: ', inContainerNames{eventNumber} ' row ', inRowName, ' ',  minInCol, '-', maxInCol];
                            end
                        else
                            
                        end
                            
                        % search for common row in outWells
                        
                        [outRowName, outRowSuccess, minOutRow, maxOutRow] = PipetingSimulatorInterface.findCommonRow(outWells);
                        
                        % search for common column in outWells
                        
                        [outColumnIndex, outColSuccess, minOutCol, maxOutCol] = PipetingSimulatorInterface.findCommonColumn(outWells);
                        
                        
                        if outColSuccess && outRowSuccess
                            %all well names are the same or it is one
                            %channel pipette, something is wrong
                            error('Impossible pipetting event: pipetting in form several wells with the same name');
                        elseif outColSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' col ',  num2str(inColumnIndex)];
                            else
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' col ',  num2str(inColumnIndex), ' ', minOutRow, '-', maxOutRow];
                            end
                        elseif outRowSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' row ', inRowName];
                            else
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' row ', inRowName, ' ', num2str(minOutCol), '-', num2str(maxOutCol)];
                            end
                        else
                            
                        end
                        
                        noteText = [inSentence, outSentence];                 
                        
                        sequence{end + 1} = definePipettingStep(speed, str2double(volumes{eventNumber}), excess, noteText);
                        
                    elseif isequal(pipettingChannels, numel(inWellNames{eventNumber}))
                        % probably uncommon case where same volume is
                        % pipetted from several wells to one output well
                        % put technically possible
                        
                        % search for common row in inWells
                        
                        [inRowName, inRowSuccess, minInRow, maxInRow] = PipetingSimulatorInterface.findCommonRow(inWells);                       
                        
                        % search for common column in inWells
                        
                        [inColumnIndex, inColSuccess, minInCol, maxInCol] = PipetingSimulatorInterface.findCommonColumn(inWells);
                        
                        if inColSuccess && inRowSuccess
                            %all well names are the same or it is one
                            %channel pipette, something is wrong
                        error('Impossible pipetting event: pipetting in form several wells with the same name');
                        elseif inColSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                inSentence = ['In: ', inContainerNames{eventNumber},' col ', num2str(inColumnIndex)];
                            else
                                inSentence = ['In: ', inContainerNames{eventNumber},' col ', num2str(inColumnIndex), ' ', minInRow, '-', maxInRow];
                            end
                        elseif inRowSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                inSentence = ['In: ', inContainerNames{eventNumber} ' row ', inRowName];
                            else
                                inSentence = ['In: ', inContainerNames{eventNumber} ' row ', inRowName, ' ',  minInCol, '-', maxInCol];
                            end
                        else
                            
                        end
                        
                        if isequal(numel(outWellNames{eventNumber}), 1)
                            outSentence = [',Out: ', outContainerNames{eventNumber},' ', outWellNames{eventNumber}{1}];
                        else
                            error('Impossible pipetting event: in and out wells numbers do not match');
                        end
                        
                        noteText = [inSentence, outSentence];
                        
                        sequence{end + 1} = definePipettingStep(speed, str2double(volumes{eventNumber}), excess, noteText);
                        
                    elseif isequal(pipettingChannels, numel(outWellNames{eventNumber}))
                        % usual case when a whole row or column of a
                        % microplate is filled from reagent reservoir/
                        % channel
                        % (estonian: renn)
                        
                        % search for common row in outWells
                        
                        [outRowName, outRowSuccess, minOutRow, maxOutRow] = PipetingSimulatorInterface.findCommonRow(outWells);
                        
                        % search for common column in outWells
                        
                        [outColumnIndex, outColSuccess, minOutColumn, maxOutColumn] = PipetingSimulatorInterface.findCommonColumn(outWells);
                        
                        if outColSuccess && outRowSuccess
                            %all well names are the same or it is one
                            %channel pipette, something is wrong
                            error('Impossible pipetting event: pipetting in form several wells with the same name');
                        elseif outColSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' col ',  num2str(inColumnIndex)];
                            else
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' col ',  num2str(inColumnIndex), ' ', minOutRow, '-', maxOutRow];
                            end
                        elseif outRowSuccess
                            if isequal(pipettingChannels, maxPipettingChannels)
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' row ', inRowName];
                            else
                                outSentence = [',Out: ', outContainerNames{eventNumber}, ' row ', inRowName, ' ', num2str(minOutCol), '-', num2str(maxOutCol)];
                            end
                        else
                            
                        end
                        
                        if isequal(numel(inWellNames{eventNumber}), 1)
                            inSentence = ['In: ', inContainerNames{eventNumber},' ', inWellNames{eventNumber}{1}];
                        else
                            error('Impossible pipetting event: in and out wells numbers do not match');
                        end
                    end
                    
                else
                   warndlg('Sorry. Could now generate a pipetting programme which would correspond to specified pipetting sequence. Try a pipette with different number of channels or see if this problem has been resolved in updated versions of Aparecium');
                end
            end
                
        end
        
        function calculateNewVolumes(this, experimentProtocol)
           this.regeneratePlateSimulatorFromTreatmentStructure(experimentProtocol.treatmentStructure);
           volumeLinearEquationsSolver.calculateVolumes('','',this);
        end
    end
    
    methods(Static)
        
        function newStep = definePipettingStep(speed, volume, excess, noteText)
            % define the notestep
            
            newStep.notestep.text = noteText;
            
            % define the fillstep
            newStep.fillstep.speed.ATTRIBUTE.value = speed;
            newStep.fillstep.speed.CONTENT = [];
            newStep.fillstep.volume.ATTRIBUTE.value = volume;
            newStep.fillstep.volume.CONTENT = [];
            newStep.fillstep.excess.ATTRIBUTE.value = excess;
            newStep.fillstep.excess.CONTENT = [];

            % define the dispensestep
            newStep.dispensestep.speed.ATTRIBUTE.value = speed;
            newStep.dispensestep.speed.CONTENT = [];
            newStep.dispensestep.volume.ATTRIBUTE.value = volume;
            newStep.dispensestep.volume.CONTENT = [];
            newStep.dispensestep.blowout.ATTRIBUTE.value = excess;
            newStep.dispensestep.blowout.CONTENT = []; 
        end
        
        function [rowName, success, minCol, maxCol] = findCommonRow(wells)
            rowFound = 1;
            rowOfFirstWell = regexp(wells{1}, '[A-Z]+', 'match');

            for wellIndex = 2 : numel(wells)
                rowOfWell = regexp(wells{wellIndex}, '[A-Z]+', 'match');
                if strcmp(rowOfWell, rowOfFirstWell)                              

                else
                   rowFound = 0;
                   break; 
                end
            end
            
            if rowFound
                rowName = rowOfFirstWell;
                success = 1;
            else
                rowName = [];
                success = 0;
            end
            
            if success
                columnIndices = zeros(numel(wells), 1);
                for wellIndex = 1 : numel(wells)
                    columnIndices(wellIndex) = str2double(regexp(wells{wellIndex}, '\d*', 'match'));
                end
                minCol = min(columnIndices);
                maxCol = max(columnIndices);
            else
               minCol = [];
               maxCol = [];
            end
        end
        
        function [columnIndex, success, minRow, maxRow] = findCommonColumn(wells)
            columnFound = 1;
            columnOfFirstWell = str2double(regexp(wells{1}, '\d*', 'match'));

            for wellIndex = 2 : numel(wells)
                columnOfWell = str2double(regexp(wells{wellIndex}, '\d*', 'match'));
                if isequal(columnOfWell, columnOfFirstWell)                              

                else
                   columnFound = 0;
                   break;
                end
            end
            if columnFound
                columnIndex =  columnOfFirstWell;
                success = 1;
            else
                columnIndex = [];
                success = 0;
            end
            
            if success
                columnIndices = zeros(numel(wells), 1);
                rowLabels = ExtendedRowLabels();
                for wellIndex = 1 : numel(wells)
                    rowName = regexp(wells{wellIndex}, '[A-Z]+', 'match');
                    columnIndices(wellIndex) = find(strcmp(rowLabels, rowName) == 1);
                end
                minRow = rowLabels{min(columnIndices)};
                maxRow = rowLabels{max(columnIndices)};
            else
               minRow = [];
               maxRow = [];
            end
        end
        
        function finalJavaArray = convertCellToJava2dimStringArray(concentrations)
            load javapath
            import java.lang.*;
            jArray = cell(size(concentrations, 2),1);
            for treatment = 1 : size(concentrations, 2);
               jArray{treatment} = javaArray('java.lang.String', size(concentrations{treatment},2));
               for concentration = 1 : size(concentrations{treatment},2)
                   if isnumeric(concentrations{treatment}(concentration))
                       jArray{treatment}(concentration) = java.lang.String(num2str(concentrations{treatment}(concentration), ['%5.', num2str(floor(-log10(concentrations{treatment}(concentration)))+4),'f']));
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
            finalJavaArray = javaArray('java.lang.String', size(concentrations, 2), 1);
            finalJavaArray(1) = jArray{1};
            if(size(concentrations, 2) > 1) 
                for treatment = 2 : size(concentrations, 2)
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