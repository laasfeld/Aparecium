function expFileWriter(experimentName, initialConditions, representingWell, changeEvent, eventTimes, experimentTreatmentNames, experimentStateOrParam ,name)
%UNTITLED2 Writes the .exp file needed for SBToolbox2 experiment import
%   Detailed explanation goes here
concentrationChangeEvent = cell(size(changeEvent));
paramChangeEvent = cell(size(changeEvent));
noOfEvents = size(eventTimes{representingWell},2) - 1;
try
    for well = 1 : numel(changeEvent)
        concentrationChangeEvent{well} = cell(size(changeEvent{well}));
        paramChangeEvent{well} = cell(size(changeEvent{well}));
        for event = 1 : numel(changeEvent{well})
            for treatment = 1 : size(changeEvent{well}{event}, 2)
                if strcmp(experimentStateOrParam{treatment}, 'state')
                    concentrationChangeEvent{well}{event}(end + 1) = changeEvent{well}{event}(treatment);
                elseif strcmp(experimentStateOrParam{treatment}, 'param')
                    paramChangeEvent{well}{event}(end + 1) = changeEvent{well}{event}(treatment);
                end
            end
        end
    end
catch MException
    'siin'
end

experimentStateNames = cell(0, 1);
experimentParamsNames = cell(0, 1);

for treatment = 1 : numel(experimentTreatmentNames)
    if strcmp(experimentStateOrParam{treatment}, 'state')
        experimentStateNames{end + 1} = experimentTreatmentNames{treatment};
    elseif strcmp(experimentStateOrParam{treatment}, 'param')
        experimentParamsNames{end + 1} = experimentTreatmentNames{treatment};
    end
end


noOfEffectiveEvents = 0;
effectiveEvent = [];
for event = 2 : noOfEvents + 1
    try
        for treatment = 1 : size(concentrationChangeEvent{representingWell}{1}, 2)
            if ~isequal(concentrationChangeEvent{representingWell}{event - 1}(treatment), 0)
                noOfEffectiveEvents = noOfEffectiveEvents + 1;
                effectiveEvent(end + 1) = event;
                break;
            end
        end
    catch
        
    end
end


noOfEffectiveParamEvents = 0;
effectiveEventWithParams = [];
for event = 2 : noOfEvents + 1
    try
        for treatment = 1 : size(paramChangeEvent{representingWell}{1}, 2)
            if ~isequal(concentrationChangeEvent{representingWell}{event - 1}(treatment), 0)
                noOfEffectiveParamEvents = noOfEffectiveParamEvents + 1;
                effectiveEventWithParams(end + 1) = event;
                break;
            end
        end
    catch
        
    end
end
    
eventStrings = cell(noOfEffectiveEvents, 1);

for event = 1 : noOfEffectiveEvents
    eventStrings{event} = ['time = ',num2str(eventTimes{representingWell}(effectiveEvent(event)))];
    for treatment = 1 : size(concentrationChangeEvent{representingWell}{1},2)
        if ~isequal(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment), 0)
            if concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment) > 0
                if iscell(experimentStateNames{treatment})
                    eventStrings{event} = [eventStrings{event},', ',experimentStateNames{treatment}{1},' = ',experimentStateNames{treatment}{1},' + ',num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                else
                    eventStrings{event} = [eventStrings{event},', ',experimentStateNames{treatment},' = ',experimentStateNames{treatment},' + ',num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                end
            elseif concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment) < 0
                if iscell(experimentStateNames{treatment})
                    eventStrings{event} = [eventStrings{event},', ',experimentStateNames{treatment}{1},' = ',experimentStateNames{treatment}{1},num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                else
                    eventStrings{event} = [eventStrings{event},', ',experimentStateNames{treatment},' = ',experimentStateNames{treatment},num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                end
            end
        end
    end
end

paramEventStrings = cell(noOfEffectiveParamEvents, 1);

for event = 1 : noOfEffectiveParamEvents
    paramEventStrings{event} = ['time = ',num2str(eventTimes{representingWell}(effectiveEventWithParams(event)))];
    for treatment = 1: size(paramChangeEvent{representingWell}{1},2)
        if ~isequal(paramChangeEvent{representingWell}{effectiveEventWithParams(event)-1}(treatment), 0)
            if paramChangeEvent{representingWell}{effectiveEventWithParams(event)-1}(treatment) > 0
                if iscell(experimentStateNames{treatment})
                    paramEventStrings{event} = [paramEventStrings{event},', ',experimentParamsNames{treatment}{1},' = ',experimentParamsNames{treatment}{1},' + ',num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                else                        
                    paramEventStrings{event} = [paramEventStrings{event},', ',experimentParamsNames{treatment},' = ',experimentParamsNames{treatment},' + ',num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                end
            elseif paramChangeEvent{representingWell}{effectiveEventWithParams(event)-1}(treatment) < 0
                if iscell(experimentStateNames{treatment})
                    paramEventStrings{event} = [paramEventStrings{event},', ',experimentParamsNames{treatment}{1},' = ',experimentParamsNames{treatment}{1},num2str(-concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                else 
                    paramEventStrings{event} = [paramEventStrings{event},', ',experimentParamsNames{treatment},' = ',experimentParamsNames{treatment},num2str(-concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
                end
            end
        end
    end
end


fid = fopen(name,'wt');
try
    fprintf(fid,'%s','********** EXPERIMENT NAME')
    fprintf(fid,'\n')
    fprintf(fid,'%s',experimentName)

    fprintf(fid,'\n')
    fprintf(fid,'%s','********** EXPERIMENT NOTES')
    fprintf(fid,'\n')
    fprintf(fid,'%s','********** EXPERIMENT INITIAL PARAMETER AND STATE SETTINGS')
    fprintf(fid,'\n')
    for parameter = 1 : numel(initialConditions)
        fprintf(fid,'%s',initialConditions{parameter})
        fprintf(fid,'\n')
    end
    fprintf(fid,'%s','********** EXPERIMENT PARAMETER CHANGES')
    fprintf(fid,'\n')
    for event = 1 : noOfEffectiveParamEvents
        fprintf(fid,'%s',paramEventStrings{event})
        fprintf(fid,'\n')
    end
    fprintf(fid,'%s','********** EXPERIMENT STATE CHANGES')
    fprintf(fid,'\n')
    for event = 1 : noOfEffectiveEvents
        fprintf(fid,'%s',eventStrings{event})
        fprintf(fid,'\n')
    end
catch
    fclose(fid)
end
fclose(fid)
   
end