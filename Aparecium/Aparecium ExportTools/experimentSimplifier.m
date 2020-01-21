classdef experimentSimplifier < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        assumeEquilibriumBeforeFirstEvent = false;
        assumeEquilibriumBeforeLastEvent = false;
        apareciumExperimentInput = [];
    end
    
    methods
        function this = experimentSimplifier(ApareciumExperimentInput)
            this.apareciumExperimentInput = ApareciumExperimentInput;
        end
        
        function setAssumeEquilibriumBeforeFirstEvent(this, value)
            this.assumeEquilibriumBeforeFirstEvent = value;
        end
        
        function assumeEquilibriumBeforeFirstEvent = getAssumeEquilibriumBeforeFirstEvent(this)
            assumeEquilibriumBeforeFirstEvent = this.assumeEquilibriumBeforeFirstEvent;
        end
        
        function setAssumeEquilibriumBeforeLastEvent(this, value)
            this.assumeEquilibriumBeforeLastEvent = value;
        end
        
        function assumeEquilibriumBeforeLastEvent = getAssumeEquilibriumBeforeLastEvent(this)
            assumeEquilibriumBeforeLastEvent = this.assumeEquilibriumBeforeLastEvent;
        end
        
        function data = simplifyData(this, data)
            if this.assumeEquilibriumBeforeFirstEvent && this.assumeEquilibriumBeforeLastEvent
                error('Both assumptions can´t be used at the same time!');
            elseif this.assumeEquilibriumBeforeFirstEvent
                data = equilibriumBeforeFirstEventMetadata(data);
            elseif this.assumeEquilibriumBeforeLastEvent
                data = this.equilibriumBeforeFirstEventData(data);
            else
               % leave data as it is, no simplification needed
            end
        end
        
        function data = equilibriumBeforeFirstEventData(this, data)
            
        end
        
        function data = equilibriumBeforeLastEventData(this, data)
            
        end
        
        function newApareciumExperimentInput = equilibriumBeforeFirstEventMetadata(this)
            newTimeMatrix = this.apareciumExperimentInput.timeMoments;
            newEventTimes = this.apareciumExperimentInput.eventTimes;
            newConcentrationChangeEvents = this.apareciumExperimentInput.concentrationChangeEvents;
            newPredefinedConcentrations = this.apareciumExperimentInput.predefinedConcentrations;
            % Shift the timepoints by time of first event for each well
            for well = 1 : numel(this.apareciumExperimentInput.eventTimes)               
                
                % event at 0 timepoint will not be counter as event
                wellEventTimes = this.apareciumExperimentInput.eventTimes{well};
                nonZeroWellEventTimes = wellEventTimes(wellEventTimes ~= 0);
                if ~isempty(nonZeroWellEventTimes)
                    
                    % Generate new timeMoments table
                    
                    firstEventTime = nonZeroWellEventTimes(1);
                    wellCycleTimes = this.apareciumExperimentInput.timeMoments(well, :);
                    correspondingCycleIndex = find(wellCycleTimes == firstEventTime);
                    
                    beforeEventCycleTimes = wellCycleTimes(1:correspondingCycleIndex);
                    afterEventCycleTimes = wellCycleTimes(correspondingCycleIndex + 1 : end);
                    beforeEventNotNaNs = ~isnan(beforeEventCycleTimes);
                    afterEventNotNaNs = ~isnan(afterEventCycleTimes);
                    beforeEventCycleTimes(beforeEventNotNaNs) = min(beforeEventCycleTimes);
                    afterEventCycleTimes(afterEventNotNaNs) = afterEventCycleTimes(afterEventNotNaNs) - firstEventTime;
                    
                    newTimeMatrix(well, :) = [beforeEventCycleTimes afterEventCycleTimes];
                    
                    % Generate new eventTimes array
                    
                    wellEventTimes = this.apareciumExperimentInput.eventTimes{well};
                    timesToBeChanged = wellEventTimes(2:end);
                    timesToBeChanged = timesToBeChanged - firstEventTime;
                    nonZeroChangedTimes = timesToBeChanged(timesToBeChanged ~= 0);
                    newEventTimes{well} = [0, nonZeroChangedTimes];
                    
                    % Generate new concentrateionChangeEvents
                    
                    % check this with multiple events at the same well
                    newConcentrationChangeEvents{well} = newConcentrationChangeEvents{well}(2:end);
                    
                    % Generate predefinedConcentrationsTable
                    
                    for cycleIndex = 1 : correspondingCycleIndex
                        for treatmentIndex = size(newPredefinedConcentrations, 4)
                            wellID = this.apareciumExperimentInput.getOriginalWellIDOfIndex(well);
                            [rowIndex, columnIndex] = this.apareciumExperimentInput.getRowAndColumnIndecesOfWell(wellID);
                            newPredefinedConcentrations{columnIndex, rowIndex, cycleIndex, treatmentIndex} = newPredefinedConcentrations{columnIndex, rowIndex, correspondingCycleIndex, treatmentIndex};
                        end
                    end
                        
                else
                    
                end
                
                newApareciumExperimentInput = this.apareciumExperimentInput.getSimplificationInvariantClone();
                newApareciumExperimentInput.setPredefinedConcentrations(newPredefinedConcentrations);
                newApareciumExperimentInput.setCycleTimeMoments(newTimeMatrix);
                newApareciumExperimentInput.setConcentrationChangeEvents(newConcentrationChangeEvents);
                newApareciumExperimentInput.setEventTimes(newEventTimes);
            end
        end
        
        function apareciumExperimentInput = equilibriumBeforeLastEventMetadata(this)
        
        end
            
        function apareciumExperimentInput = simplifyEventsAndStartingConditions(this)
            if this.assumeEquilibriumBeforeFirstEvent && this.assumeEquilibriumBeforeLastEvent
                error('Both assumptions can´t be used at the same time!');
            elseif this.assumeEquilibriumBeforeFirstEvent
                apareciumExperimentInput = this.equilibriumBeforeFirstEventMetadata();
            elseif this.assumeEquilibriumBeforeLastEvent
                apareciumExperimentInput = this.equilibriumBeforeLastEventMetadata();
            else
               % leave data as it is, no simplification needed
                apareciumExperimentInput = this.apareciumExperimentInput;
            end
        end
    end
    
end

