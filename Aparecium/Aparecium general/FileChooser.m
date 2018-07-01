classdef FileChooser < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        PheraStarAsciiPath
        NeoAsciiPath
        ConfigurationsPath
        MidasPath
        PheraStarDatabasePath
        ExcelPath
        SBToolboxPath
        PerkinElmerPath
    end
    
    methods
        function this = FileChooser()
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            this.PheraStarAsciiPath = settings.PHERAStarASCII;
            this.NeoAsciiPath = settings.NeoASCII;
            this.ConfigurationsPath = settings.Configurations;
            this.MidasPath = settings.PHERAStarDatabase;
            this.ExcelPath = settings.Excel;
            this.SBToolboxPath = settings.SBToolbox;
            try
                this.PerkinElmerPath = settings.PerkinElmerPath;
            catch
                
            end
        end
        
        function [fullFilePath, fileName] = userChoosePheraStarASCIIFile(this)
            startingPath = this.PheraStarAsciiPath;
            [fileName, filePath] = uigetfile({'*.dat'},'Select PHERAStar ASCII file', startingPath);% opens dialog to select a .dat file, {'*.dat';'*.17_BV'}
            fullFilePath = [filePath, fileName];% merges filePath and fileName to single variable

            if isequal(fullFilePath(1,1),0)%checks if something was selected, if user pressed cancel, then filename(1,1) would be 0
               error('User selected Cancel')
            end
        end
        
        function [fullFilePath, fileName] = userChooseNeoASCIIFile(this)
            startingPath = this.NeoAsciiPath;
            [fileName, filePath] = uigetfile('*.txt','Select Neo ASCII file',startingPath);
            fullFilePath = [filePath, fileName];
            if isequal(fullFilePath(1,1),0)%checks if something was selected, if user pressed cancel, then filename(1,1) would be 0
               error('User selected Cancel')
            end
        end
        
        function [fullFilePath, fileName] = userChoosePerkinElmerExcel(this)
            try
                startingPath = this.PerkinElmerPath;
                [fileName, filePath] = uigetfile('*.xls','Select PerkinElmer platereader excel file', startingPath);
            catch
                [fileName, filePath] = uigetfile('*.xls','Select PerkinElmer platereader excel file');
            end
            fullFilePath = [filePath, fileName];
            if isequal(fullFilePath(1,1),0)%checks if something was selected, if user pressed cancel, then filename(1,1) would be 0
               error('User selected Cancel')
            end
        end
        
        function [fullFilePath, fileName, parameterStructure] = userChoosePheraStarDatabase(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            startingPath = settings.PHERAStarDatabase;

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
                    emissionFilter{recordIndex}=cell(0,0);
                    if ~isequal(char(record.getStringValue(String('EMFILT'))),'')

                        emissionFilter{recordIndex}{end+1} = regexprep(char(record.getStringValue(String('EMFILT'))),' ','');
                    end
                    for letter = alphabet
                        if ~isequal(char(record.getStringValue(String(['EMFILT',letter]))),'')
                            emissionFilter{recordIndex}{end+1} = regexprep(char(record.getStringValue(String(['EMFILT',letter]))),' ','');
                        end
                    end
                    loading.setLoadingBarPercent((recordIndex/numberOfRecords)*100);
                end
            catch
                errordlg('Your measure file has not been transferred correctly. Search the help for "Fixing a corrupted memo file". If you have the ASCII file for the same experiment then you should prefer the ASCII file');           
            end  
            loading.devizualize();
            [selection, ok] = listdlg('ListString' ,listString,'ListSize',[600 300],'SelectionMode','single','Name','Select experiment to import');
            fileName = [fileString{selection},'.dbf'];
            fullFilePath = [filePath, fileName];

            parameterStructure.emissionFilter = emissionFilter{selection};
            parameterStructure.exitationFilter = extFilter(selection);
            parameterStructure.kineticTime = double(kinTime{selection});
            parameterStructure.readingDirection = double(readingDirection{selection});
            measureTable.close();
            pause(0.5);
        end
        
        function [fullFilePath, fileName] = chooseMIDASFile(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings;
            end
            startingPath = settings.MIDAS;

            [fileName, filePath] = uigetfile({'*.csv;*.xls'},'Select MIDAS file', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
        end
        
        function [fullFilePathArray, fileNameArray] = chooseMultipleMIDASFiles(this)
           if isdeployed
               load([pwd, '\', 'settings.mat']);
           else
               load settings
           end
           startingPath = settings.MIDAS;
           
           [fileNameArray, filePath] = uigetfile({'*.csv;*.xls'},'Select MIDAS file', startingPath, 'MultiSelect', 'on');
           fullFilePathArray = cell(numel(fileNameArray), 1);
           for fileIndex = 1 : numel(fileNameArray)
                fullFilePathArray{fileIndex} = [filePath, fileNameArray{fileIndex}];
           end

           if isequal(fullFilePathArray(1,1),0)
              error('User selected Cancel')
           end
           
        end
        
        function [fullFilePath, fileName] = chooseTemplateExcel(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings;
            end
            if isfield(settings, 'templateExcel')
                startingPath = settings.templateExcel;
            else
                startingPath = [];
            end
            [fileName, filePath] = uigetfile({'*.csv;*.xls;*.xlsx'},'Select template excel file', startingPath);
            fullFilePath = [filePath, fileName];

            if isequal(fullFilePath(1,1),0)
               error('User selected Cancel')
            end
        end
        
        function [fullFilePath, fileName] = chooseConfigurationFile(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings;
            end
            startingPath = settings.Configurations;
            
            [fileName, filePath] = uigetfile('.mat','Select Configurations file', startingPath);
            fullFilePath = [filePath, fileName];
            
            if isequal(fullFilePath(1,1),0)
              error('User selected Cancel')
            end         
        end
        
        function [fileName, filePath] = chooseGCFFile(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            
            try
                startingPath = settings.GCFPath;
                [fileName, filePath] = uigetfile('*.mat', 'Choose grouping format file', startingPath);
            catch
                [fileName, filePath] = uigetfile('*.mat', 'Choose grouping format file')
            end
        end
        
        function [fileName, filePath] = chooseFCFFile(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            
            try
                startingPath = settings.FCFPath;
                [fileName, filePath] = uigetfile('*.mat', 'Choose formula file', startingPath);
            catch
                [fileName, filePath] = uigetfile('*.mat', 'Choose formula file');
            end
        end
        
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
    end

end

