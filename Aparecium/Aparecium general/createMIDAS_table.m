function [MIDAS_table] = createMIDAS_table(parentHandle)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
MIDAS_table = createTable(parentHandle, {'A', 'B'}, rand(1,2), 'Buttons', 'off', 'Editable',false);
MIDAS_table.setVisible('off');

end

