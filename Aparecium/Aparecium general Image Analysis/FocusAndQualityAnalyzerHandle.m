classdef FocusAndQualityAnalyzerHandle < handle
    %focusAndQualityAnalyzer Handle object for focusAndQualityAnalyzer
    %   Stores the imageQualityAnalyzer input such as masks and focal
    %   planes in case something goes wrong there
    
    properties
        handle = [];
        focusImageNamePreference = [];
        newPattern = [];
        focusPreferenceSet = false;
    end
    
    methods
        
        function this = focusAndQualityAnalyzer(this)
            %Construct an instance of focusAndQualityAnalyzer
        end
        
        function updateHandles(this, handles)
            this.handle = handles;
        end
        
        function setNewPattern(this, pattern)
            this.newPattern = pattern;
        end
        
        function setPattern(this, pattern)
            this.newPattern = pattern;
        end
        
        function adaptToNewPattern(this)
            
        end
        
        function this = setFocusImageNamePreference(this, imageNamesCell)
            this.focusImageNamePreference = imageNamesCell;
            this.focusPreferenceSet = true;
        end
              
        function focusImageNamePreference = getFocusImageNamePreference(this)
            focusImageNamePreference = this.focusImageNamePreference;
        end
        
        function focusPreferenceSet = isFocusImageNamePreferenceSet(this)
            focusPreferenceSet = this.focusPreferenceSet;
        end
    end
end

