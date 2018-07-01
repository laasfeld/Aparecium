classdef ChannelManager < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        channelFilePath
    end
    
    methods
        function this = ChannelManager()
            
        end
    end
    
    methods(Static)
        function addNewChannel(channelName, MIDASChannelName)
           load channelNames.mat
           channelNames(end + 1).channelName = channelName;
           channelNames(end).MIDASChannelName = MIDASChannelName;
           ChannelManager.saveChannels(channelNames);
        end 
        
        function channelNames = getChannels()
            load channelNames.mat
            
        end
        
        function changeMIDASChannelName(index, newName)
            channelNames = ChannelManager.getChannels();
            channelNames(index).MIDASChannelName = newName;
            ChannelManager.saveChannels(channelNames);
        end
        
        function saveChannels(channelNames) % it is used, ignore warning
           filename = mfilename('fullpath');
           thisPath = fileparts(filename);
           save([thisPath, '\channelNames.mat'], 'channelNames'); 
        end
        
        function deleteChannel(index)
            channelNames = ChannelManager.getChannels();
            channelNames(index) = [];
            ChannelManager.saveChannels(channelNames);
        end
        
        function MIDASChannels = getMIDASChannelNames(inputChannels)
            channelNames = ChannelManager.getChannels();
            for channelToFindIndex = 1 : numel(inputChannels)
                nameFound = 0;
                for channelToCompareWithIndex = 1 : numel(channelNames)
                    if strcmp(inputChannels{channelToFindIndex}, channelNames(channelToCompareWithIndex).channelName)
                       MIDASChannels{channelToFindIndex} = channelNames(channelToCompareWithIndex).MIDASChannelName;
                       nameFound = 1;
                    end
                end
                if isequal(nameFound, 0)
                    MIDASChannels{channelToFindIndex} = inputChannels{channelToFindIndex};
                end
            end
            
        end
    end
    
end

