classdef FileChooser < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        settings
        settingsPath
    end
    
    methods
        function this = FileChooser()
            if isdeployed
                loaded = load([pwd, '\', 'settings.mat']);
            else
                loaded = load('settings.mat');
            end
            this.settingsPath = regexprep(mfilename('fullpath'), 'FileChooser', '');
            this.settings = loaded.settings;
        end
        
        %% BGM ASCII methods
        
        function [fullFilePath, fileName] = userChoosePheraStarASCIIFile(this)
            if isfield(this.settings, 'PheraStarAsciiPath')
                startingPath = this.settings.PheraStarAsciiPath;
            else
                startingPath = '';
            end
            
            [fileName, filePath] = uigetfile({'*.dat'},'Select PHERAStar ASCII file', startingPath);% opens dialog to select a .dat file, {'*.dat';'*.17_BV'}
            fullFilePath = [filePath, fileName];% merges filePath and fileName to single variable

            if isequal(fullFilePath(1,1),0)%checks if something was selected, if user pressed cancel, then filename(1,1) would be 0
               error('User selected Cancel')
            end
            this.registerPheraStarASCIIFilePath(filePath);
        end
        
        function registerPheraStarASCIIFilePath(this, path)
            if isfield(this.settings, 'PHERAStarASCII_useLast')
               if isequal(this.settings.PHERAStarASCII_useLast, true)
                   this.settings.PHERAStarASCII = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% Neo ASCII methods
        
        function [fullFilePath, fileName] = userChooseNeoASCIIFile(this)
            if isfield(this.settings, 'NeoASCII')
                startingPath = this.settings.NeoASCII;
            else
                startingPath = '';
            end

            [fileName, filePath] = uigetfile('*.txt','Select Neo ASCII file',startingPath);
            fullFilePath = [filePath, fileName];
            if isequal(fullFilePath(1,1),0)%checks if something was selected, if user pressed cancel, then filename(1,1) would be 0
               error('User selected Cancel')
            end
            this.registerNeoASCIIFilePath(filePath)
        end
        
        function registerNeoASCIIFilePath(this, path)
            if isfield(this.settings, 'NeoASCII_useLast')
               if isequal(this.settings.NeoASCII_useLast, true)
                   this.settings.NeoASCII = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% Perkin Elmer reader methods
        
        function [fullFilePath, fileName] = userChoosePerkinElmerExcel(this)
            if isfield(this.settings, 'PerkinElmerPath')
                startingPath = this.settings.PerkinElmerPath;
            else
                startingPath = '';
            end

            [fileName, filePath] = uigetfile('*.xls','Select PerkinElmer platereader excel file', startingPath);

            fullFilePath = [filePath, fileName];
            if isequal(fullFilePath(1,1),0)%checks if something was selected, if user pressed cancel, then filename(1,1) would be 0
               error('User selected Cancel')
            end
            this.registerPerkinElmerExcelPath(filePath);
        end
        
        function registerPerkinElmerExcelPath(this, path)
            if isfield(this.settings, 'perkinElmer_useLast')
               if isequal(this.settings.perkinElmer_useLast, true)
                   this.settings.perkinElmerPath = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% BMG database methods
        
        function [fullFilePath, fileName, parameterStructure] = userChoosePheraStarDatabase(this)
            if isfield(this.settings, 'PHERAStarDatabase')
                startingPath = this.settings.PHERAStarDatabase;
            else
                startingPath = '';
            end

            [fileName, filePath] = uigetfile('*.dbf','Select database measure file', [startingPath, '\Measure.dbf']);% select the database main file
            measureFilename = [filePath, fileName];% select the corresponding file for your experiment

            try
                load javapath
                javaaddpath(strcat(Path,'\modified-dans-dbf.jar'), '-end')% adds the dbf reader to path YAY
            catch
                
            end

            javaaddpath(strcat(cd,'\modified-dans-dbf.jar'), '-end')
            import nl.knaw.dans.common.dbflib.*;
            import java.lang.String
            import java.io.File

            string = String(measureFilename);
            file = java.io.File(string);
            measureTable = nl.knaw.dans.common.dbflib.Table(file);
            measureTable.open();
            measureIterator = measureTable.recordIterator();
            listString = cell(0,0);
            fileString = cell(0,0);
            readingDirection=cell(0,0);
            kinTime=cell(0,0);
            extFilter = cell(0,0);
            emissionFilter = cell(0,0);
            emissionFilterChannel = cell(0,0);
            filterSetupName = cell(0,0);
            alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
%             OLDER VERSION OF CODE
%             try
%                 looper = 0;
%                 while(measureIterator.hasNext())
%                     looper = looper + 1
%                     record = measureIterator.next();
%                     listString{end + 1}=strcat(char(record.getStringValue(String('DATE'))),'__',char(record.getStringValue(String('TIME'))),'__',char(record.getStringValue(String('TSTNAME'))),'__',char(record.getStringValue(String('IDNUMBER'))));
%                     fileString{end + 1}=char(record.getNumberValue(String('MESSDATEI')));
%                     readingDirection{end+1}=record.getNumberValue(String('READINGDIR'));
%                     kinTime{end+1}=record.getNumberValue(String('KINTIME'));
%                     % get the channel names
%                     extFilter{end+1} = regexprep(char(record.getStringValue(String('EXFILT'))),' ','');
%                     emissionFilter{looper}=cell(0,0);
%                     if ~isequal(char(record.getStringValue(String('EMFILT'))),'')
% 
%                         emissionFilter{looper}{end+1} = regexprep(char(record.getStringValue(String('EMFILT'))),' ','');
%                     end
%                     for letter = alphabet
%                         if ~isequal(char(record.getStringValue(String(['EMFILT',letter]))),'')
%                             emissionFilter{looper}{end+1} = regexprep(char(record.getStringValue(String(['EMFILT',letter]))),' ','');
%                         end
%                     end
%                 end
%             catch
%                 errordlg('Your measure file has not been transferred correctly. Search the help for "Fixing a corrupted memo file". If you have the ASCII file for the same experiment then you should prefer the ASCII file');
%             end  

            try
                numberOfRecords = measureTable.getRecordCount();
                loading = loadingBar();
                loading.vizualizeWithString('Importing: ');
                for recordIndex = 1 : numberOfRecords
%                     'old'
%                     tic
%                     record = measureIterator.next();
%                     toc
                    record = measureTable.getRecordAt(recordIndex - 1);                    
                    listString{recordIndex}=strcat(char(record.getStringValue(String('DATE'))),'__',char(record.getStringValue(String('TIME'))),'__',char(record.getStringValue(String('TSTNAME'))),'__',char(record.getStringValue(String('IDNUMBER'))));
                    fileString{recordIndex}=char(record.getNumberValue(String('MESSDATEI')));
                    readingDirection{recordIndex}=record.getNumberValue(String('READINGDIR'));
                    kinTime{recordIndex}=record.getNumberValue(String('KINTIME'));
                    % get the channel names
                    extFilter{recordIndex} = regexprep(char(record.getStringValue(String('EXFILT'))),' ','');
                    emissionFilter{recordIndex} = cell(0,0);
                    emissionFilterChannel{recordIndex} = cell(0,0);
                    if ~isequal(char(record.getStringValue(String('EMFILT'))),'')
                        emissionFilter{recordIndex}{end+1} = regexprep(char(record.getStringValue(String('EMFILT'))),' ','');
                        emissionFilterChannel{recordIndex}{end + 1} = '';
                    end
                    for letter = alphabet
                        if ~isequal(char(record.getStringValue(String(['EMFILT',letter]))),'')
                            emissionFilter{recordIndex}{end+1} = regexprep(char(record.getStringValue(String(['EMFILT',letter]))),' ','');
                            emissionFilterChannel{recordIndex}{end + 1} = letter;
                        end
                    end
                    filterSetupName{recordIndex} = strtrim(char(record.getStringValue(String('OM')))); 
                    loading.setLoadingBarPercent((recordIndex/numberOfRecords)*100);
                end
            catch
                errordlg('Your measure file has not been transferred correctly. Search the help for "Fixing a corrupted memo file". If you have the ASCII file for the same experiment then you should prefer the ASCII file');           
            end  
            loading.devizualize();
            [selection, ok] = listdlg('ListString' ,listString,'ListSize',[600 300],'SelectionMode','single','Name','Select experiment to import');
            fileName = [fileString{selection},'.dbf'];
            fullFilePath = [filePath, fileName];
            fileName = regexprep(listString{selection}, ':', ''); % this is the effective file name that should be used a default for CF and MIDAS file suggestions. For actual file path fullFilePath should be used

            parameterStructure.emissionFilterChannel = emissionFilterChannel{selection};
            parameterStructure.filterSetupName = filterSetupName{selection};
            parameterStructure.emissionFilter = emissionFilter{selection};
            parameterStructure.exitationFilter = extFilter(selection);
            parameterStructure.kineticTime = double(kinTime{selection});
            parameterStructure.readingDirection = double(readingDirection{selection});
            measureTable.close();
            pause(0.5);
            this.registerPheraStarDatabasePath(filePath);
        end
        
        function registerPheraStarDatabasePath(this, path)
            if isfield(this.settings, 'PHERAStarDatabase_useLast')
               if isequal(this.settings.PHERAStarDatabase_useLast, true)
                   this.settings.PHERAStarDatabase = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% MIDAS file methods
        
        function [fullFilePath, fileName] = chooseMIDASFile(this)
            if isfield(this.settings, 'MIDAS')
                startingPath = this.settings.MIDAS;
            else
                startingPath = '';
            end

            [fileName, filePath] = uigetfile({'*.csv;*.xls'},'Select MIDAS file', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
            this.registerMIDASFilePath(filePath);
        end
        
        function [fullFilePathArray, fileNameArray] = chooseMultipleMIDASFiles(this)
           if isfield(this.settings, 'MIDAS')
                startingPath = this.settings.MIDAS;
           else
                startingPath = '';
           end         
           
           [fileNameArray, filePath] = uigetfile({'*.csv;*.xls'},'Select MIDAS file', startingPath, 'MultiSelect', 'on');
           fullFilePathArray = cell(numel(fileNameArray), 1);
           for fileIndex = 1 : numel(fileNameArray)
                fullFilePathArray{fileIndex} = [filePath, fileNameArray{fileIndex}];
           end

           if isequal(fullFilePathArray(1,1),0)
              error('User selected Cancel')
           end
           this.registerMIDASFilePath(filePath);
           
        end
        
        function startingPath = chooseMIDASFileSave(this)
            if isfield(this.settings, 'MIDAS')
                startingPath = this.settings.MIDAS;
            else
                startingPath = '';
            end                  
        end
        
        function registerMIDASFilePath(this, path)
            if isfield(this.settings, 'MIDAS_useLast')
               if isequal(this.settings.MIDAS_useLast, true)
                   this.settings.MIDAS = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% Template Excel file methods
        function [fullFilePath, fileName] = chooseTemplateExcel(this)
            if isfield(this.settings, 'templateExcel')
                startingPath = this.settings.templateExcel;
            else
                startingPath = '';
            end
            
            [fileName, filePath] = uigetfile({'*.csv;*.xls;*.xlsx'},'Select template excel file', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
        end
        
        function registerTemplateExcelPath(this, path)
            
        end
        
        %% CF file methods
        function [fullFilePath, fileName] = chooseConfigurationFile(this)
            if isfield(this.settings, 'Configurations')
                startingPath = this.settings.Configurations;
            else
                startingPath = '';
            end
            
            [fileName, filePath] = uigetfile('.mat','Select Configurations file', startingPath);
            fullFilePath = [filePath, fileName];
            
            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
            this.registerConfigurationFileSavePath(filePath);
        end
        
        function startingPath = chooseConfigurationFileSave(this)
            if isfield(this.settings, 'Configurations')
                startingPath = this.settings.Configurations;
            else
                startingPath = '';
            end                  
        end
        
        function registerConfigurationFileSavePath(this, path)
           if isfield(this.settings, 'Configurations_useLast')
               if isequal(this.settings.Configurations_useLast, true)
                   this.settings.Configurations = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        
        %% GCF file methods
        function [fileName, filePath] = chooseGCFFile(this) 
            if isfield(this.settings, 'Configurations')
                startingPath = this.settings.Configurations;
            else
                startingPath = '';
            end
            [fileName, filePath] = uigetfile('*.mat', 'Choose grouping format file', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
            this.registerGCFFilePath(filePath);
        end
        
        function startingPath = chooseGCFFileSave(this)
            if isfield(this.settings, 'GCFPath')
                startingPath = this.settings.GCFPath;
            else
                startingPath = '';
            end                  
        end
        
        function registerGCFFilePath(this, path)
           if isfield(this.settings, 'GCF_useLast')
               if isequal(this.settings.GCF_useLast, true)
                   this.settings.GCFPath = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% FCF file methods
        function [fileName, filePath] = chooseFCFFile(this)
            if isfield(this.settings, 'FCFPath')
                startingPath = this.settings.FCFPath;
            else
                startingPath = '';
            end

            [fileName, filePath] = uigetfile('*.mat', 'Choose formula file', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
            this.registerFCFFilePath(filePath);
        end
        
        function startingPath = chooseFCFFileSave(this)
            if isfield(this.settings, 'FCFPath')
                startingPath = this.settings.FCFPath;
            else
                startingPath = '';
            end                  
        end
        
        function registerFCFFilePath(this, path)
           if isfield(this.settings, 'FCF_useLast')
               if isequal(this.settings.FCF_useLast, true)
                   this.settings.FCFPath = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end       
        
        %% Protocol file methods
        function [fullFilePath, fileName] = chooseProtocolFile(this)
             % loading settings file is unnecessary as long as protocol
             % standard path has not been implemented into the settings
%             if isdeployed
%                 load([pwd, '\', 'settings.mat']);
%             else
%                 load settings
%             end
            
            [fileName, filePath] = uigetfile('*.mat', 'Choose formula file');
            fullFilePath = [filePath, fileName];
        end
        
        function registerProtocolFilePath(this, path)
            % to be added in the future
        end
        
        %% SBToolbox2/IQMTools folder methods
        
        function startingPath = chooseSBToolboxFolderSave(this)
            if isfield(this.settings, 'SBToolbox')
                startingPath = this.settings.SBToolbox;
            else
                startingPath = '';
            end                  
        end
        
        function registerSBToolboxFolderSavePath(this, path)
           if isfield(this.settings, 'SBToolbox_useLast')
               if isequal(this.settings.SBToolbox_useLast, true)
                   this.settings.SBToolbox = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% Excel export/Prism Export methods
    
        function startingPath = chooseExcelExportFileSave(this)
            if isfield(this.settings, 'Excel')
                startingPath = this.settings.Excel;
            else
                startingPath = '';
            end  
        end
        
        function registerExcelFolderSavePath(this, path)
           if isfield(this.settings, 'Excel_useLast')
               if isequal(this.settings.Excel_useLast, true)
                   this.settings.Excel = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% MembraneTools methods
        
        function folderPath = chooseMembraneToolsFolder(this)
            if isfield(this.settings, 'MembraneToolsPath')
                startingPath = this.settings.MembraneToolsPath;
            else
                startingPath = '';
            end

            folderPath = uigetdir(startingPath, 'Choose the folder which contains folders with all the image files for all the timepoints');

            if isequal(folderPath, 0)
               error('User selected Cancel')
            end
            this.registerMembraneToolsFolderPath(folderPath);
        end
        
        function registerMembraneToolsFolderPath(this, path)
           if isfield(this.settings, 'MembraneTools_useLast')
               if isequal(this.settings.MembraneTools_useLast, true)
                   this.settings.MembraneToolsPath = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        function fullFilePath = chooseIlastikModelFile(this)
            if isfield(this.settings, 'defaultIlastikModelPath')
                startingPath = this.settings.defaultIlastikModelPath;
            else
                startingPath = '';
            end
            
            [fileName, filePath] = uigetfile('*.ilp', 'Choose Ilastik model', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
            this.registerIlastikModelPath(filePath);
        end
        
        function registerIlastikModelPath(this, path)
           if isfield(this.settings, 'defaultIlastikModel_useLast')
               if isequal(this.settings.defaultIlastikModel_useLast, true)
                   this.settings.defaultIlastikModelPath = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
        
        %% Ilastik methods
        
        function path = getIlastikExecutablePath(this)
            if isfield(this.settings, 'IlastikExecutablePath')
                path = this.settings.IlastikExecutablePath;
            else
                result = questdlg('Ilastik executable path not found! To attempt automatic search of Ilastik, click "Attempt search". Clicking "Cancel will stop analysis"','Ilastik not configured','Attempt search','Cancel', 'Attempt search');
                switch result
                    case 'Attempt search'
                        ilastikPath = findIlastikPath();
                        if isempty(ilastikPath)
                           result = questdlg('Automatic search failed! Click "Manually" to manually select the Ilastik executable. Clicking "Cancel will stop analysis"','Ilastik not configured','Manually','Cancel', 'Manually');
                           switch result
                               case 'Manually'
                                   [fileName, filePath] = uigetfile('*.exe', 'Select Ilastik executable', 'ilastik.exe');
                                   path = [filePath, fileName];
                               case 'Cancel'
                                 path = '';
                           end
                                  
                        else
                           path = ilastikPath;
                        end
                    case 'Cancel'
                        path = '';
                end
                       
            end
        end
        
        %% model library methods
        
        function path = getModelLibraryPath(this)
            if isfield(this.settings, 'modelLibraryPath')
                startingPath = this.settings.modelLibraryPath;
            else
                startingPath = '';
            end
            path = startingPath;
        end
        
        %% Stopwatch loading functions
        
        function fullFilePath = getStopwatchPath(this)
    
            if isfield(this.settings, 'stopwatchPath')
                startingPath = this.settings.stopwatchPath;
            else
                startingPath = '';
            end
            
            [fileName, filePath] = uigetfile({'*.txt'}, 'Choose the stopwatch file for this experiment',  startingPath);

            if isequal(filePath, 0)
               error('User selected Cancel')
            end
                      
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
            this.registerStopwatchPath(filePath);
        end
        
        function registerStopwatchPath(this, filePath)
            if isfield(this.settings, 'stopwatchPath_useLast')
               if isequal(this.settings.stopwatchPath_useLast, true)
                   this.settings.stopwatchPath = path;
                   settings = this.settings; % ignore warning, it is used in the save
                   if isdeployed
                        save([pwd, '\', 'settings.mat'], 'settings');
                   else
                        save([this.settingsPath, 'settings.mat'], 'settings');
                   end
               end
           end
        end
    end
    


end

