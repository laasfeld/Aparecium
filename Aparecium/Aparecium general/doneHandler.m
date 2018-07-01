classdef doneHandler < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handles
        button
        functionHandle
    end
    
    methods
        function this = doneHandler(button, handles, functionHandle)
            this.handles = handles;
            this.button = handle(button, 'CallbackProperties');
            %'functionHandle([], [], this.handles)'
            this.functionHandle = functionHandle;
            set(this.button, 'MouseClickedCallback', @this.callback);
        end
        
        function callback(this, a, b)
            this.functionHandle([], [], this.handles)
        end
    end
    
end

