function [ concChangeEvent, eventTimes ] = EventReader(handles)

data = handles.data;
noOfWells = size(handles.ID, 1)*size(handles.ID, 2);
timepoints = size(handles.time, 2);
noOfChannels = handles.noc;
data = reshape(data, noOfWells, timepoints, size(data, 2));
%previousConcentration(:,:) = data(:,1,:);
%previousConcentration(:,:) = 0;
eventList = cell(noOfWells, 1);
isevent = cell(noOfWells, 1);
eventTimes = cell(noOfWells, 1);
for well = 1 : noOfWells
   eventList{well} = cell(0); 
end
for timepoint = 1 : timepoints
   eventData(:, :) = data(:, timepoint, :);
   for well = 1 : noOfWells
      for channel = 1 : noOfChannels
         if isequal(num2str(eventData(well, end + 1 - channel)), 'NaN')
             isevent{well} = true;
         else
             isevent{well} = false;
             break;
         end
      end
   end
   for well = 1 : noOfWells
       
       for substance = size(data, 3) - noOfChannels - 1
           if isequal(isevent{well}, 1)
                eventTimes{well}(end + 1) = eventData(well, end - noOfChannels);
                eventList{well}{end + 1}(substance) = eventData(well, substance);    
           end
       end
   end
end
concChangeEvent = cell(noOfWells, 1);
for well = 1 : noOfWells
   concChangeEvent{well} = cell(0); 
end
for well = 1 : noOfWells      
    for event = 2 : size(eventList{well}, 2)
        for substance = 1 : size(data,3) - noOfChannels - 1
            concChangeEvent{well}{event - 1} = eventList{well}{event} - eventList{well}{event - 1};   
        end
    end
end
 
end
