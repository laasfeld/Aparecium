classdef FocusAndQualityAnalyzerHandle < handle
    %focusAndQualityAnalyzer Handle object for focusAndQualityAnalyzer
    %   Stores the imageQualityAnalyzer input such as masks and focal
    %   planes in case something goes wrong there
    
    properties
        handle = [];
        newPattern = [];
    end
    
    methods
        
        function this = focusAndQualityAnalyzer(this)
            %Construct an instance of focusAndQualityAnalyzer
        end
        
        function updateHandles(this, handles)
            this.handle = handles;
        end
        
        function setPattern(this, pattern)
            this.newPattern = pattern;
        end
        
        function adaptToNewPattern(this)
            
        end
    end
end

