classdef GraphicalPreviewController < ExportPanelController
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        axisHandle = [];
        dropdownHandle = [];
        groupDropdownHandle = [];
        timeUnitConversionConstant = 1;
        graphFormatChooser = [];
        trisurfCheckbox;
        pointsSurfaceCheckbox;
        Xmin;
        Xmax;
        Ymin;
        Ymax;
        Zmin;
        Zmax;
        PlotToExternalFigure = 0;
        markers = [{'+'},{'o'},{'*'},{'x'},{'square'},{'diamond'},{'v'},{'^'},{'>'},{'<'},{'pentagram'},{'hexagram'},{'.'}];
        organizationStyle = 'Group' % Group or subgroup
        holdOn = 0
    end
    
    methods
        function this = GraphicalPreviewController(axis)
            
            this.axisHandle = axis;
            addlistener(this.axisHandle,'XLim','PostSet',@this.updateXAxisBoxes);
            addlistener(this.axisHandle,'YLim','PostSet',@this.updateYAxisBoxes);
            addlistener(this.axisHandle,'ZLim','PostSet',@this.updateZAxisBoxes);
        end
        
        function addExperiment(this, experiment, varargin)
            this.experiment = experiment;
            treatments = this.convertToCellArrayOfStrings(this.experiment.getTreatments());
            set(this.dropdownHandle, 'String', treatments);
        end

        function setTrisurfCheckbox(this, checkbox)
           this.trisurfCheckbox = checkbox;
        end
        
        function setPointsSurfaceCheckbox(this, checkbox)
           this.pointsSurfaceCheckbox = checkbox; 
        end

        function setAxisHandle(this, axisHandle)
           this.axisHandle = axisHandle;
        end
        
        function setGraphFormatDropdownHandle(this, handle)
            this.graphFormatChooser = handle;
        end
        
        function setXAxisChoosingDropdownHandle(this, dropdownHandle)
            this.dropdownHandle = dropdownHandle;
        end
        
        function setGroupDropdownHandle(this, handle)
            this.groupDropdownHandle = handle;
        end

        function updateXAxisBoxes(this,a,b,c)
            lim = get(this.axisHandle, 'XLim');
            set(this.Xmin, 'String', num2str(lim(1)));
            set(this.Xmax, 'String', num2str(lim(2)));
        end
        
        function updateYAxisBoxes(this,a,b,c)
            lim = get(this.axisHandle, 'YLim');
            set(this.Ymin, 'String', num2str(lim(1)));
            set(this.Ymax, 'String', num2str(lim(2)));
        end
        
        function updateZAxisBoxes(this,a,b,c)
            lim = get(this.axisHandle, 'ZLim');
            set(this.Zmin, 'String', num2str(lim(1)));
            set(this.Zmax, 'String', num2str(lim(2)));
        end
        
        function plotToExternalFigure(this, onOrOff)
            switch onOrOff
                case 'on'
                    this.PlotToExternalFigure = 1;
                case 'off'
                    this.PlotToExternalFigure = 0;
            end
        end
        
        function calculateNewTable(this)
            this.calculateNewGraph();
        end
        
        function calculateNewGraph(this)
            if this.PlotToExternalFigure
                figure;
            end
            
            if ~this.PlotToExternalFigure && ~this.holdOn
                cla(this.axisHandle);
            end
            
            [data, groups] = this.calculationMethod.calculate(this.experiment, this.groupStructure, this.sharedBlankStructure, this.timewiseBlankStructure);
            if isequal(this.subgroupNames, [])
                 this.subgroupNames = generateStandardSubgroupNames(data, 1);
            end
            configuration = get(this.graphFormatChooser, 'Value');
            if isequal(configuration, 1)
                if strcmp(this.organizationStyle, 'Group')
                    this.convertDataToKineticGraph(data, groups);
                elseif strcmp(this.organizationStyle, 'Subgroup')
                    this.convertDataToKineticSubgroupGraph(data, groups);
                end
            elseif isequal(configuration, 2)
                if strcmp(this.organizationStyle, 'Group')
                    this.convertDataToConcentrationGraph(data, groups);
                elseif strcmp(this.organizationStyle, 'Subgroup')
                    this.convertDataToConcentrationSubgroupGraph(data, groups);
                end
            elseif isequal(configuration, 3)
                if strcmp(this.organizationStyle, 'Group')
                    this.convertDataTo3DGraph(data, groups);
                elseif strcmp(this.organizationStyle, 'Subgroup')
                    this.convertDataTo3DSubgroupGraph(data, groups);
                end
            end
        end
        
        function updateAxis(this, tableData)
           set(this.tableHandle, 'Data', tableData); 
        end
        
        function setAxisMinMaxBoxes(this, XAxisUpperBound, XAxisLowerBound, YAxisUpperBound, YAxisLowerBound, ZAxisUpperBound, ZAxisLowerBound)
            this.Xmax = XAxisUpperBound;
            this.Xmin = XAxisLowerBound;
            this.Ymax = YAxisUpperBound;
            this.Ymin = YAxisLowerBound;
            this.Zmax = ZAxisUpperBound;
            this.Zmin = ZAxisLowerBound;
        end
        
        function convertDataToKineticSubgroupGraph(this, data, groups)
            subgroup = get(this.groupDropdownHandle, 'Value') + (this.subgroupStartValue - 1);
            subgroupNames = get(this.groupDropdownHandle, 'String');
            subgroupName = subgroupNames{subgroup - (this.subgroupStartValue - 1)};
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            yAxisLabel = this.calculationMethod.formulae{end}.acronyme;
            hold on;
            legends = cell(1, numel(data));
            for group = 1 : numel(data);
                red = rand();
                green = rand();
                blue = rand();
                legends{group} = [ subgroupName, ' group ', this.experiment.groups{group}];
                xAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                yAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                
                for subgroupElement = 1 : numel(data{group}{subgroup})
                    if isequal(this.experiment.fastKinetics, 1)
                        wellIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}{subgroupElement});
                        xAxis(:,subgroupElement) = timeMoments(wellIndex, cyclesInUse);
                    else
                        xAxis(:,subgroupElement) = timeMoments(cyclesInUse);
                    end
                    yAxis(:,subgroupElement) = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse);
                end
                
                xAxis = reshape(xAxis, numel(xAxis), 1);
                yAxis = reshape(yAxis, numel(yAxis), 1);
                try
                    plot(xAxis, yAxis, 'Marker', this.markers{mod(group, numel(this.markers))}, 'Line', 'none', 'MarkerEdgeColor',[red green blue]);
                catch MException
                    if strcmp(MException.message, 'There is no Line property on the Line class.') 
                        plot(xAxis, yAxis, this.markers{mod(group, numel(this.markers))}, 'MarkerEdgeColor',[red green blue]);
                    end
                end

                hold on;
            end
            xlim auto;
            ylim auto;
            zlim auto;
            legend(legends);
            xlabel(['time (', this.timeController.timeUnit, ')']);
            ylabel(yAxisLabel);
            zlabel('');
            hold off;
        end           
        
        function convertDataToKineticGraph(this, data, groups)
            group = get(this.groupDropdownHandle, 'Value');
            groupNames = get(this.groupDropdownHandle, 'String');
            groupName = groupNames{group};
            yAxisLabel = this.calculationMethod.formulae{end}.acronyme;
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            hold on;
            legends = cell(1, numel(data{group}) - 1);

            for subgroup = this.subgroupStartValue : numel(data{group})
                red = rand();
                green = rand();
                blue = rand();
                legends{subgroup - (this.subgroupStartValue - 1)} = ['group ', groupName, ' ', this.subgroupNames{group}{subgroup}]; 
                xAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                yAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                for subgroupElement = 1 : numel(data{group}{subgroup})
                    if isequal(this.experiment.fastKinetics, 1)
                        wellIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}{subgroupElement});
                        xAxis(:,subgroupElement) = timeMoments(wellIndex, cyclesInUse);
                    else
                        xAxis(:,subgroupElement) = timeMoments(cyclesInUse);
                    end
                    yAxis(:,subgroupElement) = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse);
                end
                xAxis = reshape(xAxis, numel(xAxis), 1);
                yAxis = reshape(yAxis, numel(yAxis), 1);
                try
                    plot(xAxis, yAxis, 'Marker', this.markers{mod(group, numel(this.markers))}, 'Line', 'none', 'MarkerEdgeColor',[red green blue]);
                catch MException
                    if strcmp(MException.message, 'There is no Line property on the Line class.') 
                        plot(xAxis, yAxis, this.markers{mod(group, numel(this.markers))}, 'MarkerEdgeColor',[red green blue]);
                    end
                end

                hold on;
            end

            xlim auto;
            ylim auto;
            zlim auto;
            legend(legends);
            xlabel(['time (', this.timeController.timeUnit, ')']);
            ylabel(yAxisLabel);
            zlabel('');
            hold off;
        end
        
        function convertDataToConcentrationSubgroupGraph(this, data, groups)
            treatmentIndex = get(this.dropdownHandle, 'Value');
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            yAxisLabel = this.calculationMethod.formulae{end}.acronyme;
            
            subgroup = get(this.groupDropdownHandle, 'Value') + (this.subgroupStartValue - 1);
            legends = cell(1, numel(cyclesInUse));
            
            xAxis = [];
            for group = 1 : numel(data)
                for subgroupElement = 1 : numel(data{group}{subgroup})
                    [treatmentNames, treatmentValues] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                    treatmentConcentration = treatmentValues{treatmentIndex};
                    xAxis(end+1) = str2double(treatmentConcentration);
                end
            end
            
            
            for timeMoment = 1 : numel(cyclesInUse)               
                yAxis = [];
                for group = 1 : numel(data)
                    for subgroupElement = 1 : numel(data{group}{subgroup})
                        yAxis(end+1) = data{group}{subgroup}{subgroupElement}{1}((cyclesInUse(timeMoment)));
                    end
                end
                red = rand();
                green = rand();
                blue = rand();
                try
                    plot(xAxis, yAxis, 'Marker', this.markers{mod(timeMoment, numel(this.markers)) + 1}, 'Line', 'none', 'MarkerEdgeColor',[red green blue]);
                catch MException
                    if strcmp(MException.message, 'There is no Line property on the Line class.') 
                        plot(xAxis, yAxis, this.markers{mod(timeMoment, numel(this.markers)) + 1}, 'MarkerEdgeColor',[red green blue]);
                    end
                end
                hold on;
                legends{timeMoment} = ['time: ', num2str(timeMoments(cyclesInUse(timeMoment)))]; 
            end
            xlim auto;
            ylim auto;
            zlim auto;
            legend(legends);
            xlabel(treatmentNames{treatmentIndex});
            ylabel(yAxisLabel);  
            zlabel('');                 
        end
        
        function convertDataToConcentrationGraph(this, data, groups)            
            treatmentIndex = get(this.dropdownHandle, 'Value');
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();
            yAxisLabel = this.calculationMethod.formulae{end}.acronyme;
            group = get(this.groupDropdownHandle, 'Value');
            legends = cell(1, numel(cyclesInUse));
            
            xAxis = [];
            for subgroup = this.subgroupStartValue : numel(data{group})
                for subgroupElement = 1 : numel(data{group}{subgroup})
                    [treatmentNames, treatmentValues] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                    treatmentConcentration = treatmentValues{treatmentIndex};
                    xAxis(end+1) = str2double(treatmentConcentration);
                end
            end
            
            
            for timeMoment = 1 : numel(cyclesInUse)               
                yAxis = [];
                for subgroup = this.subgroupStartValue : numel(data{group})
                    for subgroupElement = 1 : numel(data{group}{subgroup})
                        yAxis(end+1) = data{group}{subgroup}{subgroupElement}{1}((cyclesInUse(timeMoment)));
                    end
                end
                red = rand();
                green = rand();
                blue = rand();
                try
                    plot(xAxis, yAxis, 'Marker', this.markers{mod(timeMoment, numel(this.markers)) + 1}, 'Line', 'none', 'MarkerEdgeColor',[red green blue]);
                catch MException
                    if strcmp(MException.message, 'There is no Line property on the Line class.') 
                        plot(xAxis, yAxis, this.markers{mod(timeMoment, numel(this.markers)) + 1}, 'MarkerEdgeColor',[red green blue]);
                    end
                end
                hold on;
                legends{timeMoment} = ['time: ', num2str(timeMoments(cyclesInUse(timeMoment)))]; 
            end
            xlim auto;
            ylim auto;
            zlim auto;
            legend(legends);
            xlabel(treatmentNames{treatmentIndex});
            ylabel(yAxisLabel);  
            zlabel('');
        end
        
        function convertDataTo3DSubgroupGraph(this, data, groups)
            zAxisLabel = this.calculationMethod.formulae{end}.acronyme;
            treatmentIndex = get(this.dropdownHandle, 'Value');
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();

            red = 191/255;
            green = 27/255;
            blue = 209/255;
            hold on;
            marker = '*';
            
            subgroup = get(this.groupDropdownHandle, 'Value') + (this.subgroupStartValue - 1);
            subgroupNames = get(this.groupDropdownHandle, 'String');
            subgroupName = subgroupNames{subgroup - (this.subgroupStartValue - 1)};
                       
            xStack = [];
            yStack = [];
            zStack = [];
            for group = 1 : numel(data)
                xAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                zAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                for subgroupElement = 1 : numel(data{group}{subgroup})
                    [treatmentNames, treatmentValues] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                    treatmentConcentration = str2double(treatmentValues{treatmentIndex});
                    if isequal(this.experiment.fastKinetics, 1)
                        wellIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}{subgroupElement});
                        xAxis(:,subgroupElement) = timeMoments(wellIndex, cyclesInUse);
                    else
                        xAxis(:,subgroupElement) = timeMoments(cyclesInUse);
                    end
                    zAxis(:,subgroupElement) = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse);
                end
                xAxis = reshape(xAxis, numel(xAxis), 1);
                zAxis = reshape(zAxis, numel(zAxis), 1);
                yAxis(1:numel(xAxis),1) = treatmentConcentration;
                xStack(end+1:end+numel(xAxis)) = xAxis;
                yStack(end+1:end+numel(yAxis)) = yAxis;
                zStack(end+1:end+numel(zAxis)) = zAxis;
                if get(this.pointsSurfaceCheckbox, 'Value')
                    try
                        plot3(xAxis, yAxis, zAxis, 'Marker', marker, 'Line', 'none', 'MarkerEdgeColor', [red green blue]);
                    catch MException
                        if strcmp(MException.message, 'There is no Line property on the Line class.') 
                            plot3(xAxis, yAxis, zAxis, marker, 'MarkerEdgeColor', [red green blue]);
                        end 
                    end
                end
                hold on;
            end
            
            if get(this.trisurfCheckbox, 'Value')
                try
                    trisurf(delaunay(xStack, yStack, {'QJ'}), xStack, yStack, zStack);
                catch MException
                    if strcmp(MException.identifier, 'MATLAB:delaunay:DeprecatedQhullOptionsDelaunay'); 
                        trisurf(delaunay(xStack, yStack), xStack, yStack, zStack);
                    end                  
                end
            end
            xlim auto;
            ylim auto;
            zlim auto;
            legend(['3D of ', subgroupName]);
            hold off;
            xlabel(['time (', this.timeController.timeUnit, ')']);
            ylabel(treatmentNames{treatmentIndex});
            zlabel(zAxisLabel);  
        end
        
        function convertDataTo3DGraph(this, data, groups)
            zAxisLabel = this.calculationMethod.formulae{end}.acronyme;
            treatmentIndex = get(this.dropdownHandle, 'Value');
            cyclesInUse = this.timeController.getCyclesInUse();
            timeMoments = this.timeController.getCycleTimes();

            red = 191/255;
            green = 27/255;
            blue = 209/255;
            hold on;
            marker = '*';

            group = get(this.groupDropdownHandle, 'Value');
            groupNames = get(this.groupDropdownHandle, 'String');
            groupName = groupNames{group};
            xStack = [];
            yStack = [];
            zStack = [];
            for subgroup = this.subgroupStartValue : numel(data{group})
                xAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                zAxis = zeros(numel(cyclesInUse), numel(data{group}{subgroup}));
                for subgroupElement = 1 : numel(data{group}{subgroup})
                    [treatmentNames, treatmentValues] = this.experiment.getTreatmentsOfWell(groups{group}{subgroup}(subgroupElement), 1);
                    treatmentConcentration = str2double(treatmentValues{treatmentIndex});
                    if isequal(this.experiment.fastKinetics, 1)
                        wellIndex = this.experiment.getIndexOfUsedWell(groups{group}{subgroup}{subgroupElement});
                        xAxis(:,subgroupElement) = timeMoments(wellIndex, cyclesInUse);
                    else
                        xAxis(:,subgroupElement) = timeMoments(cyclesInUse);
                    end
                    zAxis(:,subgroupElement) = data{group}{subgroup}{subgroupElement}{1}(cyclesInUse);
                end
                xAxis = reshape(xAxis, numel(xAxis), 1);
                zAxis = reshape(zAxis, numel(zAxis), 1);
                yAxis(1:numel(xAxis),1) = treatmentConcentration;
                xStack(end+1:end+numel(xAxis)) = xAxis;
                yStack(end+1:end+numel(yAxis)) = yAxis;
                zStack(end+1:end+numel(zAxis)) = zAxis;
                if get(this.pointsSurfaceCheckbox, 'Value')
                    try
                        plot3(xAxis, yAxis, zAxis, 'Marker', marker, 'Line', 'none', 'MarkerEdgeColor', [red green blue]);
                    catch MException
                        if strcmp(MException.message, 'There is no Line property on the Line class.') 
                            plot3(xAxis, yAxis, zAxis, marker, 'MarkerEdgeColor', [red green blue]);
                        end 
                    end
                end
                hold on;
            end
                        
            pointXYStack = [xStack',yStack'];
            uniquePointXYStack = unique(pointXYStack, 'rows');
            meanZPoints = zeros(size(uniquePointXYStack, 1), 1);
            for index = 1 : size(uniquePointXYStack, 1)
                [~,indx]=ismember(pointXYStack,uniquePointXYStack(index,:),'rows');
                meanZPoints(index) = mean(zStack(indx==1));
            end
            
            if get(this.trisurfCheckbox, 'Value')
                try
                    trisurf(delaunay(uniquePointXYStack(:,1), uniquePointXYStack(:,2), {'QJ'}), uniquePointXYStack(:,1), uniquePointXYStack(:,2), meanZPoints);
                catch MException
                    if strcmp(MException.identifier, 'MATLAB:delaunay:DeprecatedQhullOptionsDelaunay'); 
                        trisurf(delaunay(uniquePointXYStack(:,1), uniquePointXYStack(:,2)), uniquePointXYStack(:,1), uniquePointXYStack(:,2), meanZPoints);
                    end                  
                end
            end
            xlim auto;
            ylim auto;
            zlim auto;
            legend(['3D of group ', num2str(groupName)]);
            hold off;
            xlabel(['time (', this.timeController.timeUnit, ')']);
            ylabel(treatmentNames{treatmentIndex});
            zlabel(zAxisLabel);            
        end
        
        function updateGraphic(this)

            XLim = [str2double(get(this.Xmin, 'String')), str2double(get(this.Xmax, 'String'))];
            YLim = [str2double(get(this.Ymin, 'String')), str2double(get(this.Ymax, 'String'))];
            ZLim = [str2double(get(this.Zmin, 'String')), str2double(get(this.Zmax, 'String'))];
            try
                set(this.axisHandle, 'XLim', XLim, 'YLim', YLim, 'ZLim', ZLim);
            catch Error
                wrongLimitIdentifier = 'MATLAB:hg:propswch:PropertyError';
                if strcmp(Error.identifier, wrongLimitIdentifier)
                    displayMessage = 'Lower limit can´t be higher than upper limit';
                    disp(displayMessage);
                    warndlg(displayMessage, 'Warning');
                else
                   disp(Error);
                end
            end
        end
        
        function copyAxesToNewFigure(this)
            handle = figure;
            copyobj(this.axisHandle, handle);
        end
        
        function exportWithName(this, name)
            
            handle = figure;
            copyobj(this.axisHandle, handle);
            saveas(handle, name);
            set(handle, 'visible','off');
        end
        
        function exportWithDialogue(this)
            if isdeployed
                load([pwd, '\', 'settings.mat']);
            else
                load settings
            end
            startingPath = settings.Excel;
            [FileName,FilePath] = uiputfile({'.fig'}, '', startingPath);
            outputFilename = [FilePath, '\', FileName];
            this.exportWithName(outputFilename);           
        end
        
        function sendToWorkspace(this)
            assignin('base', 'Axis_handle', this.axisHandle);
        end
    end
end