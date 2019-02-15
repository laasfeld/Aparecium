classdef ExcelTableController < ExportPanelController
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        tableHandle = [];
        dropdownHandle = [];
        timeUnitConversionConstant = 1;
        tableOrganizationHandle;
        activeTable;
        selectedIndices;
        xmlString
        numberOfSpecialXaxis = 3;
        header = '<?xml version="1.0" encoding="UTF-8"?><GraphPadPrismFile xmlns="http://graphpad.com/prism/Prism.htm" PrismXMLVersion="5.00"> <TableSequence Selected="1"><Ref ID="Table0" Selected="1"/></TableSequence>';
        PZFXColumnCountWarningFlag = 0; % Graphpad PRISM can only support limited number of columns so a warning must be given if larger tables are generated. This is a flag for the warning.
        PZFXMaxColumns = 104;
    end
    properties
        removeEmptyRows = 1;
    end
    
    methods
        function this = ExcelTableController()
            
        end
        
        function addExperiment(this, experiment, mode)
            addExperiment@ExportPanelController(this, experiment);
            treatments = this.convertToCellArrayOfStrings(this.experiment.getTreatments());
            switch mode
                case 'concentrations'
                    set(this.dropdownHandle, 'String', ['Concatenate', 'All', 'Smart', treatments]);
                    set(this.dropdownHandle, 'Value', 3);
                case 'kinetics'
                    set(this.dropdownHandle, 'String', ['Concatenate', 'Smart', treatments]);
                    set(this.dropdownHandle, 'Value', 2);
            end
        end
        
        function setXAxisChoosingDropdownMode(this, mode)
            treatments = this.convertToCellArrayOfStrings(this.experiment.getTreatments());
            
            switch mode               
               case 'concentrations'
                   treatments = ['Concatenate', 'All', 'Smart', treatments];
                   set(this.dropdownHandle, 'String', treatments);
                   set(this.dropdownHandle, 'Value', 3);
               case 'kinetics'
                   set(this.dropdownHandle, 'String', ['Concatenate', 'Smart', treatments]);
                   set(this.dropdownHandle, 'Value', 2);
           end
        end                                    
        
        function setTableHandle(this, tableHandle)
           this.tableHandle = tableHandle;
        end
        
        function setXAxisChoosingDropdownHandle(this, dropdownHandle)
            this.dropdownHandle = dropdownHandle;
        end
        
        function setTableOrganizationHandle(this, dropdownHandle)
            this.tableOrganizationHandle = dropdownHandle;
        end
                
        function calculateNewTable(this, configuration) 
           [data, groups] = this.calculationMethod.calculate(this.experiment, this.groupStructure, this.sharedBlankStructure, this.timewiseBlankStructure);
           if isequal(this.subgroupNames, [])
                this.subgroupNames = generateStandardSubgroupNames(data, 1);
           end
           if isequal(configuration, 1)
                this.convertDataToKineticTable(data, groups);
                this.generateKineticPZFX(data, groups);
           elseif isequal(configuration, 2)
                if isequal(this.timeController.getFastKinetics(), 0)
                    tableType = get(this.tableOrganizationHandle, 'Value');
                    switch tableType
                        case 1
                            this.convertDataToConcentrationTable(data, groups);
                            this.generatePZFX(data, groups);
                        case 2                         
                            this.convertDataToConcentrationSubgroupTable(data, groups);
                            this.generateSubgroupPZFX(data, groups)
                    end
                else
                    warndlg('Concentration dependance table is not implemented for fast kinetics experiment');
                end

           end
           
        end
        
        function calculateNewPZFX(this, configuration)
           [data, groups] = this.calculationMethod.calculate(this.experiment, this.groupStructure, this.sharedBlankStructure, this.timewiseBlankStructure);
           if isequal(configuration, 1)
                this.generateKineticPZFX(data, groups);
           elseif isequal(configuration, 2)
                if isequal(this.timeController.getFastKinetics(), 0)
                    tableType = get(this.tableOrganizationHandle, 'Value');
                    switch tableType
                        case 1
                            this.generatePZFX(data, groups);
                        case 2                         
                            this.generateSubgroupPZFX(data, groups)
                    end
                else
                    warndlg('Concentration dependance table is not implemented for fast kinetics experiment');
                end

           end 
        end
        
        function convertDataToConcentrationTable(this, data, groups)
            % count the number of subgroups present
            tableType = get(this.dropdownHandle, 'Value');
               
            groupNames = this.experiment.getGroups();
            noOfSubgroups = 0;
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    noOfSubgroups = noOfSubgroups + 1;
                end
            end
            
            Header(noOfSubgroups + 1, 3) = {''};% make proper size header
            Header(1,3) = {['time/', this.timeController.getTimeUnit()]};% set the time column
            Header(2,1) = groupNames(1);
            place = 2;           
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    subgroupElement = 1;
                    if isequal(subgroup, this.subgroupStartValue)
                        Header(place,1) = groupNames(group);
                    end
                    
                    Header(place, 2) = this.subgroupNames{group}(subgroup);%{['Subgroup ',num2str(subgroup)]};
                    tempString = '';
                    tempTreatmentName = '';
                    tempTreatmentValue = '';
                    [row, column] = this.experiment.getRowAndColumnIndecesOfWell(groups{group}{subgroup}(subgroupElement));
                    for element = 1 : numel(groups{group}{subgroup})
                        [treatments, concentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(element), 1);
                        if isequal(strfind(concentrations{1}, 'NaN'), [])
                           break; 
                        end
                    end
                    switch tableType
                        case 1 %Concatenate type of table
                            for treatment = 1 : numel(treatments)
                                tempTreatmentName = treatments{treatment};
                                tempTreatmentValue = concentrations{treatment};
                                tempString = [tempString,' ',tempTreatmentName{1,1},'-',num2str(tempTreatmentValue),'|'];
                            end
                            Header(place,3) = {tempString}; 
                            place = place + 1;% move writable column to right by one cell
                        case 2 %All concentrations
                            column = 3;
                            for treatment = 1 : numel(treatments)
                                tempTreatmentName = treatments{treatment};
                                tempTreatmentValue = concentrations{treatment};                              
                                Header(place, column) = {tempTreatmentName{1,1}}; 
                                column = column + 1;
                                Header(place, column) = {num2str(tempTreatmentValue)}; 
                                column = column + 1;% move writable column to right by one cell
                            end
                            place = place + 1;
                        case 3 % Smart table
                            concentrationsOfGroup = this.experiment.getTreatmentsConcentrationsOfGroup(groups{group}, 1);
                            treatmentUniquenessTable = this.createTreatmentUniquenessTable(size(data, 2), groups, data);
                            treatment = findLargestDimention(concentrationsOfGroup, treatmentUniquenessTable{group}{subgroup});
                            column = 3;
                            tempTreatmentName = treatments{treatment};
                            tempTreatmentValue = concentrations{treatment};                              
                            Header(place, column) = {tempTreatmentName{1,1}}; 
                            column = column + 1;
                            Header(place, column) = {num2str(tempTreatmentValue)}; 
                            column = column + 1;% move writable column to right by one cell
                            place = place + 1;
                        otherwise %Special cases are over, other are treatment types
                            treatment = tableType - this.numberOfSpecialXaxis;
                            column = 3;
                            tempTreatmentName = treatments{treatment};
                            tempTreatmentValue = concentrations{treatment};                              
                            Header(place, column) = {tempTreatmentName{1,1}}; 
                            column = column + 1;
                            Header(place, column) = {num2str(tempTreatmentValue)}; 
                            column = column + 1;% move writable column to right by one cell
                            place = place + 1;
                    end
                end
            end
            numberOfCycles = this.timeController.getNumberOfCycles();
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();      
            place = 2;% reset writable column to 2
            row = 2;
            col = 1;
            for group = 1 : size(data, 2)
                maxNumberOfSubgroups{group} = 0;
                for subgroup = this.subgroupStartValue : numel(data{group})
                    if size(groups{group}{subgroup}, 1) > maxNumberOfSubgroups{group}
                        maxNumberOfSubgroups{group} = size(groups{group}{subgroup}, 1);
                    end
                end
            end
            colorgen = @(color,text) ['<html><table border=0 width=200 bgcolor=',color,'  ><TR><TD>',text,'</TD></TR> </table></html>'];
            colorgenBlank = @(color,text) ['<html><table border=0 width=200 bgcolor=',color,' color=',color,' ><TR><TD>',text,'</TD></TR> </table></html>'];
            cr = ColoredFieldCellRenderer(java.awt.Color.white);
            cr.setDisabled(true);
            maxNumberOfSubgroupElements = -1;
            for groupIndex = 1 : numel(groups)
               maxNumberOfSubgroupElements = max(max(cellfun(@numel,data{groupIndex})), maxNumberOfSubgroupElements); 
            end
            counter = 0;
            crShift = size(Header, 2);
            control = cell(size(Header, 1), 204);
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    for timeIndex = 1 : numberOfCycles
                        for subgroupElement = 1 : maxNumberOfSubgroupElements
                            switch mod(timeIndex + group, 2)
                                case 0
                                    colorCode = 'E4EFF7';
                                    colorRGB = [228	239	247]/255;
                                case 1
                                    colorCode = 'E8D8E4';
                                    colorRGB = [232	216	228]/255;
                            end
                            if subgroupElement <= size(groups{group}{subgroup}, 1)
                                if isequal(subgroupElement,1)
                                    experimentData(1,col) = {num2str(timeMoments(cyclesInUse(timeIndex)))};
                                    %visualExperimentData(1,col) = {num2str(timeMoments(cyclesInUse(timeIndex)))};
                                    cr.setCellBgColor(0, col - 1 + crShift, java.awt.Color(1, 1, 1));
                                    cr.setCellFgColor(0, col - 1 + crShift, java.awt.Color(0, 0, 0));
                                    counter = counter + 1;
                                    control{1, col + crShift} = 1; 
                                end
                                experimentData(row, col) = {data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))};
                                %visualExperimentData(row, col) = {colorgen(colorCode, num2str(data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))))};
                                cr.setCellBgColor(row - 1, col - 1 + crShift, java.awt.Color(colorRGB(1), colorRGB(2), colorRGB(3)));
                                cr.setCellFgColor(row - 1, col - 1 + crShift, java.awt.Color(0, 0, 0));
                                counter = counter + 1;
                                control{row, col + crShift} = 1;
                            else
                                experimentData(row, col) = {[]};
                                %visualExperimentData(row, col) = {colorgenBlank(colorCode, 't')};
                                cr.setCellBgColor(row - 1, col - 1 + crShift, java.awt.Color(1, 1, 1));
                                cr.setCellFgColor(row - 1, col - 1 + crShift, java.awt.Color(0, 0, 0));
                                counter = counter + 1;
                                control{row, col + crShift} = 1;
                            end
                            
                            col = col + 1;                            
                            
                        end
                    end
                    row = row + 1;
                    col = 1;
                end
            end
            
            for row = 1 : size(Header, 1)
                for col = 1 : size(Header, 2)
                    counter = counter + 1;
                    cr.setCellBgColor(row - 1, col - 1, java.awt.Color(1, 1, 1));
                    cr.setCellFgColor(row - 1, col - 1, java.awt.Color(1, 0, 0));
                    control{row, col} = 1;
                end
            end

            tableData = [Header, experimentData];
            %visualData = [Header, visualExperimentData];
            this.setTableData(tableData);
            jtable = this.tableHandle.getTable;        
            this.setVisualTableData(tableData);
            %set(this.tableHandle,'ColumnFormat',[]);
            for colIdx = 1 : size(tableData, 2)
                %disp([num2str(colIdx),' /',num2str(size(tableData, 2))])                
                jtable.getColumnModel.getColumn(colIdx-1).setCellRenderer(cr);
            end
            
            
        end
        
        function uniquenessTable = createTreatmentUniquenessTable(this, numberOfGroups, groups, data)
            concentrationsOfGroup = cellfun(@str2num, this.experiment.getTreatmentsConcentrationsOfGroup(groups{1}, 1));
            for group = 2 : numberOfGroups
                concentrationsOfGroup = cat(1, concentrationsOfGroup, cellfun(@str2num, this.experiment.getTreatmentsConcentrationsOfGroup(groups{group}, 1)));
            end
            if isequal(size(concentrationsOfGroup, 2), 1)
               concentrationsOfGroup = concentrationsOfGroup'; 
            end
            uniquenessTable = cell(numberOfGroups, 1);
            for group = 1 : numberOfGroups
                uniquenessTable{group} = cell(numel(data{group}), 1);
                for subgroup = this.subgroupStartValue : numel(data{group})
                    try
                        [unneeded, treatmentConcentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(1), 1);
                    catch MException
                        'siin'
                        rethrow(MException);
                    end
                    treatmentConcentrations = cellfun(@str2num, treatmentConcentrations);
                    for treatment = 1 : numel(treatmentConcentrations)
                        uniquenessTable{group}{subgroup}(treatment) = numel(find(concentrationsOfGroup(:,treatment)==treatmentConcentrations(treatment))); 
                    end
                end              
            end            
        end
        
        function convertDataToConcentrationSubgroupTable(this, data, groups)
            tableType = get(this.dropdownHandle, 'Value');
               
            groupNames = this.experiment.getGroups();
            noOfSubgroups = 0;
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    noOfSubgroups = noOfSubgroups + 1;
                end
            end
            
            Header(noOfSubgroups + 1, 3) = {''};% make proper size header
            Header(1,3) = {['time/', this.timeController.getTimeUnit()]};% set the time column
            Header(2,1) = groupNames(1);
            place = 2; 
            tableRows = cell(size(data, 2), 1);
            visualTableRows = cell(size(data, 2), 1);
            headerRows = cell(size(data, 2), 1);
            colorgen = @(color,text) ['<html><table border=0 width=200 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table></html>'];
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    subgroupElement = 1;
                    Header(place,2) = groupNames(group);
                    if isequal(group, 1)
                        Header(place, 1) = this.subgroupNames{group}(subgroup);%{['Subgroup ',num2str(subgroup)]};
                    end
                    tempString = '';
                    tempTreatmentName = '';
                    tempTreatmentValue = '';
                    [row, column] = this.experiment.getRowAndColumnIndecesOfWell(groups{group}{subgroup}(subgroupElement));
                    [treatments, concentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                    switch tableType
                        case 1 %Concantenate type of table
                            for treatment = 1 : numel(treatments)
                                tempTreatmentName = treatments{treatment};
                                tempTreatmentValue = concentrations{treatment};
                                tempString = [tempString,' ',tempTreatmentName{1,1},'-',num2str(tempTreatmentValue),'|'];
                            end
                            Header(place,3) = {tempString}; 
                            place = place + 1;% move writable column to right by one cell
                        case 2 %All concentrations
                            column = 3;
                            for treatment = 1 : numel(treatments)
                                tempTreatmentName = treatments{treatment};
                                tempTreatmentValue = concentrations{treatment};                              
                                Header(place, column) = {tempTreatmentName{1,1}}; 
                                column = column + 1;
                                Header(place, column) = {num2str(tempTreatmentValue)}; 
                                column = column + 1;% move writable column to right by one cell
                            end
                            place = place + 1;
                        case 3
                            concentrationsOfGroup = squeeze(this.experiment.getTreatmentsConcentrationsOfSubgroup(groups, subgroup, 1));
                            treatmentUniquenessTable = this.createTreatmentUniquenessTable(size(data, 2), groups, data);
                            treatment = findLargestDimention(concentrationsOfGroup, treatmentUniquenessTable{group}{subgroup});
                            column = 3;
                            tempTreatmentName = treatments{treatment};
                            tempTreatmentValue = concentrations{treatment};                              
                            Header(place, column) = {tempTreatmentName{1,1}}; 
                            column = column + 1;
                            Header(place, column) = {num2str(tempTreatmentValue)}; 
                            column = column + 1;% move writable column to right by one cell
                            place = place + 1;
                        otherwise %Special cases are over, other are treatment types
                            treatment = tableType - this.numberOfSpecialXaxis;
                            column = 3;
                            tempTreatmentName = treatments{treatment};
                            tempTreatmentValue = concentrations{treatment};                              
                            Header(place, column) = {tempTreatmentName{1,1}}; 
                            column = column + 1;
                            Header(place, column) = {num2str(tempTreatmentValue)}; 
                            column = column + 1;% move writable column to right by one cell
                            place = place + 1;
                    end
                    headerRows{group}{subgroup} = Header(place-1, :);
                end
            end
            numberOfCycles = this.timeController.getNumberOfCycles();
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();      
            place = 2;% reset writable column to 2
            row = 2;
            col = 1;
            for group = 1 : size(data, 2)
                maxNumberOfSubgroups{group} = 0;
                for subgroup = this.subgroupStartValue : numel(data{group})
                    if size(groups{group}{subgroup}, 1) > maxNumberOfSubgroups{group}
                        maxNumberOfSubgroups{group} = size(groups{group}{subgroup}, 1);
                    end
                end
            end
            
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    for timeIndex = 1 : numberOfCycles
                        for subgroupElement = 1 : size(groups{group}{subgroup}, 1)
                             
                            if isequal(subgroupElement,1)
                                experimentData(1,col) = {num2str(timeMoments(cyclesInUse(timeIndex)))};
                                visualExperimentData(1,col) = {num2str(timeMoments(cyclesInUse(timeIndex)))};
                            end
                           switch mod(timeIndex+subgroup, 2)
                                case 0
                                    colorCode = 'E4EFF7';
                                case 1
                                    colorCode = 'E8D8E4';
                            end
                            experimentData(row, col) = {data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))}; 
                            visualExperimentData(row, col) = {colorgen(colorCode, num2str(data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))))};
                            col = col + 1;                            
                            
                        end
                        col = col + maxNumberOfSubgroups{group} - size(groups{group}{subgroup}, 1);
                    end
                    visualTableRows{group}{subgroup} = visualExperimentData(row, :);
                    tableRows{group}{subgroup} = experimentData(row, :);
                    row = row + 1;
                    col = 1;
                end
            end
            row = 2;
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    visualTableRows{group}{subgroup} = visualExperimentData(row, :);
                    tableRows{group}{subgroup} = experimentData(row, :);
                    row = row + 1;
                end
            end
            newExperimentData = experimentData(1, :);
            newVisualExperimentData = visualExperimentData(1, :);
            newHeaderData = Header(1, :);
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    subgroupwiseTable{subgroup}{group} = tableRows{group}{subgroup};
                    subgroupwiseVisualTable{subgroup}{group} = visualTableRows{group}{subgroup};
                    subgroupwiseHeader{subgroup}{group} = headerRows{group}{subgroup};
                end
            end
            first = 1;
            for subgroup = this.subgroupStartValue : numel(subgroupwiseTable)
                for groupIndex = 1 : numel(subgroupwiseTable{subgroup})

                    newExperimentData = [newExperimentData; subgroupwiseTable{subgroup}{groupIndex}];
                    newHeaderData = [newHeaderData; subgroupwiseHeader{subgroup}{groupIndex}];
                    newVisualExperimentData = [newVisualExperimentData; subgroupwiseVisualTable{subgroup}{groupIndex}]; 
                end
            end
            
            tableData = [newHeaderData, newExperimentData];
            visualData = [newHeaderData, newVisualExperimentData];
            this.setTableData(tableData);
            this.setVisualTableData(visualData);
        end
        
        function convertDataToKineticTable(this, data, groups)
            
            tableType = get(this.dropdownHandle, 'Value');
            
            firstsubgroupToShow = 2; % 2 if you want to hide the blank group, 1 of you want to show the blank group 
            groupNames = this.experiment.getGroups();
            
            numberOfWells = numel(this.experiment.getWells());
            Header(4, numberOfWells + 1) = {''};% make proper size header
            Header(4,1) = {'time'};% set the time column
            Header(1,2) = groupNames(1);
            
            numberOfCycles = this.timeController.getNumberOfCycles();
            experimentData(numberOfCycles ,numberOfWells + 1) = {''};
            column = 2;
           
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    for subgroupElement = 1 : numel(data{group}{subgroup})
                        if subgroup == this.subgroupStartValue && subgroupElement == 1
                            Header(1, column) = groupNames(group);
                        end
                        if subgroupElement == 1
                            Header(2, column) = this.subgroupNames{group}(subgroup);
                        end
                        Header(3, column) = ['', groups{group}{subgroup}(subgroupElement)];
                        tempString = '';
                        tempTreatmentName = '';
                        tempTreatmentValue = '';
                        [treatmentNames, treatmentValues] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                        switch tableType
                            case 1
                                for treatment = 1 : numel(treatmentValues)
                                    tempTreatmentName = treatmentNames{treatment};
                                    tempTreatmentValue = treatmentValues{treatment};
                                    tempString = [tempString, ' ', tempTreatmentName{1}, ':', tempTreatmentValue,'|'];
                                end
                            case 2 % smart treatment as header
                                
                            otherwise % treatment as header
                                treatment = tableType - 2;
                                tempTreatmentName = treatmentNames{treatment};
                                tempTreatmentValue = treatmentValues{treatment};
                                tempString = [tempTreatmentName{1}, ':', tempTreatmentValue];                                                               
                        end
                        Header(4,column) = {tempString}; 
                        column = column + 1;% move writable column to right by one cell
                    end
                end
            end
            
            column = 2;% reset writable column to 2
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            fastKinetics = this.timeController.getFastKinetics();
            
            timeMomentsAsString = cell(numel(cyclesInUse), 1);
            for timeIndex = 1 : numberOfCycles             
                experimentData(timeIndex, 1) = {num2str(timeMoments(cyclesInUse(timeIndex)))};                                           
            end
            % this loop can be optimized
            if isequal(fastKinetics, 0) 
                for group = 1 : size(data, 2)
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        for subgroupElement = 1 : numel(data{group}{subgroup})                                           
                            experimentData(1 : numberOfCycles, column) = num2cell(data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(:)));
                            column = column + 1;% move writable column to right by one cell
                        end
                    end
                end
            else
                place=2;% reset writable column to 2
                for group = 1 : size(data, 2)
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        for subgroupElement = 1 : numel(data{group}{subgroup})
                            for timeIndex = 1 : numberOfCycles 
                                %localTimeIndex = groups{group}{subgroup}(subgroupElement);
                                localTimeIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}(subgroupElement));
                                row = size(timeMoments(:,timeIndex), 1)*(timeIndex-1) + localTimeIndex;
                                experimentData(row, 1) = {num2str(timeMoments(localTimeIndex, cyclesInUse(timeIndex)))};
                                experimentData(row, place) = {data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))};    
                            end
                            place = place + 1;% move writable column to right by one cell
                        end
                    end
                end         
            end
            if this.removeEmptyRows
                rowToBeRemoved = [];
                for rowToCheck = size(experimentData, 1) : -1 : 1 
                    if isempty(experimentData{rowToCheck,1})
                        rowToBeRemoved(end+1) = rowToCheck;
                    end
                end
                experimentData(rowToBeRemoved, :) = [];
            else
                
            end
            
            tableData = [Header; experimentData];
            this.setTableData(tableData);
            this.setVisualTableData(tableData);
            %drawnow;
        end
        
        function convertDataToKineticSubgroupTable(this, data, groups)
            
            tableType = get(this.dropdownHandle, 'Value');
            
            firstsubgroupToShow = 2; % 2 if you want to hide the blank group, 1 of you want to show the blank group 
            groupNames = this.experiment.getGroups();
            
            numberOfWells = numel(this.experiment.getWells());
            Header(4, numberOfWells + 1) = {''};% make proper size header
            Header(4,1) = {'time'};% set the time column
            Header(1,2) = groupNames(1);
            
            numberOfCycles = this.timeController.getNumberOfCycles();
            experimentData(numberOfCycles ,numberOfWells + 1) = {''};
            column = 2;
           
            for group = 1 : size(data, 2)
                for subgroup = this.subgroupStartValue : numel(data{group})
                    for subgroupElement = 1 : numel(data{group}{subgroup})
                        if subgroup == this.subgroupStartValue && subgroupElement == 1
                            Header(1, column) = groupNames(group);
                        end
                        if subgroupElement == 1
                            Header(2, column) = this.subgroupNames{group}(subgroup);
                        end
                        Header(3, column) = ['', groups{group}{subgroup}(subgroupElement)];
                        tempString = '';
                        tempTreatmentName = '';
                        tempTreatmentValue = '';
                        [treatmentNames, treatmentValues] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                        switch tableType
                            case 1
                                for treatment = 1 : numel(treatmentValues)
                                    tempTreatmentName = treatmentNames{treatment};
                                    tempTreatmentValue = treatmentValues{treatment};
                                    tempString = [tempString, ' ', tempTreatmentName{1}, ':', tempTreatmentValue,'|'];
                                end
                            case 2 % smart treatment as header
                                
                            otherwise % treatment as header
                                treatment = tableType - 2;
                                tempTreatmentName = treatmentNames{treatment};
                                tempTreatmentValue = treatmentValues{treatment};
                                tempString = [tempTreatmentName{1}, ':', tempTreatmentValue];                                                               
                        end
                        Header(4,column) = {tempString}; 
                        column = column + 1;% move writable column to right by one cell
                    end
                end
            end
            
            column = 2;% reset writable column to 2
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            fastKinetics = this.timeController.getFastKinetics();
            if isequal(fastKinetics, 0) 
                for group = 1 : size(data, 2)
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        for subgroupElement = 1 : numel(data{group}{subgroup})
                            for timeIndex = 1 : numberOfCycles             
                                experimentData(timeIndex,1) = {num2str(timeMoments(cyclesInUse(timeIndex)))};
                                experimentData(timeIndex,column) = {data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))};           
                            end
                            column = column + 1;% move writable column to right by one cell
                        end
                    end
                end
            else
                place=2;% reset writable column to 2
                for group = 1 : size(data, 2)
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        for subgroupElement = 1 : numel(data{group}{subgroup})
                            for timeIndex = 1 : numberOfCycles 
                                %localTimeIndex = groups{group}{subgroup}(subgroupElement);
                                localTimeIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}(subgroupElement));
                                row = size(timeMoments(:,timeIndex), 1)*(timeIndex-1) + localTimeIndex;
                                experimentData(row, 1) = {num2str(timeMoments(localTimeIndex, cyclesInUse(timeIndex)))};
                                experimentData(row, place) = {data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex))};    
                            end
                            place = place + 1;% move writable column to right by one cell
                        end
                    end
                end         
            end
            if this.removeEmptyRows
                rowToBeRemoved = [];
                for rowToCheck = size(experimentData, 1) : -1 : 1 
                    if isempty(experimentData{rowToCheck,1})
                        rowToBeRemoved(end+1) = rowToCheck;
                    end
                end
                experimentData(rowToBeRemoved, :) = [];
            else
                
            end
            
            tableData = [Header; experimentData];
            this.setTableData(tableData);
            this.setVisualTableData(tableData);
            %drawnow;
        end
        
        function setTableData(this, tableData)
           this.activeTable =  tableData; 
        end
        
        function setVisualTableData(this, visualTableData)
           this.tableHandle.setData(visualTableData);  
        end      
        
        
        function exportWithDialogue(this) % consider moving some functionality of exportWithDialogue to exportWithName to reduce code duplication
            tableData = this.activeTable;
            fileChooser = FileChooser();
            startingPath = fileChooser.chooseExcelExportFileSave();
            [FileName,FilePath,FilterIndex] = uiputfile({'*.xls';'*.csv'}, '', startingPath);
            
            if isequal(FilterIndex,1)
                outputFilename = [FilePath, '\', FileName];
                try
                    xlswrite(outputFilename, tableData)
                catch
                   % the error is probably caused by the fact that while using .xls extension 256 columns is the limit, by for xlsx it is 16384, so we will just 
                   % save it as an .xlsx file then
                   outputFilename = [outputFilename 'x'];
                   xlswrite(outputFilename, tableData);
                   fileChooser.registerExcelFolderSavePath(FilePath);
                   warndlg('Error occurred while writing .xls file. An .xlsx file has been created instead');
                end
                answer = questdlg('Would you like to open the created Excel file now?', 'Open?', 'Yes', 'No', 'Yes');
                if strcmp(answer, 'Yes')
                    winopen(outputFilename);
                end
            elseif isequal(FilterIndex, 2)
                outputFilename = [FilePath,'\',FileName];    
                cell2csv(outputFilename, tableData, ';')
                answer = questdlg('Would you like to open the created .csv file now?', 'Open?', 'Yes', 'No', 'Yes');
                if strcmp(answer, 'Yes')
                    winopen(outputFilename);
                end
            end
        end      
        
        function exportWithName(this, fileName)
            tableData = this.activeTable;
            try
                try
                    xlswrite(fileName, tableData)
                catch
                   % the error is probably caused by the fact that while using .xls extension 256 columns is the limit, by for xlsx it is 16384, so we will just 
                   % save it as an .xlsx file then
                   fileName = [fileName 'x'];
                   xlswrite(fileName, tableData);
                   warndlg('Error occurred while writing .xls file. An .xlsx file has been created instead');
                end
            catch
                fileName = regexprep(fileName, '.xlsx', '.csv');
                cell2csv(fileName, tableData, '  ');
            end

        end
        
        function exportToPZFXWithName(this, fileName)
            fileID = fopen(fileName,'w');
            
            fprintf(fileID, regexprep(this.xmlString, '%', '%%'));
            fclose(fileID);
        end
        
        function exportToPZFX(this)

            
            if isequal(this.PZFXColumnCountWarningFlag, 1)
                answer = questdlg('The number of columns for some sheets is larger than allowed by GraphpadPrism 5 (104 columns) and will not properly display such tables. Would you still like to create the file?', 'Create file?', 'Yes', 'No', 'No');
                if strcmp(answer, 'Yes')
                   createFile = 1;
                else
                   createFile = 0;  
                end
            else
               createFile = 1; 
            end
                
            if isequal(createFile, 1)
                fileChooser = FileChooser();
                startingPath = fileChooser.chooseExcelExportFileSave();
                [FileName, FilePath] = uiputfile({'.pzfx'}, '', startingPath);
                fullFileName = [FilePath, '\', FileName];
                
                this.exportToPZFXWithName(fullFileName);
                fileChooser.registerExcelFolderSavePath(FilePath);
                answer = questdlg('Would you like to open the created Prism file now?', 'Open?', 'Yes', 'No', 'Yes');
                if strcmp(answer, 'Yes')
                    winopen(fullFileName);
                end
            end
        end
         
        function updateSelectedIndices(this, indices)
            this.selectedIndices = indices;
        end
        
        function customCopy(this)
            minimum = min(this.selectedIndices, [], 1);
            maximum = max(this.selectedIndices, [], 1);
            tableToCopy = this.activeTable(minimum(1):maximum(1), minimum(2):maximum(2));
            resultString = [];
            for row = 1 : size(tableToCopy, 1)
                for col = 1 : size(tableToCopy, 2)
                    if isempty(resultString)
                        resultString = num2str(tableToCopy{row, col});
                    elseif isequal(col, 1)
                        resultString = [resultString, num2str(tableToCopy{row, col})];
                    else
                        resultString = [resultString, char(9), num2str(tableToCopy{row, col})];
                    end
                end
                resultString = [resultString, char(10)];
            end
            clipboard('copy', resultString);
        end
        
        function sendToWorkspace(this)            
            assignin('base', 'Aparecium_Excel_Table', this.activeTable);
        end
        
        function generateKineticPZFX(this, data, groups)
            this.PZFXColumnCountWarningFlag = 0;
            numberOfCycles = this.timeController.getNumberOfCycles();
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            groupNames = this.experiment.getGroups();
            tableType = get(this.dropdownHandle, 'Value');
            fastKinetics = this.timeController.getFastKinetics();
            if isequal(fastKinetics, 0)
                for group = 1 : size(data, 2)

                    %YCol(numel(data{group}) - this.subgroupStartValue + 1) = struct('Title', cell(1, size(groups{group}{subgroup}, 1)), 'Subcolumn', struct('d', cell(1, numberOfCycles)));
                    Table = struct('Title', cell(1, numel(data{group}) - this.subgroupStartValue + 1), 'XColumn', cell(1, numel(data{group}) - this.subgroupStartValue + 1), 'YColumn', cell(1, numel(data{group}) - this.subgroupStartValue + 1));
                    clear YCol;
                    Table(1).Title = groupNames{group};
                    Table(1).XColumn.Title = ['time(', this.timeController.timeUnit, ')'];
                    tempTimeMoments = timeMoments(cyclesInUse);
                    for timeIndex = 1 : numberOfCycles
                        Table(1).XColumn.Subcolumn(timeIndex).d = tempTimeMoments(timeIndex);
                    end
                    
                    concentrationsOfGroup = this.experiment.getTreatmentsConcentrationsOfGroup(groups{group}, 1);
                    treatmentUniquenessTable = this.createTreatmentUniquenessTable(size(data, 2), groups, data);                    
                    
                    if (numel(data{group}) - this.subgroupStartValue) > this.PZFXMaxColumns
                        this.PZFXColumnCountWarningFlag = 1;
                    end
                        
                    largestDimTreatmentIndex = findLargestDimention(concentrationsOfGroup, treatmentUniquenessTable{group}{2});
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        Table(subgroup - (this.subgroupStartValue - 1)).YColumn = struct('Title', cell(1, size(groups{group}{subgroup}, 1)), 'Subcolumn', struct('d', cell(1, numberOfCycles)));
                        for subgroupElement = 1 : size(groups{group}{subgroup}, 1)
                            if isequal(subgroupElement, 1)
                                switch tableType
                                    case 1
                                        Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Title = this.subgroupNames{group}{subgroup};
                                    case 2
                                        treatmentIndex = largestDimTreatmentIndex;
                                        well = groups{group}{subgroup}{1};
                                        [treatments, concs] = this.experiment.getTreatmentsOfWell(well,1);
                                        Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Title = [treatments{treatmentIndex}{1}, ' ', concs{treatmentIndex}];
                                    otherwise
                                        well = groups{group}{subgroup}{1};
                                        treatmentIndex = tableType - 2;
                                        [treatments, concs] = this.experiment.getTreatmentsOfWell(well,1);
                                        Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Title = [treatments{treatmentIndex}{1}, ' ', concs{treatmentIndex}];
                                end
                            end
                            %for timeIndex = 1 : numberOfCycles                                                     
                                
                                %Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Subcolumn(timeIndex).d = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex));
                            %end
                            Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Subcolumn = cell2struct(num2cell(data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(:))), 'd', 2);
                        end
                    end
                    subXML(group).Table = Table;
                end
            elseif isequal(fastKinetics, 1)
                for group = 1 : size(data, 2)
                    Table = [];
                    Table(1).Title = groupNames{group};
                    Table(1).XColumn.Title = ['time(', this.timeController.timeUnit, ')'];
                    Table(1).XColumn.Subcolumn.d = timeMoments(cyclesInUse);
                    xValues = [];
                    wellsInGroup = this.findAllWellsInGroup(groups{group}, this.subgroupStartValue);
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        for subgroupElement = 1 : size(groups{group}{subgroup}, 1)
                            if isequal(subgroupElement, 1)
                                Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Title = this.subgroupNames{group}{subgroup};
                            end
                            for row = 1 : numel(wellsInGroup)*numel(cyclesInUse)
                                Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Subcolumn(row).d = '';
                            end
                        end
                        
                        for timeIndex = 1 : numberOfCycles
                            for subgroupElement = 1 : size(groups{group}{subgroup}, 1)
                                localTimeIndex = findStringFromCellArray(wellsInGroup, groups{group}{subgroup}{subgroupElement});
                                row = numel(wellsInGroup)*(timeIndex-1) + localTimeIndex;
                                Table(subgroup - (this.subgroupStartValue - 1)).YColumn(subgroupElement).Subcolumn(row).d = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex));
                                generalTimeIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}(subgroupElement));
                                xValues(row, 1) = timeMoments(generalTimeIndex, cyclesInUse(timeIndex));
                            end
                        end
                    end
                    for xValueIndex = 1 : numel(xValues)                      
                       Table(1).XColumn.Subcolumn(xValueIndex).d = xValues(xValueIndex); 
                    end
                    subXML(group).Table = Table;
                end
            end

            try
                xmlString = variableToXMLString(subXML);
            catch
                xmlString = xml_format(subXML, 'off'); % slower function, but gives the same result if the compilation of the previous tool fails
            end
            xmlString = ExcelTableController.fixXMLString(xmlString, data);
            this.xmlString = [this.header, xmlString];      
        end
        
        function generateSubgroupPZFX(this, data, groups)
            this.PZFXColumnCountWarningFlag = 0;
            numberOfCycles = this.timeController.getNumberOfCycles();
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            groupNames = this.experiment.getGroups();
            tableType = get(this.dropdownHandle, 'Value');
            if ~(isequal(tableType, 1) || isequal(tableType, 2))
                for subgroup = this.subgroupStartValue : numel(data{1})
                    Table = [];

                    
                    concentrationList = [];
                    for group = 1 : numel(data)
                        if isequal(tableType, 3)
                           concentrationsOfGroup = squeeze(this.experiment.getTreatmentsConcentrationsOfSubgroup(groups, subgroup, 1));
                           treatmentUniquenessTable = this.createTreatmentUniquenessTable(size(data, 2), groups, data);
                           treatment = findLargestDimention(concentrationsOfGroup, treatmentUniquenessTable{group}{subgroup});
                        else
                           treatment = tableType - this.numberOfSpecialXaxis;
                        end
                        try
                            [treatments, concentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(1), 1);
                            for element = 1 : numel(groups{group}{subgroup})
                                [treatments, concentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(element), 1);
                                if isequal(strfind(concentrations{1}, 'NaN'), [])
                                   break; 
                                end
                            end

                        catch MException
                           disp(MException) 
                        end
                        concentrationList(end + 1) = str2double(concentrations{1, 1, 1, treatment});
                    end
                    tempTreatmentName = treatments{treatment};
                    
                    if(numberOfCycles > this.PZFXMaxColumns)
                        this.PZFXColumnCountWarningFlag = 1;
                    end
                    for timeIndex = 1 : numberOfCycles
                        if isequal(timeIndex, 1)
                            Table(timeIndex).Title = this.subgroupNames{1}{subgroup};
                            Table(timeIndex).XColumn.Title = tempTreatmentName{1};
                            Table(timeIndex).XColumn.Subcolumn.d = concentrationList;

                        else
                            
                        end
                        
                        for group = 1 : numel(data)
                            if isequal(timeIndex, 1)
                                Table(timeIndex).XColumn.Subcolumn(group).d = concentrationList(group);
                            end

                            for subgroupElement = 1 : size(groups{group}{subgroup}, 1)
                                if isequal(subgroupElement, 1)
                                    Table(timeIndex).YColumn(subgroupElement).Title = timeMoments(cyclesInUse(timeIndex));
                                end
                                Table(timeIndex).YColumn(subgroupElement).Subcolumn(group).d = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex));
                            end

                        end
                        
                        subXML(subgroup - (this.subgroupStartValue - 1)).Table = Table;
                    end
                end
            
                
                try
                    xmlString = variableToXMLString(subXML);
                catch
                    xmlString = xml_format(subXML, 'off'); % slower function, but gives the same result if the compilation of the previous tool fails
                end
                xmlString = ExcelTableController.fixXMLString(xmlString, data);
                this.xmlString = [this.header, xmlString];
            end
            
        end
        
        function generatePZFX(this, data, groups)
            this.PZFXColumnCountWarningFlag = 0;
            numberOfCycles = this.timeController.getNumberOfCycles();
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            groupNames = this.experiment.getGroups();
            tableType = get(this.dropdownHandle, 'Value');
            if ~(isequal(tableType, 1) || isequal(tableType, 2))
                for group = 1 : size(data, 2)
                    Table = [];   
                    if isequal(tableType, 3)
                       concentrationsOfGroup = this.experiment.getTreatmentsConcentrationsOfGroup(groups{group}, 1);
                       treatmentUniquenessTable = this.createTreatmentUniquenessTable(size(data, 2), groups, data);
                       treatment = findLargestDimention(concentrationsOfGroup, treatmentUniquenessTable{group}{2});
                    else
                       treatment = tableType - this.numberOfSpecialXaxis;
                    end

                    concentrationList = [];
                    for subgroup = this.subgroupStartValue : numel(data{group})
                        try
                            [treatments, concentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(1), 1);
                            for element = 1 : numel(groups{group}{subgroup})
                                [treatments, concentrations] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(element), 1);
                                if isequal(strfind(concentrations{1}, 'NaN'), [])
                                   break; 
                                end
                            end

                        catch MException
                           disp(MException) 
                        end
                        concentrationList(end + 1) = str2double(concentrations{1, 1, 1, treatment});
                    end
                    tempTreatmentName = treatments{treatment};

                    if(numberOfCycles > this.PZFXMaxColumns)
                        this.PZFXColumnCountWarningFlag = 1;
                    end
                    
                    for timeIndex = 1 : numberOfCycles
                        if isequal(timeIndex, 1)
                            Table(timeIndex).Title = groupNames{group};
                            Table(timeIndex).XColumn.Title = tempTreatmentName{1};
                            Table(timeIndex).XColumn.Subcolumn.d = concentrationList;

                        else

                        end

                        for subgroup = this.subgroupStartValue : numel(data{group})
                            if isequal(timeIndex, 1)
                                Table(timeIndex).XColumn.Subcolumn(subgroup - (this.subgroupStartValue - 1)).d = concentrationList(subgroup - (this.subgroupStartValue - 1));
                            end
                            
                            maxNumberOfSubgroupElements = -1; % consider turning this into a separate function because it is repeating, possibly to ExportPanelController
                            for groupIndex = 1 : numel(groups)
                                maxNumberOfSubgroupElements = max(max(cellfun(@numel,data{groupIndex})), maxNumberOfSubgroupElements); 
                            end
                            
                            for subgroupElement = 1 : maxNumberOfSubgroupElements
                                if isequal(subgroupElement, 1)
                                    Table(timeIndex).YColumn(subgroupElement).Title = timeMoments(cyclesInUse(timeIndex));
                                end
                                if subgroupElement <= size(groups{group}{subgroup}, 1)
                                    Table(timeIndex).YColumn(subgroupElement).Subcolumn(subgroup - (this.subgroupStartValue - 1)).d = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse(timeIndex));
                                else
                                    Table(timeIndex).YColumn(subgroupElement).Subcolumn(subgroup - (this.subgroupStartValue - 1)).d = NaN;
                                end
                            end

                        end
                    end

                    subXML(group).Table = Table;
                end    
                try
                    xmlString = variableToXMLString(subXML);
                catch
                    xmlString = xml_format(subXML, 'off'); % slower function, but gives the same result if the compilation of the previous tool fails
                end
                xmlString = ExcelTableController.fixXMLString(xmlString, data);
                this.xmlString = [this.header, xmlString];
            end
        end
    end
    
    methods(Static)
        
        function xmlString = fixXMLString(xmlString, data)
            xmlString = regexprep(xmlString, '</root>','</GraphPadPrismFile>');
            xmlString = regexprep(xmlString, '<root>','');
            
            xmlString = regexprep(xmlString, '<XColumn/>', '');
            xmlString = regexprep(xmlString, '<XColumn>', '<XColumn Decimals="4" Subcolumns="1">');

            xmlString = regexprep(xmlString, '<Title/>', '');
            xmlString = regexprep(xmlString, '<YColumn>', '<YColumn Decimals="4" Subcolumns="2">');
            
            for tableID = 1 : size(data, 2)
                xmlString = regexprep(xmlString, '<Table>', ['<Table ID="Table', num2str(tableID - 1), '" XFormat="numbers" YFormat="replicates" Replicates="',num2str(max(cellfun(@numel, data{tableID}))),'" TableType="XY">'], 'once');
            end
        end        
        
        function wells = findAllWellsInGroup(group, subgroupStartValue)
            wells = cell(1, 0);
            for subgroup = subgroupStartValue : numel(group)
                for subgroupElement = 1 : numel(group{subgroup})
                    wells{end + 1} = group{subgroup}{subgroupElement};
                end
            end
        end
    end
    
end