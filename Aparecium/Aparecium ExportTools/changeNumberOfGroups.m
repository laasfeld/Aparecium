function handles = changeNumberOfGroups(handles, numberOfGroups)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
numberOfGroups = floor(str2double(numberOfGroups));

if isnan(numberOfGroups) || numberOfGroups < 1
    set(handles.numberOfGroupsText,'String','Only positive integers allowed','ForegroundColor','red');
    set(handles.numberOfGroupsField,'String',num2str(handles.numberOfGroups));
    set(handles.numberOfGroupsField,'BackgroundColor','red');
    pause(1);
    set(handles.numberOfGroupsField,'BackgroundColor','white');
    set(handles.numberOfGroupsText,'String','NumberOfGroups :','ForegroundColor','black');
    return;
end

numberOfRows = size(get(handles.groupNameTable, 'Data'), 1);

if(numberOfRows > numberOfGroups) && strcmp(get(handles.groupsOKIndicator, 'String'), 'OK')
    answer = questdlg('Lowering the number of groups REMOVES current grouping. This means that you have to set all of the groups, subgroups, blanks and timewise blanks again. Are you sure you want to decrease the number of groups?');
    switch answer
        
        case 'Yes'
            set(handles.groupsOKIndicator, 'String', 'Undef', 'BackgroundColor', [1 0 0]);
            set(handles.savePlateKonfig, 'Enable', 'off');
            set(handles.applyFormula, 'Enable', 'off');
        case 'No'
            set(handles.numberOfGroupsField,'String',num2str(numberOfRows));
            return;
        case 'Cancel'
            set(handles.numberOfGroupsField,'String',num2str(numberOfRows));
            return;
    end
end
    
handles.numberOfGroups = numberOfGroups;
set(handles.numberOfGroupsField,'String',num2str(numberOfGroups));
alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
doubleAlphabet = cellstr(alphabet');
for firstLetter = 1 : numel(alphabet)
    for secondLetter = 1 : numel(alphabet)
        doubleAlphabet(end + 1) = {[alphabet(firstLetter), alphabet(secondLetter)]}; 
    end
end
emptyRow = {''};
data = get(handles.groupNameTable, 'data');

if(numberOfRows <= numberOfGroups - 1)
    for row = numberOfRows : numberOfGroups - 1
        data = [data; doubleAlphabet{row + 1}];
        %data = [data; alphabet(row + 1)];       
    end
else
    for row = numberOfRows : -1 : numberOfGroups + 1
        data(row, :) = [] ; 
    end   
end
set(handles.groupNameTable, 'Data', data);
handles.numberOfGroups = numberOfGroups;
handles.apareciumExperimentInput.setGroups(data);

end

