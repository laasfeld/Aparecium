function [ output_args ] = successBox(message, title)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
toolboxLocation = fileparts(mfilename('fullpath'));
filename = mfilename('fullpath');
thisPath = fileparts(filename);

myicon= imread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'Icons', 'tick.png'));
h = msgbox(message, title, 'custom', myicon);

end

