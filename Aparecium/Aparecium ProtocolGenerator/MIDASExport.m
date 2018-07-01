classdef MIDASExport < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        exportName = ''
        groupNames
        groupStructure
        subgroupNames
        sharedBlankStructure
        timewiseBlankStructure
        timwiseBlankAlignment = 'first';
        calculationMethod
        timeUnit
        exportType % indicates if export should be figure, excel table or systems biology export
        %% variables for Excel type of table
        tableType % indicates what kind of table type to use
        xAxisTypeTable % indicates which kind of xAxis to use for excel type of table
        tableOrganizationStyle % indicates which kind of table organization style to use for excel type of table
        organizationStyleGroups = 'Groups';
        organizationStyleSubgroups = 'Subgroups';
        excelOrPrism = 'Prism';
        prism = 'Prism';
        %% variables for SB type of table
        variableNames % a table of variable names
        fastKineticsExportMethod % show if merge or average should be used
        average = 'average';
        merge = 'merge'
        %% variables for figure
        graphFormat % indicates what kind of graphFormat to use
        timeDependant = 'Time dependant';
        concentrationDependant = 'Concentration dependant';
        threeD = '3D';
        xAxisTypeFigure % indicates what kind of x axis to use on figure
        activeGroup % indicates which groups graph to use
        surface % indicates is surface should be used
        points % indicates if points should be used 
        
        
        excel = 'Excel';
        SB = 'SB';
        figure = 'figure';
    end
    
    methods
        function this = MIDASExport()
            
        end
        
        function setGroupNames(this, groupNames)
            this.groupNames = groupNames;
        end
        
        function groupNames = getGroupNames(this)
            groupNames = this.groupNames;
        end
        
        function setGroupStructure(this, groupStructure)
            this.groupStructure = groupStructure;
        end
        
        function groupStructure = getGroupStructure(this)
            groupStructure = this.groupStructure;
        end
        
        function setCalculationMethod(this, calculationMethod)
            this.calculationMethod = calculationMethod;
        end
        
        function calculationMethod = getCalculationMethod(this)
            calculationMethod = this.calculationMethod;
        end
        
        function setExportType(this, exportType)
           switch exportType
               case this.excel
                   this.exportType = this.excel;
               case this.SB
                   this.exportType = this.SB;
               case this.figure
                   this.exportType = this.figure;
           end
        end
        
        function exportType = getExportType(this)
            exportType = this.exportType;
        end
        
        function setTableType(this, tableType)
           this.tableType = tableType;
        end
        
        function setSubgroupNames(this, subgroupNames)
           this.subgroupNames = subgroupNames; 
        end
        
        function subgroupNames = getSubgroupNames(this)
           subgroupNames = this.subgroupNames; 
        end
        
        function setSharedBlankStructure(this, sharedBlankStructure)
           this.sharedBlankStructure = sharedBlankStructure; 
        end
        
        function sharedBlankStructure = getSharedBlankStructure(this)
           sharedBlankStructure = this.sharedBlankStructure; 
        end
        
        function setTimewiseBlankStructure(this, timewiseBlankStructure)
           this.timewiseBlankStructure = timewiseBlankStructure; 
        end
        
        function timewiseBlankStructure = getTimewiseBlankStructure(this)
            timewiseBlankStructure = this.timewiseBlankStructure;
        end
        
        function setTimwiseBlankAlignment(this, alignment)
            this.timwiseBlankAlignment = alignment; % possible options: 'first', 'last' 
        end
        
        function timewiseBlankAlignment = getTimewiseBlankAlignment(this)
            timewiseBlankAlignment = this.timwiseBlankAlignment;
        end
        
        function setTimeUnit(this, timeUnit)
            this.timeUnit = timeUnit;
        end
        
        function timeUnit = getTimeUnit(this)
           timeUnit = this.timeUnit; 
        end
    end
end