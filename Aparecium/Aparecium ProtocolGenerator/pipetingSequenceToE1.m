function [ output_args ] = pipetingSequenceToE1(sequence, filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% TODO - looks like some models have a certain number of steps that one
% protocol can contain. for example for the one channel pipette it was 60
% steps. Maybe it is needed to split up the protocol into bite size junks
% for the pipette.

load StandardPipetingStruct.mat % load the structure
extras = cell(numel(sequence)*3, 0);
for stepIndex = 1 : numel(sequence)
   extras{end + 1}.notestep = sequence{stepIndex}.notestep;
   extras{end + 1}.fillstep = sequence{stepIndex}.fillstep;
   extras{end + 1}.dispensestep = sequence{stepIndex}.dispensestep;
end
xml_write(filename, structure, 'userprogram', [], extras)

end

