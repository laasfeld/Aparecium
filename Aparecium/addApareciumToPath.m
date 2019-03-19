function addApareciumToPath()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

toolboxLocation = fileparts(mfilename('fullpath'));
filename = mfilename('fullpath');
thisPath = fileparts(filename);
addpath(genpath(toolboxLocation))
try
    javaaddpath(strcat(thisPath,'\bfmatlab\bioformats_package.jar'), '-end')
    javaaddpath(strcat(thisPath,'\Aparecium Java\Sim plate.jar'), '-end')
    javaaddpath(strcat(thisPath,'\Aparecium Java\modified-dans-dbf.jar'), '-end')
    javaaddpath(strcat(thisPath,'\createTable\TableSorter.jar'), '-end')
    javaaddpath(strcat(thisPath,'\createTable\ColoredFieldCellRenderer.zip'), '-end')
catch
    warndlg('Error loading java packages, some features might not work');
end
cd('Aparecium Options');

try
    settings = load('settings.mat');
    IQMToolsPath = settings.settings.IQMToolsPath;
    cd(IQMToolsPath);
    installIQMtools();
catch MException
    if strcmp(MException.message, 'Undefined function or variable installIQMtools')
       warndlg('IQMTools integration disabled in ExportTools. Could not intall IQMTools at the said location', 'IQMTools installation failed'); 
    end
    cd(thisPath);
end
    cd(thisPath);
end