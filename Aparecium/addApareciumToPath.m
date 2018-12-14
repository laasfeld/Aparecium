function addApareciumToPath()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% subdirs = {...
%     {''},...
%     {'bfmatlab'},...
%     {'tinyxml'},...
%     {'xml_toolbox'},...
%     {''},...
%     {''},...
%     {''},...
%     {''},...
%     {''},...
%     {''},...
%     {''},...
%     {''},...
%     {''}};

toolboxLocation = fileparts(mfilename('fullpath'));
filename = mfilename('fullpath');
thisPath = fileparts(filename);
% for i=numel(subdirs):-1:1
%     subdirs{i} = fullfile(thisPath, subdirs{i}{:});
%     if ~isdir(subdirs{i})
%         subdirs(i) = [];
%     end
% end
% addpath(subdirs{:});
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

end



