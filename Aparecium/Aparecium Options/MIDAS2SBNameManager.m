classdef MIDAS2SBNameManager < ChannelManager
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function addNewChannel(channelName, MIDASChannelName, stateOrParam, includeDefault)
           load SBNames.mat
           channelNames(end + 1).channelName = channelName;
           channelNames(end).MIDASChannelName = MIDASChannelName;
           if strcmp(stateOrParam, 'state') || strcmp(stateOrParam, 'param')    
                channelNames(end).stateOrParam = stateOrParam;
           else
               
           end
           channelNames(end).includeDefault = includeDefault;
           MIDAS2SBNameManager.saveChannels(channelNames);
        end 
        
        function channelNames = getChannels()
            load SBNames.mat           
        end        
        
        function changeMIDASChannelName(index, newName)
            channelNames = MIDAS2SBNameManager.getChannels();
            channelNames(index).MIDASChannelName = newName;
            MIDAS2SBNameManager.saveChannels(channelNames);
        end
        
        function changeStateOrParam(index, newStateOrParam)
            channelNames = MIDAS2SBNameManager.getChannels();
            if strcmp(newStateOrParam, 'state') || strcmp(newStateOrParam, 'param')    
                channelNames(index).stateOrParam = newStateOrParam;
            else
               
            end
            MIDAS2SBNameManager.saveChannels(channelNames);
        end
        
        function changeDefaultInclude(index, newDefaultInclude)
            channelNames = MIDAS2SBNameManager.getChannels();
            channelNames(index).includeDefault = newDefaultInclude;
            MIDAS2SBNameManager.saveChannels(channelNames);
        end
        
        function saveChannels(channelNames) % it is used, ignore warning
           filename = mfilename('fullpath');
           thisPath = fileparts(filename);
           save([thisPath, '\SBNames.mat'], 'channelNames'); 
        end
        
        function deleteChannel(index)
            channelNames = MIDAS2SBNameManager.getChannels();
            channelNames(index) = [];
            MIDAS2SBNameManager.saveChannels(channelNames);
        end
        
        function MIDASChannels = getMIDASChannelNames(inputChannels)
            channelNames = MIDAS2SBNameManager.getChannels();
            for channelToFindIndex = 1 : numel(inputChannels)
                nameFound = 0;
                for channelToCompareWithIndex = 1 : numel(channelNames)
                    if strcmp( strtrim(inputChannels{channelToFindIndex}), strtrim(channelNames(channelToCompareWithIndex).channelName))
                       MIDASChannels{channelToFindIndex} = channelNames(channelToCompareWithIndex).MIDASChannelName;
                       nameFound = 1;
                    end
                end
                if isequal(nameFound, 0)
                    MIDASChannels{channelToFindIndex} = inputChannels{channelToFindIndex};
                end
            end
            
        end
        
        function stateOrParam = getDefaultStateOrParam(inputChannels, varargin)
            % varargin, if present, should contain a single cell where the
            % cell value is either 'state' or 'param'. If not present then
            % everything is considered to be a state
            if isequal(numel(varargin), 0)
                defaultStateOrParam = 'state';
            elseif isequal(numel(varargin), 1)
                defaultStateOrParam = varargin{1};
            end
            
            channelNames = MIDAS2SBNameManager.getChannels();
            for channelToFindIndex = 1 : numel(inputChannels)
                nameFound = 0;
                for channelToCompareWithIndex = 1 : numel(channelNames)
                    if strcmp( strtrim(inputChannels{channelToFindIndex}), strtrim(channelNames(channelToCompareWithIndex).channelName))
                       stateOrParam{channelToFindIndex} = channelNames(channelToCompareWithIndex).stateOrParam;
                       nameFound = 1;
                    end
                end
                if isequal(nameFound, 0)
                    stateOrParam{channelToFindIndex} = defaultStateOrParam;
                end
            end                    
        end
        
        function include = getDefaultInclude(inputChannels, varargin)
            % varargin, if present, should contain a single cell where the
            % cell value is either true (all parameters which are not
            % defined are included by default) or false (all parameters
            % which are not defined are not included by default
            if isequal(numel(varargin), 0)
                defaultInclude = true;
            elseif isequal(numel(varargin), 1)
                defaultInclude = varargin{1};
            end
            
            channelNames = MIDAS2SBNameManager.getChannels();
            for channelToFindIndex = 1 : numel(inputChannels)
                nameFound = 0;
                for channelToCompareWithIndex = 1 : numel(channelNames)
                    if strcmp( strtrim(inputChannels{channelToFindIndex}), strtrim(channelNames(channelToCompareWithIndex).channelName))
                       include{channelToFindIndex} = logical(channelNames(channelToCompareWithIndex).includeDefault);
                       nameFound = 1;
                    end
                end
                if isequal(nameFound, 0)
                    include{channelToFindIndex} = defaultInclude;
                end
            end                    
        end
        
    end
    
end

