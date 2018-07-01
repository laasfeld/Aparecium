function updateMidasChannels(handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    numberOfChannels = handles.apareciumExperimentInput.getNumberOfChannels;
    handles.midasTableController.measurementColumns = numberOfChannels;
    channelName = handles.apareciumExperimentInput.getChannelNames();
    for channel = 1 : numberOfChannels     
        handles.midasTableController.changeChannelHeader(channelName{channel}, channel);
    end

end