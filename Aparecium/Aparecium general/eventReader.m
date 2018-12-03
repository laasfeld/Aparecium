function [ concChangeEvent, eventTimes ] = eventReader(handles)
    data = handles.data;
    noOfWells = handles.noOfWells;
    timepoints = handles.noOfCycles;
    noOfChannels = handles.numberOfChannels;
    data = reshape(data, noOfWells, timepoints, size(data, 2));
    previousConcentration(:,:) = data(:,1,:);
    previousConcentration(:,:) = 0;
    eventList = cell(noOfWells,1);
    isevent = cell(noOfWells,1);
    eventTimes = cell(noOfWells,1);
    for well = 1:noOfWells
       eventList{well} = cell(0); 
       event{well} = 0;
    end
    for timepoint = 1:timepoints
       eventData(:,:) = data(:,timepoint,:);
       for well = 1:noOfWells
          % first event
         if isempty(eventList{well})
             isevent{well} = true;
         else
             newConcs = eventData(well,1 : size(data,3)-noOfChannels-1);
             deltaConcentrations = diff([eventList{well}{end}; newConcs]);
             somethingChanged = ~all(deltaConcentrations == 0);
             if somethingChanged
                 for channel = 1:noOfChannels
                     if isequal(num2str(eventData(well,end+1-channel)),'NaN')                
                         isevent{well} = true;
                     else
                         isevent{well} = false;
                         break;
                     end
                 end
             else
                 isevent{well} = false;
             end
         end
       end
       for well = 1:noOfWells
            if isequal(isevent{well},1)
                event{well} = event{well} + 1;
                eventTimes{well}(end + 1) = eventData(well,end-noOfChannels);
                for substance = 1 : size(data,3)-noOfChannels-1
                    eventList{well}{event{well}}(substance) = eventData(well,substance);    
                end
            end
       end
    end
    concChangeEvent = cell(noOfWells,1);
    for well = 1:noOfWells
       concChangeEvent{well} = cell(0); 
    end
    for well = 1 : noOfWells   
        if ~isempty(eventList{well})
            for event = 2 : size(eventList{well}, 2)
                for substance = 1:size(data,3)-noOfChannels-1
                    concChangeEvent{well}{event-1} = eventList{well}{event} - eventList{well}{event-1};   
                end
            end
        end
    end
end