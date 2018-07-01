classdef Gen5Kinetic < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        orderIndex
        runtime
        interval
        numberOfCycles
        listOfReads
    end
    
    methods
        function this = Gen5Kinetic(startingLine)
            informationString = regexprep(startingLine, 'Start Kinetic', '');
            informationMatrix = strsplit(informationString, ',');
            this.setRuntimeFromString(informationMatrix{1});
            this.setIntervalFromString(informationMatrix{2});
            this.setCyclesFromString(informationMatrix{3});            
        end
        
        function setOrderIndex(this, index)
           this.orderIndex = index; 
        end
        
        function setRuntimeFromString(this, string)
            stringComponents = strsplit(string, ' ');
            timeString = stringComponents{2};
            this.runtime = this.timeStringToSec(timeString); 
        end
        
        function setIntervalFromString(this, string)
           stringComponents = strsplit(string, ' ');
           timeString = stringComponents{2};
           this.interval = this.timeStringToSec(timeString);
        end
        
        function setCyclesFromString(this, string)
            stringComponents = strsplit(string, ' ');
            this.numberOfCycles = str2double(stringComponents{1});
        end      
        
        function read = addEmptyRead(this)
            this.listOfReads{end + 1} = Gen5Read;
            read = this.listOfReads{end};
            read.setNumberOfCycles(this.numberOfCycles);
            read.setRuntime(this.runtime);
            read.setInterval(this.interval);
        end
        
    end
    
    methods(Static)
        function sec = timeStringToSec(string)
            timeComponents = strsplit(string, ':');
            sec = 3600*str2double(timeComponents{1}) + 60*str2double(timeComponents{2}) + str2double(timeComponents{3});
        end 
    end
    
end