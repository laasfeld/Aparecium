classdef ExperimentProtocol < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        folderPath;
        toolOfProtocol = 'Gen5Tools';
        experimentName
        plateName
        MIDASChannelNames
        plateHeight = 8;
        plateWidth = 12;
        numberOfChannels = 1;
        plateSimulatorInterface = PlateSimulatorInterface();
        pipetingSimulatorInterface = PipetingSimulatorInterface();
        inputTimeUnit
        dimensionality = 1;
        apareciumExperimentInput = ApareciumExperimentInput();
        createMIDASFile
        MIDASFileName
        listOfExports = cell(0, 1);
        protocolOutput
        exampleMIDASTableController = MidasTableController('empty');
        exampleExperimentDataStructure
        treatmentStructure
        excelProtocol
        temporaryApareciumExperimentInput % holds the original Aparecium experiment input while launching protocol generator
        % parameters for ICSE Tools mode
        imageAnalyzer = ImageAnalyzer();
        analysisMode = 'Completed';
        templateFormulaDataTable % Stores the template formula table of the template excel file
        
        
    end
    
    properties(SetAccess=private)
       midasTableController = MidasTableController('empty'); 
    end
    
    methods
        
        function this = ExperimentProtocol()
            this.generateEmptyExperiment();
            this.exampleMIDASTableController.startWithOneMeasurementColumn();
        end
        
        function pipetingSimulatorInterface = getPipetingSimulatorInterface(this)
            pipetingSimulatorInterface = this.pipetingSimulatorInterface;
        end
        
        function setPipetingSimulatorInterface(this, pipetingSimulatorInterface)
           this.pipetingSimulatorInterface = pipetingSimulatorInterface;
        end
        
        function setToolOfProtocol(this, toolOfProtocol)
           this.toolOfProtocol = toolOfProtocol; 
        end
        
        function toolOfProtocol = getToolOfProtocol(this)
           toolOfProtocol = this.toolOfProtocol; 
        end
        
        function setFastKinetics(this, fastKinetics)
           this.apareciumExperimentInput.setFastKinetics(fastKinetics); 
        end
        
        function fastKinetics = getFastKinetics(this)
           fastKinetics = this.apareciumExperimentInput.getFastKinetics(); 
        end
        
        function setCreateMIDASFile(this, createMIDASFile)
           this.createMIDASFile = createMIDASFile; 
        end
        
        function createMIDASFile = getCreateMIDASFile(this)
            createMIDASFile = this.createMIDASFile;
        end
        
        function setDimensionality(this, dimensionality)
           this.dimensionality  = dimensionality; 
        end
        
        function dimensionality = getDimensionality(this)
            dimensionality = this.dimensionality;
        end
        
        function setMIDASFileName(this, MIDASFileName)
           this.MIDASFileName = MIDASFileName; 
        end
        
        function MIDASFileName = getMIDASFileName(this)
            MIDASFileName = this.MIDASFileName;
        end
        
        function setPlateWidth(this, width)
           this.plateWidth = width;
           this.generateEmptyExperiment();
        end
        
        function width = getPlateWidth(this)
           width = this.plateWidth; 
        end
        
        function setPlateHeight(this, height)
           this.plateHeight = height;
           this.generateEmptyExperiment();
        end
        
        function height = getPlateHeight(this)
           height = this.plateHeight; 
        end
        
        function setInputTimeUnit(this, timeUnit)
           this.inputTimeUnit = timeUnit; 
        end
        
        function timeUnit = getInputTimeUnit(this)
            timeUnit = this.inputTimeUnit;
        end
        
        function setExperimentName(this, experimentName)
           this.experimentName = experimentName; 
        end
        
        function experimentName = getExperimentName(this)
           experimentName = this.experimentName; 
        end
        
        function setExampleMIDASTableController(this, midasTableController)
            this.exampleMIDASTableController = midasTableController;
        end
        
        function midasTableController = getExampleMIDASTableController(this)
            midasTableController = this.exampleMIDASTableController;
        end
        
        function setNumberOfChannels(this, numberOfChannels)
            this.numberOfChannels = numberOfChannels;
        end
        
        function numberOfChannels = getNumberOfChannels(this)
            numberOfChannels = this.numberOfChannels;
        end
        
        function treatmentNames = getTreatmentNames(this)
            treatmentNames = this.apareciumExperimentInput.getTreatments();
        end
        
        function treatmentConcentrations = getTreatmentConcentrations(this)
            treatmentConcentrations = this.apareciumExperimentInput.getConcentrations();
        end
        
        function treatmentUnits = getTreatmentUnits(this)
            treatmentUnits = this.apareciumExperimentInput.getUnits(); 
        end
        
        function numberOfTreatments = getNumberOfTreatments(this)
           numberOfTreatments = this.apareciumExperimentInput.getNumberOfTreatments(); 
        end
        
        function generateEmptyExperiment(this)
           channelNames = cell(this.numberOfChannels, 1);
           for channel = 1 : this.numberOfChannels
              channelNames{channel} = ['Channel ', num2str(channel)];
           end
           this.apareciumExperimentInput.setChannelNames(channelNames);
           experiment = generateEmptyExperimentDataStructure(channelNames, this.plateHeight, this.plateWidth);
           generateApareciumExperimentInput(this, experiment);
           this.exampleExperimentDataStructure = experiment;
        end
        
        function updateExampleExperimentDataStructureChannelNames(this)
            channelNames = this.apareciumExperimentInput.getChannelNames();
            this.exampleExperimentDataStructure = generateEmptyExperimentDataStructure(channelNames, this.plateHeight, this.plateWidth);
        end
        
        function setListOfExports(this, listOfExports)
           this.listOfExports = listOfExports; 
        end
        
        function listOfExports = getListOfExports(this)
           listOfExports = this.listOfExports; 
        end
        
        function replaceExport(this, exportIndex, export)
           this.listOfExports{exportIndex} = export; 
        end
        
        function exportNames = getExportNames(this)
            exportNames = cell(1, numel(this.listOfExports));
            for exportIndex = 1 : numel(this.listOfExports)
                exportNames{exportIndex} = this.listOfExports{exportIndex}.exportName;
            end
        end
        
        function addNewExports(this, newExports)
            this.listOfExports = [this.listOfExports, newExports];
        end
        
        function launch(this)
           this.folderPath = [uigetdir(cd, 'Choose folder for saving exports'), '\'];
           switch this.toolOfProtocol
                case 'Gen5Tools'
                    this.launchGen5Tools();
                case 'PerkinElmerTools'
                    this.launchPerkinElmerTools();
                case 'PHERAStarTools'
                    this.launchPHERAStarTools();
                case 'ICSETools'
                    this.launchICSETools();
                case 'MIDASTools'
                    this.launchMIDASTools();
           end
        end
        
        function launchExcelProtocol(this)
            this.excelProtocol.createTables(this);
            maxRow = this.excelProtocol.calculateMaxRow();
            maxColumn = this.excelProtocol.calculateMaxColumn();
            finalTable = cell(maxRow, maxColumn);
            for tableIndex = 1 : this.excelProtocol.getNumberOfSingleTables()
                excelTable = this.excelProtocol.getTableAtIndex(tableIndex);
                finalTable = ExperimentProtocol.placeExcelTableToFinalTable(excelTable, finalTable);
            end
            
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            startingPath = settings.Excel;
            [FileName,FilePath,FilterIndex] = uiputfile({'.xls';'.csv'}, '', startingPath);
            
            if isequal(FilterIndex,1)
                outputFilenameMIDAS = [FilePath, '\', FileName];% was before outputFilenameMIDAS = [FilePath,'\',FileName,'.xls'];
                try
                    xlswrite(outputFilenameMIDAS, finalTable)
                catch
                   % the error is probably caused by the fact that while using .xls extension 256 columns is the limit, by for xlsx it is 16384, so we will just 
                   % save it as an .xlsx file then
                   outputFilenameMIDAS = [outputFilenameMIDAS 'x'];
                   xlswrite(outputFilenameMIDAS, finalTable);
                   warndlg('Error occurred while writing .xls file. An .xlsx file has been created instead');
                end
                winopen(outputFilenameMIDAS);
            elseif isequal(FilterIndex, 2)
                outputFilenameMIDAS = [FilePath,'\',FileName];    
                cell2csv(outputFilenameMIDAS, finalTable)
            end
        end
        
        function launchGen5Tools(this)
            this.midasTableController = MidasTableController('empty');
            fileChooser = FileChooser();
            [fullFilePath, fileName] = fileChooser.userChooseNeoASCIIFile();
            timeShift = this.askForTimeShift();
            
            neoAsciiReader = NeoASCIIReader();
            neoAsciiReader.readFile(fullFilePath);
            experimentDataStructure = neoAsciiReader.experimentDataStructure;
            this.midasTableController.addTreatmentColumn(' ', '', '');
            rawData = sendDataToMidasTable(neoAsciiReader.experimentDataStructure, 1);
            this.midasTableController.setData(rawData);
            this.addTreatmentsToMIDASTable(experimentDataStructure);
            updateMidasChannels(this);
            this.midasTableController.recalculateTimeShift(timeShift);
            this.midasTableController.updateTreatments(this.treatmentStructure);
            this.midasTableController.setEventDataEqualToData();
            this.attemptMIDASExport();
            this = MidasToApareciumExperimentInput(this.midasTableController, this);
            for exportIndex = 1 : numel(this.listOfExports)
               this.exportMidas(exportIndex); 
            end
            this.apareciumExperimentInput.setMode('addTreatments');
        end
        
        function attemptMIDASExport(this)
            if this.createMIDASFile
                inputStruct.data = this.midasTableController.getMidasTable();
                inputStruct.fileName = this.experimentName;
                inputStruct.automatically = 1;
                saveMidasFile(inputStruct);
            end
        end
        
        function exportMidas(this, exportIndex)
            export = this.listOfExports{exportIndex};
            export = this.cropGroupingStructuresToSize(export);
            switch export.exportType
                case export.excel
                    this.exportExcel(export);
                case export.SB
                    this.exportSB(export);
                case export.figure
                    this.exportFigure(export);
            end
            
        end
        
        function export = cropGroupingStructuresToSize(this, export)
           dimension1 = size(this.apareciumExperimentInput.wells, 1) + 1;
           dimension2 = size(this.apareciumExperimentInput.wells, 2) + 1;
           export.groupStructure(dimension1 : end, :, :) = [];
           export.groupStructure(:, dimension2 : end, :) = [];
           export.sharedBlankStructure(dimension1 : end, :, :) = [];
           export.sharedBlankStructure(:, dimension2 : end, :) = [];
           
           for column = 1 : dimension1 - 1
               for row = 1 : dimension2 - 1
                   if isequal(this.apareciumExperimentInput.inUse, 0)
                       export.groupStructure(column, row, 1) = 0;
                       export.groupStructure(column, row, 2) = -1;
                       export.sharedBlankStructure(column, row, :) = 0;
                   end
               end 
           end
        end
        
        function exportExcel(this, export)
            exportTimeMomentController = ExportTimeMomentController(this.apareciumExperimentInput);
            lb = this.dummyListbox(1);
            exportTimeMomentController.setCycleListHandle(lb);
            excelTableController = ExcelTableController();
            excelTableController.addTimeController(exportTimeMomentController);
            excelTableController.addExperiment(this.apareciumExperimentInput);
            excelTableController.addGroupStructure(export.groupStructure);
            excelTableController.addSharedBlankStructure(export.sharedBlankStructure);
            excelTableController.addSubgroupNames(export.subgroupNames);
            excelTableController.setCalculationMethod(export.calculationMethod);
            this.apareciumExperimentInput.setGroups(export.groupNames);
            switch export.tableType
                case 'Kinetic configuration'
                    excelTableController.calculateNewTable(1);
                case 'Concentration dependance'
                    pm = uicontrol('Style','popupmenu',...
                    'String',{'Groups','Subgroups (beta)'},...
                    'Value',1,'Visible','off');
                    excelTableController.setTableOrganizationHandle(pm);
                    originalTreatments = this.apareciumExperimentInput.getTreatments();
                    for treatmentIndex = 1 : numel(this.apareciumExperimentInput.getTreatments())
                        if strcmp(originalTreatments{treatmentIndex}{1}, export.xAxisTypeTable)
                            if isprop(excelTableController, 'numberOfSpecialXaxis')
                                numberOfSpecialXAxis = excelTableController.numberOfSpecialXaxis;
                            else
                                numberOfSpecialXAxis = 2; % older versions had strictly two special x axis configurations and the number of them was not parametrized
                            end
                                pm2 = uicontrol('Style','popupmenu',...
                                'Value',treatmentIndex + numberOfSpecialXAxis, 'Position',[30 80 130 20],'Visible','off');
                            break;
                        elseif strcmp(export.xAxisTypeTable, 'Concatenate')
                            pm2 = uicontrol('Style','popupmenu',...
                            'Value',1,'Visible','off');
                            break;
                        elseif strcmp(export.xAxisTypeTable, 'All')
                            pm2 = uicontrol('Style','popupmenu',...
                            'Value',2,'Visible','off');
                            break;
                        elseif strcmp(export.xAxisTypeTable, 'Smart')
                            pm2 = uicontrol('Style','popupmenu',...
                            'Value',3,'Visible','off');
                            break;
                        end
                    end
                    excelTableController.setXAxisChoosingDropdownHandle(pm2);
                    switch export.tableOrganizationStyle
                        case export.organizationStyleGroups
                            set(pm, 'Value', 1);
                        case export.organizationStyleSubgroups
                            set(pm, 'Value', 2);
                    end
                    excelTableController.calculateNewTable(2);
            end
            
            switch export.excelOrPrism
                case export.excel
                    excelTableController.exportWithName([this.folderPath, export.exportName, '.xls']);
                case export.prism
                    excelTableController.exportToPZFXWithName([this.folderPath, export.exportName, '.pzfx']);
            end
        end
        
        function exportSB(this, export)
            exportTimeMomentController = ExportTimeMomentController(this.apareciumExperimentInput);
            lb = this.dummyListbox(1);
            exportTimeMomentController.setCycleListHandle(lb);
            loading_Bar = loadingBar();
            SBExporter = SBToolboxExporter();
            SBExporter.addTimeController(exportTimeMomentController);
            SBExporter.addLoadingBar(loading_Bar);
            parameterNameTable = uitable('Data', export.variableNames);
            SBExporter.setExperimentParamNameTable(parameterNameTable);
            SBTable = uitable();
            SBExporter.setTableHandle(SBTable);
            SBExporter.addExperiment(this.apareciumExperimentInput);
            SBExporter.addGroupStructure(export.groupStructure);
            SBExporter.addSubgroupNames(export.subgroupNames);
            SBExporter.addSharedBlankStructure(export.sharedBlankStructure);
            SBExporter.setCalculationMethod(export.calculationMethod);
            acronyme = export.calculationMethod.formulae{end}.acronyme;
            switch export.fastKineticsExportMethod
                case export.average
                    SBExporter.calculateNewTable('Average', acronyme);
                case export.merge                    
                    SBExporter.calculateNewTable('Merge', acronyme);
            end
            mkdir([this.folderPath, export.exportName]);
            mkdir([this.folderPath, export.exportName,'\Experiments'])
            SBExporter.exportWithName([this.folderPath, export.exportName,'\Experiments']);
        end
        
        function exportFigure(this, export)
            f = figure;
            axis;
            a = gca;
            set(f, 'visible', 'off');
            graphicalPreviewController = GraphicalPreviewController(a);
            switch export.graphFormat
                case export.timeDependant
                    index = 1;
                case export.concentrationDependant
                    index = 2;                                                     
                case export.threeD
                    index = 3;                                    
            end
            
            graphFormatChooser = uicontrol('Style','popupmenu',...
                    'String',{'Groups','Subgroups (beta)'},...
                    'Value',index,'Visible','off');
            if ~isequal(index, 1)
                originalTreatments = this.apareciumExperimentInput.getTreatments();
                    for treatmentIndex = 1 : numel(this.apareciumExperimentInput.getTreatments())
                        if strcmp(originalTreatments{treatmentIndex}{1}, export.xAxisTypeFigure)
                            xAxisChooser = uicontrol('Style','popupmenu',...
                            'String',{export.timeDependant,export.concentrationDependant,export.threeD},...
                            'Value', treatmentIndex, 'Visible','off');
                        end
                    end
            else
                xAxisChooser = uicontrol('Style','popupmenu',...
                    'String',{export.timeDependant,export.concentrationDependant,export.threeD},...
                    'Value', 1,'Visible','off');
            end
            for groupIndex = 1 : numel(export.groupNames)
               if strcmp(export.groupNames{groupIndex}, export.activeGroup)
                  groupChooser = uicontrol('Style','popupmenu',...
                    'String',export.groupNames,...
                    'Value',groupIndex,'Visible','off');
               end
            end

            trisurfCheckBox = uicontrol(f,'Style','checkbox',...
                'String','Display file extension',...
                'Value',export.surface,'Visible','off');            
            pointsCheckBox = uicontrol(f,'Style','checkbox',...
                'String','Display file extension',...
                'Value',export.points,'Visible','off');
            
            exportTimeMomentController = ExportTimeMomentController(this.apareciumExperimentInput);
            lb = this.dummyListbox(1);
            exportTimeMomentController.setCycleListHandle(lb);
            
            graphicalPreviewController.addTimeController(exportTimeMomentController);
            graphicalPreviewController.setXAxisChoosingDropdownHandle(xAxisChooser);
            graphicalPreviewController.setGraphFormatDropdownHandle(graphFormatChooser);
            graphicalPreviewController.setGroupDropdownHandle(groupChooser);
            graphicalPreviewController.setTrisurfCheckbox(trisurfCheckBox);
            graphicalPreviewController.setPointsSurfaceCheckbox(pointsCheckBox);
            %handles.graphicalPreviewController.setAxisMinMaxBoxes(handles.XAxisUpperBound, handles.XAxisLowerBound, handles.YAxisUpperBound, handles.YAxisLowerBound, handles.ZAxisUpperBound, handles.ZAxisLowerBound);
            
            graphicalPreviewController.addExperiment(this.apareciumExperimentInput);
            graphicalPreviewController.addGroupStructure(export.groupStructure);
            graphicalPreviewController.addSubgroupNames(export.subgroupNames);
            graphicalPreviewController.addSharedBlankStructure(export.sharedBlankStructure);
            graphicalPreviewController.setCalculationMethod(export.calculationMethod);
            graphicalPreviewController.calculateNewGraph();
            set(f, 'visible', 'on');
            saveas(f, [this.folderPath, export.exportName, '.fig']);
            delete(f);
        end      
        
        function addTreatmentsToMIDASTable(this, experimentDataStructure)
            treatmentNames = this.apareciumExperimentInput.getTreatments();
            treatmentUnit = this.apareciumExperimentInput.getUnits();
            for treatmentIndex = 1 : this.dimensionality
                if ~isequal(treatmentIndex, 1)
                    this.midasTableController.addTreatmentColumn(' ', '', '');
                end
                this.midasTableController.changeTreatmentHeader(treatmentNames{treatmentIndex}, treatmentIndex, treatmentUnit{treatmentIndex});
            end
            this.modifyTreatmentStructureToMatchExperiment(experimentDataStructure);
        end
        
        function modifyTreatmentStructureToMatchExperiment(this, experimentDataStructure)
            actuallyMeasuredWells = this.fromNoZeroToZero(experimentDataStructure.wellID);
            wellsFromProtocol = this.fromNoZeroToZero(this.treatmentStructure.resultWells);           
            presentWellIndices = zeros(1, numel(actuallyMeasuredWells));
            for wellIndexInProtocol = 1 : numel(wellsFromProtocol)
               for wellIndexMeasured = 1 : numel(actuallyMeasuredWells)
                   if isequal(numel(wellsFromProtocol{wellIndexInProtocol}{1}), 2) && isequal(numel(actuallyMeasuredWells{wellIndexMeasured}), 3)
                       tempString = [wellsFromProtocol{wellIndexInProtocol}{1}(1), '0', wellsFromProtocol{wellIndexInProtocol}{1}(2)];
                       if strcmp(actuallyMeasuredWells{wellIndexMeasured}, tempString)
                           presentWellIndices(wellIndexMeasured) = wellIndexInProtocol;
                       end
                   else
                       if strcmp(actuallyMeasuredWells{wellIndexMeasured}, wellsFromProtocol{wellIndexInProtocol}{1})
                           presentWellIndices(wellIndexMeasured) = wellIndexInProtocol;
                       end
                   end
               end
            end
            for wellIndexMeasured = 1 : numel(actuallyMeasuredWells)
               newTreatmentStructure.resultWells{wellIndexMeasured} = this.treatmentStructure.resultWells{presentWellIndices(wellIndexMeasured)}; 
               newTreatmentStructure.eventTimes = 0;
               newTreatmentStructure.results{wellIndexMeasured} = this.treatmentStructure.results{presentWellIndices(wellIndexMeasured)};
               newTreatmentStructure.eventStruct{1}{wellIndexMeasured} =  this.treatmentStructure.eventStruct{1}{presentWellIndices(wellIndexMeasured)};
            end
            this.treatmentStructure = newTreatmentStructure;
        end
        
        function updateTreatmentStructure(this)
            treatmentStructure = this.plateSimulatorInterface.getTreatmentStructure();
            this.midasTableController.updateTreatments(treatmentStructure); 
        end
        
        function launchPerkinElmerTools(this)
            
        end
        
        function launchPHERAStarTools(this)
            this.midasTableController = MIDASTableController('empty');
            fileChooser = FileChooser();
            switch questdlg('Load from ASCII or xBase database?', 'Question', 'xBase', 'ASCII', 'ASCII')
                case 'ASCII'
                    [fullFilePath, fileName] = fileChooser.userChoosePheraStarASCIIFile();
                    pheraStarAsciiReader = PheraSTARASCIIReader();
                    pheraStarAsciiReader.readFile(fullFilePath);
                    experimentDataStructure = pheraStarAsciiReader.experimentDataStructure;
                case 'xBase'
                    [fullFilePath, fileName, parameterStructure] = userChoosePheraStarDatabase();
                    pheraStarDatabaseReader = PheraStarDatabaseReader();
                    pheraStarDatabaseReader.readFile(fullFilePath, parameterStructure);
                    experimentDataStructure = pheraStarDatabaseReader.experimentDataStructure;
                    
            end
            this.midasTableController.addTreatmentColumn(' ', '', '');
            rawData = sendDataToMidasTable(experimentDataStructure, 1);
            this.midasTableController.setData(rawData);
            this.addTreatmentsToMIDASTable(experimentDataStructure);
            updateMidasChannels(this);
            timeShift = this.askForTimeShift();
            this.midasTableController.recalculateTimeShift(timeShift);
            this.midasTableController.updateTreatments(this.treatmentStructure);
            this.midasTableController.setEventDataEqualToData();
            this = MidasToApareciumExperimentInput(this.midasTableController, this);
            this.attemptMIDASExport();
            for exportIndex = 1 : numel(this.listOfExports)
               this.exportMidas(exportIndex); 
            end
            this.apareciumExperimentInput.setMode('addTreatments');
        end
        
        function launchICSETools(this)
            this.midasTableController = MIDASTableController('empty');
            imageImporter = this.imageAnalyzer.imageImporter;
            imageImporter.userChooseImageFolders();
            switch this.imageAnalyzer.getMeasurementTimeMode()
                case 'Manual'
                    
                case 'Cycle average'
                    this.askUserForTime();
                case 'Well average'
                    this.askUserForTime();
            end
                
            switch this.analysisMode
                case 'Completed'
                    this.imageAnalyzer.startAnalysis();
                case 'Observe'
                    
            end
            experimentDataStructure = this.imageAnalyzer.fullDataStructure;
            this.midasTableController.addTreatmentColumn(' ', '', '');           
            rawData = sendDataToMidasTable(experimentDataStructure, 1);
            this.midasTableController.setData(rawData);
            this.addTreatmentsToMIDASTable(experimentDataStructure);
            updateMidasChannels(this);
            this.midasTableController.updateTreatments(this.treatmentStructure);
            this.midasTableController.setEventDataEqualToData();
            this = MidasToApareciumExperimentInput(this.midasTableController, this);
            this.attemptMIDASExport();
            for exportIndex = 1 : numel(this.listOfExports)
               this.exportMidas(exportIndex); 
            end
            this.apareciumExperimentInput.setMode('addTreatments');
            this.apareciumExperimentInput.revertToPreMIDASImport();
        end
        
        function askUserForTime(this)
           switch this.imageAnalyzer.getReferenceTimeMode()
               case 'First point'
                   timeShift = this.askForTimeShift();
                   this.imageAnalyzer.setTimeShift(timeShift);
               case 'Choose time'
                   startTime = ExperimentStartTimeChooser(); % Let the user choose the starting time of the experiment
                   this.imageAnalyzer.setExperimentStartTime(startTime); % Let the imageAnalyzer know that which experiment start time was defined
           end
        end
        
        function launchMIDASTools(this)
            this.midasTableController = MIDASTableController('empty');
            file_Chooser = fileChooser();
            [fullFilePath, fileName] = file_Chooser.chooseMIDASFile();
            this.midasTableController.readMidasFile(fullFilePath);
            this.midasTableController.setEventDataEqualToData();
            this = MidasToApareciumExperimentInput(this.midasTableController, this);
            for exportIndex = 1 : numel(this.listOfExports)
               this.exportMidas(exportIndex); 
            end
            this.apareciumExperimentInput.setMode('addTreatments');
        end
        
        function setChannelNames(this, channelNames)
            this.apareciumExperimentInput.setChannelNames(channelNames);
        end
        
        function channelNames = getChannelNames(this)
            channelNames = this.apareciumExperimentInput.getChannelNames();
        end
        
        function setExcelProtocol(this, excelProtocol)
           this.excelProtocol = excelProtocol; 
        end
        
        function excelProtocol = getExcelProtocol(this)
            excelProtocol = this.excelProtocol;
        end
        
        function setTemplateTable(this, templateTable)
           this.templateFormulaDataTable = templateTable;
        end
        
        function templateTable = getTemplateTable(this)
            templateTable = this.templateFormulaDataTable;
        end
    end
    
    methods(Static)
        function timeShift = askForTimeShift()
           timeShift = str2double(inputdlg('Enter time shift in seconds')); 
        end
        
        function finalTable = placeExcelTableToFinalTable(excelTable, finalTable)
            startingRow = excelTable.getStartingRow(); 
            startingColumn = excelTable.getStartingColumn();
            endingRow = excelTable.getMaxRow();
            endingColumn = excelTable.getMaxColumn();
            table = excelTable.table;
            if ~iscell(table)
                table = {table};
            end
            finalTable(startingRow : endingRow, startingColumn : endingColumn) = table;
        end
        
        function wellID = fromNoZeroToZero(wellID)
            for wellIndex = 1 : numel(wellID)
               if isequal(numel(wellID{wellIndex}), 2)
                   wellID{wellIndex} = [wellID{wellIndex}(1), '0', wellID{wellIndex}(2)];
               end
            end
        end
        
        function listBox = dummyListbox(value)
             listBox = uicontrol('Style','listbox',...
            'Position',[30 20 130 80],'Value',value, 'Visible', 'off');
        end
        
        function setImageAnalyzer(this, imageAnalyzer)
            this.imageAnalyzer = imageAnalyzer; 
        end
        
        function imageAnalyzer = getImageAnalyzer(this)
            imageAnalyzer = this.imageAnalyzer;
        end
    end
    
end