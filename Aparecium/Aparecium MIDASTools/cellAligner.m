function [noOfCols, combinedHeaders ] = Untitled(a,b,names1,names2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load javapath
javaaddpath(strcat(Path,'\Sim plate.jar'), '-end')

import java.awt.*;
import cellAligner.*;
import javax.swing.JFrame
import java.awt.Color;

%a=2;
%b=2;

%names1={'a','b'}
%names2={'a','b'}

% display the GUI
GUI = CellAligner(a,b,names1,names2);
f=JFrame('');
f.setSize(1300,700)
f.setTitle('Sim Well')
%% Col=java.awt.Color(0.7,0.7,0.9);
%%f.getContentPane().setBackground(Col);
f.add(GUI);
f.setVisible(true)

% loop while the GUI is still running
while isequal(GUI.isFinished(),0)
    pause(0.5);
end

% close the window
f.dispose();


% get the resulting column layout and convert it from java format to matlab
% cell format so that it is comparable to the names1 and names2 variables
% given as the input
upperHeadersOrig = GUI.getUpperHeaders();
lowerHeadersOrig = GUI.getLowerHeaders();

upperHeaders = cell(1,size(upperHeadersOrig,1));
lowerHeaders = cell(1,size(lowerHeadersOrig,1));
for counter = 1:size(upperHeadersOrig,1)
    upperHeaders{1,counter} = char(upperHeadersOrig(counter,:));
end

for counter = 1:size(lowerHeadersOrig,1)
    lowerHeaders{1,counter} = char(lowerHeadersOrig(counter,:));
end

% check to see how many columns are there in the end

noOfCols = size(lowerHeaders,2);

% loop through all the given headers and input names and determine where to
% shift the columns

for originalColumn = 1 : size(names1,2)
    for reformedColumn = 1 : size(upperHeaders,2)
        if strcmp(names1{1, originalColumn}, upperHeaders{1, reformedColumn})
            combinedHeaders{reformedColumn, 1}.index = originalColumn;
            combinedHeaders{reformedColumn, 1}.name = upperHeaders{1, reformedColumn};
        end
    end
end

for originalColumn = 1 : size(names2, 2)
    for reformedColumn = 1 : size(lowerHeaders, 2)
        if strcmp(names2{1, originalColumn}, lowerHeaders{1, reformedColumn})
            combinedHeaders{reformedColumn, 2}.index = originalColumn;
            combinedHeaders{reformedColumn, 2}.name = lowerHeaders{1, reformedColumn};
        end
    end
end


end

