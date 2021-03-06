classdef SBToolboxExporter <  ExportPanelController
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        tableHandle = [];
        experimentParamsNames = [];
        experimentStateOrParam = [];
        experimentParamNameTable = []; % can either be 'state' or 'param'
        includeParameter = [];
        includeRedundantParameters = false;
        outputTableStruct = [];
        groups = [];
        loadingBar = [];
        prefix = '';
        suffix = '';
        outputValue = [];
        data = [];
        ultracorrect = 0;
    end
    
    methods
        function this = SBToolboxExporter()
            
        end
        
        function setIncludeRedundantParameters(this, includeRedundantParameters)
            this.includeRedundantParameters = includeRedundantParameters;
        end
        
        function includeRedundantParameters = getIncludeRedundantParameters(this)
            includeRedundantParameters = this.includeRedundantParameters;
        end
        
        function setUltracorrect(this, value)
           this.ultracorrect = value; 
        end
        
        function ultracorrect = getUltracorrect(this)
           ultracorrect = this.ultracorrect; 
        end
        
        function addLoadingBar(this, loadingBar)
            this.loadingBar = loadingBar;
        end
        
        function setPrefix(this, prefix)
            this.prefix = prefix;
            this.updatePrefixAndSuffixInTable();
        end
        
        function setSuffix(this, suffix)
           this.suffix = suffix;
           this.updatePrefixAndSuffixInTable();
        end
        
        function addExperiment(this, experiment, varargin)
            this.experiment = experiment;
            this.experimentParamsNames = this.experiment.getTreatments();
            for i = 1 : numel(this.experimentParamsNames)
               this.experimentStateOrParam{i} = 'state'; 
            end
            treatments = this.convertToCellArrayOfStrings(this.experiment.getTreatments());
            userDefNames = MIDAS2SBNameManager.getMIDASChannelNames(treatments);
            stateOrParam = MIDAS2SBNameManager.getDefaultStateOrParam(treatments);
            include = MIDAS2SBNameManager.getDefaultInclude(treatments);
            this.includeParameter = include';
            data = [treatments', userDefNames', num2cell(strcmp(stateOrParam, 'state')'), num2cell(strcmp(stateOrParam, 'param')'), include'];
            set(this.experimentParamNameTable, 'data', data);
        end
      
        function subgroups = getSubgroupsOfGroup(this, group)
            subgroups = cell(0,0);
            for subgroup = this.subgroupStartValue : numel(this.groups{group})
                if isfield(this.outputTableStruct{group}{subgroup}, 'success') && isequal(this.outputTableStruct{group}{subgroup}.success, 1)
                    subgroups{end+1} = subgroup;
                end
            end
        end
        
        function subgroupNames = getSubgroupNamesOfGroup(this, group)
            subgroupNames = cell(0,0);
            for subgroup = this.subgroupStartValue : numel(this.groups{group})
                if isfield(this.outputTableStruct{group}{subgroup}, 'success') && isequal(this.outputTableStruct{group}{subgroup}.success, 1)
                    subgroupNames{end+1} = this.subgroupNames{group}{subgroup};
                end
            end
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
        
        function getNewExperimentStateOrParam(this)
            data = get(this.experimentParamNameTable, 'Data');
            for i = 1 : numel(data(:, 3))
                if isequal(data(i, 3), {1}) && strcmp(this.experimentStateOrParam{i}, 'param')
                    this.experimentStateOrParam{i} = 'state';
                    data(i, 4) = {false};
                elseif isequal(data(i, 4), {1}) && strcmp(this.experimentStateOrParam{i}, 'state')
                    this.experimentStateOrParam{i} = 'param';
                    data(i, 3) = {false};
                elseif isequal(data(i, 3), {0}) && isequal(data(i, 4), {0}) && strcmp(this.experimentStateOrParam{i}, 'state')
                    data(i, 3) = {true};
                elseif isequal(data(i, 3), {0}) && isequal(data(i, 4), {0}) && strcmp(this.experimentStateOrParam{i}, 'param')
                    data(i, 4) = {true};
                end
            end
            set(this.experimentParamNameTable, 'Data', data);
        end
        
        function getNewExperimentIncludes(this)
            data = get(this.experimentParamNameTable, 'Data');
            for i = 1 : numel(data(:, 5))               
                this.includeParameter{i} = data(i, 5);
            end
            set(this.experimentParamNameTable, 'Data', data);
        end
        
        function updatePrefixAndSuffixInTable(this)
            try
                groupNames = this.experiment.getGroups();
                for group = 1 : size(this.data, 2)
                    for subgroup = this.subgroupStartValue : numel(this.data{group})
                        this.outputTableStruct{group}{subgroup}.path = [this.prefix, this.outputValue,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}, this.suffix];
                    end
                end
            catch
                
            end
        end
        
        function calculateNewTable(this, exportMode, outputVariable)
           this.experiment = this.experimentSimplifier.simplifyEventsAndStartingConditions();
           [data, this.groups] = this.calculationMethod.calculate(this.experiment, this.groupStructure, this.sharedBlankStructure, this.timewiseBlankStructure);
           if isequal(this.subgroupNames, [])
                this.subgroupNames = generateStandardSubgroupNames(data, 1);
           end
           channelNames = this.calculationMethod.getChannelNames();
           this.data = this.mergeOrAverage(data, exportMode);
           this.outputValue = outputVariable{1};
           for i = 2 : numel(outputVariable)
              this.outputValue = [this.outputValue, '_', outputVariable{i}]; 
           end
           
           this.convertDataToSBToolboxFormat(this.data, this.groups, channelNames, outputVariable, exportMode);

        end
        
        function paramNames = readParamsNames(this)
           data = get(this.experimentParamNameTable, 'data'); 
           paramNames = data(:, 2);          
        end
        
        function exportData = mergeOrAverage(this, data, exportMode)
            this.experimentParamsNames = this.readParamsNames();
            timePoints = this.timeController.getCycleTimes();
            switch exportMode
                case 'Average'
                    for group = 1 : numel(data)
                        for subgroup = this.subgroupStartValue : numel(data{group})                            
                            for channel = 1 : numel(data{group}{subgroup}{1})
                                measurements = [];
                                for subgroupElement = 1 : numel(data{group}{subgroup})
                                    measurements = [measurements, data{group}{subgroup}{subgroupElement}{channel}];
                                end
                                cycles = this.experiment.getNumberOfCycles();
                                exportData{group}{subgroup}.minimum{channel} = min(measurements', [], 1)';
                                exportData{group}{subgroup}.maximum{channel} = max(measurements', [], 1)';
                                exportData{group}{subgroup}.average{channel} = mean(measurements', 1)';
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
                                        if strcmp(this.experimentStateOrParam{treatment}, 'state')
                                            exportData{group}{subgroup}.initialConditions{treatment} = [this.experimentParamsNames{treatment},'(0) = ',num2str(concentrationsOfWell{treatment})];
                                        elseif strcmp(this.experimentStateOrParam{treatment}, 'param')
                                            exportData{group}{subgroup}.initialConditions{treatment} = [this.experimentParamsNames{treatment},' = ',num2str(concentrationsOfWell{treatment})];
                                        end                                                                      
                                    end
                                end
                            end
                        end
                    end
                case 'Merge'
                    for group = 1 : numel(data)
                        for subgroup = this.subgroupStartValue : numel(data{group})
                            
                            for channel = 1 : numel(data{group}{subgroup}{1})
                                measurements = [];
                                for subgroupElement = 1 : numel(data{group}{subgroup})
                                    measurements = data{group}{subgroup}{subgroupElement}{channel};
                                    cycles = this.experiment.getNumberOfCycles();
                                    exportData{group}{subgroup}{subgroupElement}.minimum{channel} = measurements;
                                    exportData{group}{subgroup}{subgroupElement}.maximum{channel} = measurements;
                                    exportData{group}{subgroup}{subgroupElement}.average{channel} = measurements;
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
                                        if strcmp(this.experimentStateOrParam{treatment}, 'state')
                                            exportData{group}{subgroup}{1}.initialConditions{treatment} = [this.experimentParamsNames{treatment},'(0) = ',num2str(concentrationsOfWell{treatment})];
                                        elseif strcmp(this.experimentStateOrParam{treatment}, 'param')
                                            exportData{group}{subgroup}{1}.initialConditions{treatment} = [this.experimentParamsNames{treatment},' = ',num2str(concentrationsOfWell{treatment})];
                                        end 
                                    end                            
                                end
                            end
                        end
                    end                
            end
        end
        
        function showTableData(this, group, subgroup)
            data = this.outputTableStruct{group}{subgroup}.SBTable;
            this.tableHandle.setData(data);
            this.tableHandle.setEditable(0, false);
            for column = 1 : size(data, 2)-1
                this.tableHandle.setEditable(column, true);
            end
            %set(this.tableHandle, 'Data', data, 'ColumnEditable', [false true(1,size(data, 2)-1)]);
        end
        
        function sendTableToWorkspace(this, group, subgroup)            
            assignin('base', ['Aparecium_SB_Table_group', num2str(group), '_', num2str(subgroup - 1)] , this.outputTableStruct{group}{subgroup}.SBTable);
        end
        
        function exportWithDialogue(this)
            fileChooser = FileChooser();
            startingPath = fileChooser.chooseSBToolboxFolderSave();
            folderPath = uigetdir(startingPath, 'Select destination folder (should be named Experiments)');
            this.exportWithName(folderPath);
            fileChooser.registerSBToolboxFolderSavePath(folderPath)
        end
        
        function exportWithName(this, folderName)

            FilePath = folderName;
            groupNames = this.experiment.getGroups();
            this.loadingBar.vizualize();
            eventTimes = this.experiment.getEventTimes();
            for well = 1 : numel(eventTimes)
               eventTimes{well} = eventTimes{well}*this.timeController.getUnitConversionConstant();
            end
            for group = 1 : numel(this.groups)
                for subgroup = this.subgroupStartValue : numel(this.groups{group})
                    this.loadingBar.setLoadingBarPercent( 100* (((group-1)/numel(this.groups))+(subgroup-1)/(numel(this.groups{group})*numel(this.groups))));
                    outputValue = this.outputTableStruct{group}{subgroup}.outputValue;
                    mkdir(FilePath,[this.prefix, outputValue, '_Group_', groupNames{group}, '_', this.subgroupNames{group}{subgroup}, this.suffix]);
                    tempFilePath = [FilePath,'\',this.prefix, outputValue,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}, this.suffix];
                    outputFilenameMIDAS = [tempFilePath, '\', this.outputTableStruct{group}{subgroup}.path, '.xls'];
                    outputFilenameEXP = [tempFilePath, '\', this.outputTableStruct{group}{subgroup}.path, '.exp'];
                    initialConditions = this.outputTableStruct{group}{subgroup}.initialConditions;
                    representingWellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{1}); 
                    concentrationChangeEvent = this.experiment.getConcentrationChangeEvents();
                    expFileWriter(this.outputTableStruct{group}{subgroup}.path, initialConditions, representingWellIndex, concentrationChangeEvent, eventTimes, this.experimentParamsNames, this.experimentStateOrParam, outputFilenameEXP, this.includeParameter, 'file', this.includeRedundantParameters)
                    xlswrite(outputFilenameMIDAS, this.outputTableStruct{group}{subgroup}.SBTable);
                end
            end
            this.loadingBar.devizualize();
        end
        
        function updateExperimentParamNameTable(this)
            originalParameterNames =  this.experiment.getTreatments();
            tableData = {originalParameterNames', this.experimentParamsNames'};
            set(this.experimentParamNameTable, 'data', tableData);
        end
        
        function convertDataToSBToolboxFormat(this, data, groups, channelNames, outputValue, exportMode)
            groupNames = this.experiment.getGroups();
            fastKinetics = this.experiment.getFastKinetics();
            requestedChannelIndices = [];
            possibleChannelNames = this.calculationMethod.getChannelNames();
            for index = 1 : numel(outputValue)
               requestedChannelIndices(end + 1) = find(strcmp(possibleChannelNames, outputValue{index}) == 1);
            end
            
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    this.outputTableStruct{group}{subgroup}.success = 0;
                    
                    nameInfo = outputValue{1};
                    for i = 2 : numel(outputValue)
                        nameInfo = [nameInfo,'_',outputValue{2}];
                    end
                    nameInfo = [nameInfo,'_Group_',groupNames{group}, '_', this.subgroupNames{group}{subgroup}];
                    
                    noteInfo={'no user defined notes'};
                    componentNotes = {'note for time'};
                    components = {'time'};
                    for channelIndex = 1 : numel(outputValue)
                        componentNotes=[componentNotes,{['note for ',outputValue{channelIndex}]},{['note for ',outputValue{channelIndex},'+']},{['note for ',outputValue{channelIndex},'+']}];
                        components=[components, {outputValue{channelIndex}},{[outputValue{channelIndex},'+']},{[outputValue{channelIndex},'-']}];
                    end
                    %components=[{strcat('time/', this.timeController.getTimeUnit())},{outputValue},{[outputValue,'+']},{[outputValue,'-']}];
                    Header = cell(4, numel(components) + 1);
                    Header(1, 1) = {'Name'};
                    Header(1, 2) = {nameInfo};
                    Header(2, 1) = {'Notes'};
                    Header(2, 2) = noteInfo;
                    Header(3, 1) = {'Componentnotes'};
                    Header(3, 2 : end) = componentNotes;
                    Header(4, 1) = {'Components'};
                    Header(4, 2 : end) = components;

                    numberOfCycles = this.timeController.getNumberOfCycles();
                    cyclesInUse = this.timeController.getCyclesInUse();
                    timeMoments = this.timeController.getCycleTimes();
                    %time = data{group}{subgroup}.timePoints;
                    %timepoints = numel(time);

                    experimentData(6,5) = {''};
                    
                    if isequal(exportMode, 'Merge')
                        row = 0;
                        numberOfRows = 0;
                        for timeIndex = 1 : numberOfCycles;
                            for subgroupElement = 1 : numel(this.groups{group}{subgroup})
                                numberOfRows = numberOfRows + 1;
                            end
                        end
                        numberOfRows = numberOfRows + this.ultracorrect;
                        experimentData = cell(numberOfRows, 2 + 3*numel(outputValue));
                        for channelIndex = 1 : numel(outputValue)
                            row = 0;
                            
                            if isequal(this.ultracorrect, 1)
                                row = row + 1;
                                experimentData{row, 2} = 0;
                                experimentData{row, (channelIndex - 1)*3+3} = 0;
                                experimentData{row, (channelIndex - 1)*3+4} = 0;
                                experimentData{row, (channelIndex - 1)*3+5} = 0; 
                            end
                            
%                             for timeIndex = 1 : numberOfCycles; % for now, assume that all wells were measured for equal number of cycles                          
%                                 for subgroupElement = 1 : numel(this.groups{group}{subgroup})
%                                     row = row + 1;
%                                     if isequal(channelIndex, 1)
%                                         experimentData{row, 2} = data{group}{subgroup}{subgroupElement}.timePoints(cyclesInUse(timeIndex));
%                                     end
%                                     experimentData{row, (channelIndex - 1)*3+3} = data{group}{subgroup}{subgroupElement}.average{requestedChannelIndices(channelIndex)}(cyclesInUse(timeIndex));
%                                     experimentData{row, (channelIndex - 1)*3+4} = data{group}{subgroup}{subgroupElement}.maximum{requestedChannelIndices(channelIndex)}(cyclesInUse(timeIndex));
%                                     experimentData{row, (channelIndex - 1)*3+5} = data{group}{subgroup}{subgroupElement}.minimum{requestedChannelIndices(channelIndex)}(cyclesInUse(timeIndex)); 
%                                  end
%                             end
                         
                            for subgroupElement = 1 : numel(this.groups{group}{subgroup})
                                
                                if isequal(channelIndex, 1)
                                    experimentData(this.ultracorrect+subgroupElement : numel(this.groups{group}{subgroup}): end, 2) = num2cell(data{group}{subgroup}{subgroupElement}.timePoints(cyclesInUse(:)));
                                end
                                experimentData(this.ultracorrect+subgroupElement : numel(this.groups{group}{subgroup}): end, (channelIndex - 1)*3+3:(channelIndex - 1)*3+5) = num2cell([data{group}{subgroup}{subgroupElement}.average{requestedChannelIndices(channelIndex)}(cyclesInUse(:)),...
                                data{group}{subgroup}{subgroupElement}.maximum{requestedChannelIndices(channelIndex)}(cyclesInUse(:)),...
                                data{group}{subgroup}{subgroupElement}.minimum{requestedChannelIndices(channelIndex)}(cyclesInUse(:))]); 
                            end
                        end
                    elseif isequal(exportMode, 'Average')
                        try
                            time = data{group}{subgroup}.timePoints;
                            timepoints = numel(time);
                            experimentData = cell(numberOfCycles, 2 + 3*numel(outputValue));
                            
                            for channelIndex = 1 : numel(outputValue)
                                row = 0;
                                if isequal(this.ultracorrect, 1)
                                    row = row + 1;
                                    experimentData{row, 2} = 0;
                                    experimentData{row, (channelIndex - 1)*3+3} = 0;
                                    experimentData{row, (channelIndex - 1)*3+4} = 0;
                                    experimentData{row, (channelIndex - 1)*3+5} = 0; 
                                end
                                if isequal(channelIndex, 1)
                                    experimentData(1+this.ultracorrect : numberOfCycles + this.ultracorrect, 2) = num2cell(time(cyclesInUse(:)));
                                end
                                experimentData(1+this.ultracorrect : numberOfCycles + this.ultracorrect,(channelIndex - 1)*3+3:(channelIndex - 1)*3+5) = num2cell([data{group}{subgroup}.average{requestedChannelIndices(channelIndex)}(cyclesInUse(:)),...
                                data{group}{subgroup}.maximum{requestedChannelIndices(channelIndex)}(cyclesInUse(:)),...
                                data{group}{subgroup}.minimum{requestedChannelIndices(channelIndex)}(cyclesInUse(:))]);                                                                                                 
                            end
                        catch MException
                           disp(['Could not create table for group ', num2str(group),  ' ', this.subgroupNames{group}{subgroup}]);   
                        end
                    end
                    
                    % loop and remove all measurement times where all
                    % measurement values are NaN
                    experimentData(isnan(sum(cell2mat(experimentData(:, 3:end)), 2)), :) = [];
                    experimentData(1,1) = {'Values'};
          
                    this.outputTableStruct{group}{subgroup}.SBTable = [Header;experimentData];
                    this.outputTableStruct{group}{subgroup}.path = [this.prefix, nameInfo, this.suffix];
                    if isequal(exportMode, 'Merge')
                        this.outputTableStruct{group}{subgroup}.initialConditions = data{group}{subgroup}{1}.initialConditions;
                    elseif isequal(exportMode, 'Average')
                        this.outputTableStruct{group}{subgroup}.initialConditions = data{group}{subgroup}.initialConditions;
                    end
                    this.outputTableStruct{group}{subgroup}.outputValue = '';
                    for i = 1 : numel(outputValue)
                        this.outputTableStruct{group}{subgroup}.outputValue = [this.outputTableStruct{group}{subgroup}.outputValue, outputValue{i}];
                    end
                    this.outputTableStruct{group}{subgroup}.groups = groups;
                    this.outputTableStruct{group}{subgroup}.group = group;
                    this.outputTableStruct{group}{subgroup}.subgroup = subgroup;

                    this.outputTableStruct{group}{subgroup}.experimentParamsNames = this.experimentParamsNames;
                    this.outputTableStruct{group}{subgroup}.success = 1;       
                end
            end
        end 
        
        function handles = cellEditCallbackFunction(this, hObject, eventdata, handles, group, subgroup)
           data = get(hObject, 'data');
           if (isequal(eventdata.Indices(1), 3) && eventdata.Indices(2)>1 ) || ( isequal(eventdata.Indices(1), 2) && isequal(eventdata.Indices(2), 2))...
                   || ( isequal(eventdata.Indices(1), 1) && isequal(eventdata.Indices(2), 2))
           
               this.outputTableStruct{group}{subgroup}.SBTable = data;
           else
               data{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
               set(hObject, 'data', data);
               this.outputTableStruct{group}{subgroup}.SBTable = data;
           end
        end 
        
        function sendToWorkspace(this)
            assignin('base', 'SBStructure', this.outputTableStruct);
        end
        
        function addToExistingProject(this)
            [fileName, filePath] = uigetfile('*.iqmp', 'Choose project where to add current experiments');
            project = IQMprojectSB([filePath, fileName]);
            
            % do not add new models, otherwise the models list will be
            % overcrowded with many duplicate models in the project.
            %project = this.createIQMmodels(project);
            % add experiments to the project
            [project, counterStart] = this.createIQMexperiments(project);
            % add measurement data to the project
            project = this.createIQMmeasurements(project, counterStart);
            properName = regexprep(fileName, '.iqmp', '');
            eval([properName, '=project']);
            save([filePath, fileName], properName);
        end
        
        function toSBProject(this)
            % create the project
            % currently no model will be attached to the raw project
            project = IQMprojectSB();
            project = this.createIQMmodels(project);
            % add experiments to the project
            project = this.createIQMexperiments(project);
            % add measurement data to the project
            project = this.createIQMmeasurements(project, 1);
            
            IQMparamestGUI(project);
        end
        
        function project = createIQMmodels(this, project)
            models = {};
            modeltypes = [];
            fileChooser = FileChooser();
            modelLibraryPath = fileChooser.getModelLibraryPath();
            files = findfiles('*.txt', modelLibraryPath);
            files = [files; findfiles('*.txtbc', modelLibraryPath)];
            files = [files; findfiles('*.xml', modelLibraryPath)];
            for k=1:length(files),
                filename = files{k};
                % check correct extensions (.txt, .txtbc, .xml)
                [a,b,EXT] = fileparts(filename);
                if strcmp(EXT,'.txt') || strcmp(EXT,'.txtbc') || strcmp(EXT,'.xml'),
                    try
                        % import models
                        models{end+1} = IQMmodel(filename);
                        if strcmp(EXT,'.txt'),
                            modeltypes(end+1) = 0;  % txt
                        else
                            modeltypes(end+1) = 1;  % txtbc or SBML
                        end
                    catch
                        disp(sprintf('Warning: Error during model import: %s',lasterr));
                    end

                end
            end
            
            projectAsStruct = IQMstruct(project);
            prevModels = projectAsStruct.models;
            prevModelTypes = projectAsStruct.modeltypes;
            if strcmp(prevModels, '')
                project.models = models;
            else
                project.models = [prevModels, models]; 
            end
            
            if strcmp(prevModelTypes, '')
                project.modeltypes = modeltypes;
            else
                project.modeltypes = [prevModelTypes, modeltypes]; 
            end
        end
        
        function project = createIQMmeasurements(this, project, counterStart)              
            counter = counterStart;

            groupNames = this.experiment.getGroups();
            for group = 1 : numel(this.groups)
                for subgroup = this.subgroupStartValue : numel(this.groups{group})                 
                    [measurementStructure, errorMsg] = this.processData(this.outputTableStruct{group}{subgroup}.SBTable, 1, []);
                    project.experiments(counter).measurements = {IQMmeasurement(measurementStructure)};
                    counter = counter + 1;
                end
            end
        end
        
        function [project, counterStart] = createIQMexperiments(this, project)            
            eventTimes = this.experiment.getEventTimes();
            for well = 1 : numel(eventTimes)
               eventTimes{well} = eventTimes{well}*this.timeController.getUnitConversionConstant(); 
            end
            
            projectAsStruct = IQMstruct(project);          
            counter = numel(projectAsStruct.experiments) + 1;
            counterStart = counter;
            
            for group = 1 : numel(this.groups)
                for subgroup = this.subgroupStartValue : numel(this.groups{group})
                    outputFilenameEXP = [this.outputTableStruct{group}{subgroup}.path, '.exp'];
                    initialConditions = this.outputTableStruct{group}{subgroup}.initialConditions;
                    representingWellIndex = this.experiment.getIndexOfUsedWell(this.groups{group}{subgroup}{1});
                    concentrationChangeEvent = this.experiment.getConcentrationChangeEvents();
                    project.experiments(counter).experiment = IQMexperiment(expFileWriter(this.outputTableStruct{group}{subgroup}.path, initialConditions, representingWellIndex, concentrationChangeEvent, eventTimes, this.experimentParamsNames, this.experimentStateOrParam, outputFilenameEXP, this.includeParameter, 'struct', this.includeRedundantParameters));                    
                    project.experiments(counter).name = outputFilenameEXP;
                    project.experiments(counter).notes = '';
                    counter = counter + 1;
                end
            end
        end
        
        function [measurementstructure,errorMsg] = processData(this, RAW,sheet,errorMsg)
            % this function is adapted from IQMmeasurement function from
            % IQMTools
            % <<<COPYRIGHTSTATEMENT - IQM TOOLS LITE>>>
            
            % initialize empty measurement structure
            measurementstructure = struct(IQMmeasurement());
            % get size of RAW matrix
            [nrows, ncols] = size(RAW);
            % each identifier needs to appear but only once!
            % furthermore, the identifieres need to appear in the correct order!
            rowName = 0;
            rowNotes = 0;
            rowComponentnotes = 0;
            rowComponents = 0;
            rowValues = 0;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get rows of identifiers and check the order
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for row=1:nrows,
                if ~isnan(RAW{row,1}),
                    if strcmp(strtrim(lower(RAW{row,1})),'name'),
                        rowName = row;
                        if rowNotes+rowComponents+rowComponentnotes+rowValues ~= 0,
                            errorMsg = sprintf('%sIdentifier ''Name'' in sheet %d does not come in correct order.\n',errorMsg,sheet);
                        end
                    end
                    if strcmp(strtrim(lower(RAW{row,1})),'notes'),
                        rowNotes = row;
                        if rowComponents+rowComponentnotes+rowValues ~= 0,
                            errorMsg = sprintf('%sIdentifier ''Notes'' in sheet %d does not come in correct order.\n',errorMsg,sheet);
                        end
                    end
                    if strcmp(strtrim(lower(RAW{row,1})),'componentnotes'),
                        rowComponentnotes = row;
                        if rowComponents + rowValues ~= 0,
                            errorMsg = sprintf('%sIdentifier ''Componentnotes'' in sheet %d does not come in correct order.\n',errorMsg,sheet);
                        end
                    end
                    if strcmp(strtrim(lower(RAW{row,1})),'components'),
                        rowComponents = row;
                        if rowValues ~= 0,
                            errorMsg = sprintf('%sIdentifier ''Components'' in sheet %d does not come in correct order.\n',errorMsg,sheet);
                        end
                    end
                    if strcmp(strtrim(lower(RAW{row,1})),'values'),
                        rowValues = row;
                    end
                    % check if all identifiers found then break the loop
                    if rowName*rowNotes*rowComponents*rowComponentnotes*rowValues ~= 0,
                        break;
                    end
                end
            end
            % check if all identifiers present
            if rowName*rowNotes*rowComponents*rowComponentnotes*rowValues == 0,
                errorMsg = sprintf('%sAt least one identifier is missing in in sheet %d.\n',errorMsg,sheet);
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Name
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Name only one line but several columns
            name = '';
            for col=2:ncols,
                if ~isnan(RAW{rowName,col}),
                    if ischar(RAW{rowName,col}),
                        name = sprintf('%s %s',name,RAW{rowName,col});
                    end
                else
                    break;
                end
            end
            measurementstructure.name = strtrim(name);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Notes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Notes several lines and several columns
            notes = '';
            spaceYes = 1;
            for row=rowNotes:rowComponentnotes-1,
                for col=2:ncols,
                    if ~isnan(RAW{row,col}),
                        if ischar(RAW{row,col}),
                            if spaceYes,
                                notes = sprintf('%s %s',notes,strtrim(RAW{row,col}));
                            else
                                notes = sprintf('%s%s',notes,strtrim(RAW{row,col}));
                                spaceYes = 1;
                            end
                        end
                    end
                end
                notes = sprintf('%s\n',strtrim(notes)); 
                spaceYes = 0;
            end
            measurementstructure.notes = notes;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Components
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            components = {};
            for col = 2:ncols,
                if ~isnan(RAW{rowComponents,col}),
                    components{end+1} = regexprep(RAW{rowComponents,col},' ','');
                else
                    break;
                end
            end
            % find 'time' component
            timeindex = strmatchIQM('time',components,'exact');
            % initialize help structure for min max values (error bounds) + components
            errorbounddata = struct('name',{},'type',{},'indexvalues',{});
            componentdata = struct('name',{},'indexvalues',{});
            % fill in component names/formulas in structure
            for k=1:length(components),
                if k ~= timeindex,
                    % check if componentname defines an upper or lower bound
                    if ~isempty(regexp(components{k},'[+]')),
                        % component defines an upper bound
                        errorbounddata(end+1).name = regexprep(components{k},'\W','');
                        errorbounddata(end).type = 'max';
                        errorbounddata(end).indexvalues = k;
                    elseif ~isempty(regexp(components{k},'[-]')),
                        % component defines a lower bound
                        errorbounddata(end+1).name = regexprep(components{k},'\W','');
                        errorbounddata(end).type = 'min';
                        errorbounddata(end).indexvalues = k;
                    else
                        measurementstructure.data(end+1).name = components{k};
                        componentdata(end+1).name = components{k};
                        componentdata(end).indexvalues = k;
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Componentnotes
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            index = 1;
            for k = 1:length(componentdata)
                col = componentdata(k).indexvalues+1;
                if ~isnan(RAW{rowComponentnotes,col}),
                    if ischar(RAW{rowComponentnotes,col}),
                        componentnotes = RAW{rowComponentnotes,col};
                        measurementstructure.data(k).notes = strtrim(componentnotes);
                    end
                else
                    measurementstructure.data(k).notes = '';
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Values and errorbounds
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get values matrix
            try
                valuesmatrix = cell2mat(RAW(rowValues:nrows,2:length(components)+1));
            catch
                error('Please check the datatypes in the values section of the Excel file.');
            end
            time = valuesmatrix(:,timeindex);
            % check for first occurrence of NaN in time vector ... then cut off.
            indexNaN = find(isnan(time)==1);
            if isempty(indexNaN),
                numbertimesteps = length(time);
            else
                numbertimesteps = indexNaN(1)-1;
            end
            measurementstructure.time = time(1:numbertimesteps);
            % assign the measurement data into the structure
            % assign the measurement data into the structure
            for k=1:length(componentdata),
                measurementstructure.data(k).values = valuesmatrix(1:numbertimesteps,componentdata(k).indexvalues);
            end
            % assign the error bound data if present (and corresponding component
            % present too ... otherwise warning).
            for k=1:length(errorbounddata),
                indexcomponent = strmatchIQM(errorbounddata(k).name,{componentdata.name},'exact');
                if isempty(indexcomponent),
                    warning('Component ''%s'' has given error bound but does not exist in the data file.',errorbounddata(k).name);
                else
                    if strcmp(errorbounddata(k).type,'max'),
                        measurementstructure.data(indexcomponent).maxvalues = valuesmatrix(1:numbertimesteps,errorbounddata(k).indexvalues);
                    else
                        measurementstructure.data(indexcomponent).minvalues = valuesmatrix(1:numbertimesteps,errorbounddata(k).indexvalues);
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Fill the nonavailable errorbounds with NaN
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for k=1:length(measurementstructure.data),
                if isempty(measurementstructure.data(k).minvalues) || isempty(measurementstructure.data(k).maxvalues),
                    measurementstructure.data(k).maxvalues = NaN(size(measurementstructure.data(k).values));
                    measurementstructure.data(k).minvalues = NaN(size(measurementstructure.data(k).values));
                end
            end
        end
    end
end