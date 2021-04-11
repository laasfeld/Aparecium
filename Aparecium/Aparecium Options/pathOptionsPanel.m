function handles = pathOptionsPanel(handles, varargin)
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    pathOptionsPanel = uipanel('Parent', handles.MIDASPreviewPanel);
    
    % Define the main panel
    
    set(pathOptionsPanel, 'BackgroundColor', [225/255 226/255 251/255]);
    set(pathOptionsPanel, 'units', 'normalized');
    set(pathOptionsPanel, 'Position', [0, 0.2278, 0.8123, 0.731]);
    set(pathOptionsPanel, 'Title', 'Path options');
    setTag(component, handles, tagname)
    
    % Define the use last for all text
    
    % Define the Select all checkbox
       
    texts = cell(0, 1);
    edits = cell(0, 1);
    folderIcons = cell(0, 1);
    useLastCheckboxes = cell(0, 1);
    
    texts{end + 1} = 'Choose the standard path for searching BMG ASCII files';
    texts{end + 1} = 'Choose the standard path for searching Gen5 ASCII files';
    texts{end + 1} = 'Choose the standard path for searching BMG database files';
    texts{end + 1} = 'Choose the standard path for saving and opening MIDAS files';
    texts{end + 1} = 'Choose the standard folder for saving Excel/Prism files';
    texts{end + 1} = 'Choose the standard folder for saving SBtoolbox experiments folders';
    texts{end + 1} = 'Choose the standard folder for saving experiment configuration files (CF)';
    texts{end + 1} = 'Choose the standard folder for saving and loading experiment group configuration files (GCF)';
    texts{end + 1} = 'Choose the standard folder for saving and loading formula configuration files (FCF)';
    texts{end + 1} = 'Choose the standard folder for loading PerkinElmer reader files';
    texts{end + 1} = 'Choose the standard folder for loading Magellan reader files';
    texts{end + 1} = 'Choose the standard folder for loading Membrane Tools images';
    texts{end + 1} = 'Choose IQMTools folder';
    texts{end + 1} = 'Choose default model library';
    texts{end + 1} = 'Choose default Ilastik model for membrane tools';
    texts{end + 1} = 'Choose Ilastik executable path';
    texts{end + 1} = 'Choose default stopwatch path';
    % Add more if needed
    
    folderTags{end + 1} = 'PHERAStarASCII';
    folderTags{end + 1} = 'NeoASCII';
    folderTags{end + 1} = 'PHERAStarDatabase';
    folderTags{end + 1} = 'MIDAS';
    folderTags{end + 1} = 'Excel';
    folderTags{end + 1} = 'SBToolbox';
    folderTags{end + 1} = 'Configurations';
    folderTags{end + 1} = 'GCF';
    folderTags{end + 1} = 'FCF';
    folderTags{end + 1} = 'perkinElmer';
    folderTags{end + 1} = 'magellan';
    folderTags{end + 1} = 'MembraneTools';
    folderTags{end + 1} = 'IQMTools';
    folderTags{end + 1} = 'modelLibrary';
    folderTags{end + 1} = 'Choose default Ilastik model for membrane tools';
    folderTags{end + 1} = 'defaultIlastikModel';
    folderTags{end + 1} = 'IlastikExecutable';
    folderTags{end + 1} = 'stopwatchFile';
    % Add more if needed
    
    editTags = cell(size(folderTags));
    textTags = cell(size(folderTags));
    useLastTags = cell(size(folderTags));
    
    for tagIndex = 1 : numel(editTags)
        editTags{tagIndex} = [folderTags{tagIndex}, '_Path']; 
        textTags{tagIndex} = ['text', num2str(tagIndex)];
        useLastTags{tagIndex} = [folderTags{tagIndex}, '_useLast'];
    end
    
    % generate the texts
    
    upperY = 0.9141354372123606;
    deltaY = 0.0564;
    
    textX = 0.013172338090010977;
    textWidth = 0.49945115257958295;
    textHeight = 0.03931623931623929;
    editX = 0.5181119648737651;
    editWidth = 0.2941822173435785;
    editHeight = 0.037606837606837584;
    folderX = 0.8254665203073546;
    folderHeight = 0.03931623931623929;
    folderWidth = 0.027442371020856227;
    useLastX = 0.8594950603732163;
    useLastYoffset = 0.0034;
    useLastHeight = 0.03931623931623929;
    useLastWidth = 0.01975850713501648;
    
    
    for tagIndex = 1 : numel(editTags)
        
        currentY = upperY - deltaY * (tagIndex - 1);
        
        % create textfields
        textField = uicontrol('Parent', pathOptionsPanel, 'Style', 'text');
        set(textField, 'BackgroundColor', [225/255 226/255 251/255]);
        set(textField, 'units', 'normalized');
        set(textField, 'Position', [textX, currentY, textWidth, textHeight]);
        
        % create editField
        
        % create folderButtons
        
        % create useLast checkboxes
    end

    
end

