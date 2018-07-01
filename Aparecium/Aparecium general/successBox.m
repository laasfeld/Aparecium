function [ output_args ] = successBox(message, title)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
toolboxLocation = fileparts(mfilename('fullpath'));
filename = mfilename('fullpath');
thisPath = fileparts(filename);

myicon = imread([thisPath, '\..\\Icons\tick.png']);
h = msgbox(message, title, 'custom', myicon);

end

