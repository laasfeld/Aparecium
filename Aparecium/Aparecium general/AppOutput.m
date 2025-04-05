classdef AppOutput < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        output
    end
    
    methods
        function this = AppOutput(this)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function setOutput(this, output)
            this.output = output;
        end
        
        function output = getOutput(this)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            output = this.output;
        end
    end
end

