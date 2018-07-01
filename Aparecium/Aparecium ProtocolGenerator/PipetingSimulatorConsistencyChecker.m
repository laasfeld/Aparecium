classdef PipetingSimulatorConsistencyChecker < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        expectedNumberOfRows
        expectedNumberOfColumns
        expectedNumberOfTreatments
        
    end
    
    methods
        function this = PipetingSimulatorConsistencyChecker(apareciumExperimentInput)         
            this.expectedNumberOfTreatments = apareciumExperimentInput.getNumberOfTreatments();
            this.expectedNumberOfRows = apareciumExperimentInput.getNumberOfRows();
            this.expectedNumberOfColumns = apareciumExperimentInput.getNumberOfColumns();           
        end
        
        function result = check(this, apareciumExperimentInput)
            result = isequal(this.expectedNumberOfTreatments, apareciumExperimentInput.getNumberOfTreatments()) &&...
            isequal(this.expectedNumberOfRows, apareciumExperimentInput.getNumberOfRows()) &&...
            isequal(this.expectedNumberOfColumns, apareciumExperimentInput.getNumberOfColumns());
        end
        
    end
    
end

