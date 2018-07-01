function expFileWriter(experimentName, initialConditions, representingWell, concentrationChangeEvent, eventTimes, experimentParamsNames, name)
%UNTITLED2 Writes the .exp file needed for SBToolbox2 experiment import
%   Detailed explanation goes here

noOfEvents = size(eventTimes{representingWell},2) - 1;
noOfEffectiveEvents = 0;
effectiveEvent = [];
for event = 2 : noOfEvents + 1
    try
        for treatment = 1 : size(concentrationChangeEvent{1}{1}, 2)
            if ~isequal(concentrationChangeEvent{representingWell}{event - 1}(treatment), 0)
                noOfEffectiveEvents = noOfEffectiveEvents + 1;
                effectiveEvent(end + 1) = event;
                break;
            end
        end
    catch
        
    end
end
    
eventStrings = cell(noOfEffectiveEvents, 1);
for event = 1: noOfEffectiveEvents
    eventStrings{event} = ['time = ',num2str(eventTimes{representingWell}(effectiveEvent(event)))];
    for treatment = 1: size(concentrationChangeEvent{1}{1},2)
        if ~isequal(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment), 0)
            if concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment) > 0
                eventStrings{event} = [eventStrings{event},', ',experimentParamsNames{treatment},' = ',experimentParamsNames{treatment},' + ',num2str(concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
            elseif concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment) < 0
                eventStrings{event} = [eventStrings{event},', ',experimentParamsNames{treatment},' = ',experimentParamsNames{treatment},' - ',num2str(-concentrationChangeEvent{representingWell}{effectiveEvent(event)-1}(treatment))];
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
    fprintf(fid,'%s','********** EXPERIMENT STATE CHANGES')
    fprintf(fid,'\n')
    for event = 1: noOfEffectiveEvents
        fprintf(fid,'%s',eventStrings{event})
        fprintf(fid,'\n')
    end
catch
    fclose(fid)
end
fclose(fid)
   
end