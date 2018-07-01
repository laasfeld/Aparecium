classdef Event < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        startTime
        length
        plateID
        wellName
        treatmentNames
        treatmentConcentrations
        channelNames
        measurements
        eventType
    end
    
    methods
        function this = Event(startTime, length, plateID, wellName, treatmentNames, treatmentConcentrations, channelNames, measurements, eventType)
           this.startTime = startTime;
           this.length = length;
           this.plateID = plateID;
           this.wellName = wellName;
           this.treatmentNames = treatmentNames;
           this.treatmentConcentrations = treatmentConcentrations;
           this.channelNames = channelNames;
           this.measurements = measurements;
           this.eventType = eventType;         
        end
    end
    
end

