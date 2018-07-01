classdef ICSEThresholdManager < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = ICSEThresholdManager()
            
        end
        
    end
    
    methods(Static)
        function functionNames = getThresholdFunctionNames()
            try
                load thresholdFunctionNames.mat % contains variable functionNames
            catch MException
                
            end
            
        end
        
        function functionNames = addNewThreshold(functionName)
            functionNames = cell(0,0);
            try
                load thresholdFunctionNames.mat % contains variable functionNames
            catch MException
                
            end
            functionNames{end + 1} = functionName;
            save('thresholdFunctionNames.mat', 'functionNames');
        end
    end
    
end