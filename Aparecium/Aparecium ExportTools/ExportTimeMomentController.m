classdef ExportTimeMomentController < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        cyclesInUse
        experiment
        listBoxHandle
        cycleTimes
        fastKinetics 
        timeUnitConversionConstant = 1;
        timeUnit = 's';
    end
    
    methods
        function this = ExportTimeMomentController(experiment)
            this.experiment = experiment;
        end
        
        function fastKinetics = getFastKinetics(this)
           fastKinetics = this.fastKinetics; 
        end
        
        function constant = getUnitConversionConstant(this)
            constant = this.timeUnitConversionConstant;
        end
        
        function setTimeUnit(this, timeUnit)
            switch timeUnit
                case 'ms'
                    this.timeUnitConversionConstant = 1000;
                    this.timeUnit = timeUnit;
                case 's'
                    this.timeUnitConversionConstant = 1;
                    this.timeUnit = timeUnit;
                case 'min'
                    this.timeUnitConversionConstant = 1/60;
                    this.timeUnit = timeUnit;
                case 'h'
                    this.timeUnitConversionConstant = 1/3600;
                    this.timeUnit = timeUnit;
                otherwise
                    warndlg('Such time unit is not defined for this program');                  
            end
            this.cycleTimes = this.experiment.getCycleTimeMoments()*this.timeUnitConversionConstant;
            this.updateTable();
        end
        
        function timeUnit = getTimeUnit(this)
            timeUnit = this.timeUnit;
        end
        
        function setCycleListHandle(this, listBoxHandle)
           this.listBoxHandle = listBoxHandle;
           this.cycleTimes = this.experiment.getCycleTimeMoments()*this.timeUnitConversionConstant;
           this.cyclesInUse = 1 : this.experiment.getNumberOfCycles;
           if numel(this.cycleTimes) > numel(this.cyclesInUse)
               this.fastKinetics = 1;
               this.updateToFastKinetics();
           else
               this.fastKinetics = 0;
               this.updateToSlowKinetics();
           end
        end
        
        function changeCycleListHandle(this, listBoxHandle)
           this.listBoxHandle = listBoxHandle;
           this.cycleTimes = this.experiment.getCycleTimeMoments()*this.timeUnitConversionConstant;
           this.updateTable();
        end
        
        function updateToFastKinetics(this)
            listBoxData = cell(numel(this.cyclesInUse), 1);
            for cycle = 1 : numel(this.cyclesInUse)
                listBoxData{cycle} = ['cycle', num2str(this.cyclesInUse(cycle)),' @', num2str(min(this.cycleTimes(:, this.cyclesInUse(cycle)))), '-', num2str(max(this.cycleTimes(:, this.cyclesInUse(cycle))))]; 
            end
            set(this.listBoxHandle, 'String', listBoxData);
        end
        
        function updateToSlowKinetics(this)
            listBoxData = cell(numel(this.cyclesInUse), 1);
            for cycle = 1 : numel(this.cyclesInUse)
                listBoxData{cycle} = ['cycle', num2str(this.cyclesInUse(cycle)),' @', num2str(this.cycleTimes(this.cyclesInUse(cycle)))]; 
            end
            set(this.listBoxHandle, 'String', listBoxData);
        end
        
        function updateTable(this)
           switch this.fastKinetics
               case 0
                   this.updateToSlowKinetics();
               case 1
                   this.updateToFastKinetics();
           end 
        end
        
        function resetToExperiment(this)
           this.timeUnit = 's';
           this.cycleTimes = this.experiment.getCycleTimeMoments();
           this.cyclesInUse = 1 : this.experiment.getNumberOfCycles;
           this.updateTable();            
        end
        
        function numberOfCycles = getNumberOfCycles(this)
           numberOfCycles = numel(this.cyclesInUse); 
        end
        
        function cyclesInUse = getCyclesInUse(this)
           cyclesInUse = this.cyclesInUse; 
        end
        
        function cycleTimes = getCycleTimes(this)
           cycleTimes = this.cycleTimes; 
        end
        
        function removeSelectedCycles(this)
            selectedItems = get(this.listBoxHandle, 'Value');
            this.cyclesInUse(selectedItems) = [];
            this.updateTable();
            set(this.listBoxHandle, 'Value', 1);
        end
        
        function removeDeselectedCycles(this)
           selectedItems = get(this.listBoxHandle, 'Value');
           this.cyclesInUse = this.cyclesInUse(selectedItems);
           this.updateTable();
           set(this.listBoxHandle, 'Value', 1);
           
        end
    end
end