classdef loadingBar < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        waitbarHandle
        name = 'Exporting:';
    end
    
    methods
        function this = loadingBar()
           this.waitbarHandle = waitbar(0, 'exporting', 'visible', 'off');
           set(this.waitbarHandle, 'visible', 'off');
           drawnow;
        end
        
        function setLoadingBarPercent(this, percent)
            try
                waitbar(percent/100, this.waitbarHandle, [this.name, num2str(round(percent)), '% completed']);
            catch

            end
            drawnow;
        end
        
        function vizualize(this)
            try
                set(this.waitbarHandle, 'visible', 'on');
            catch
                this.waitbarHandle = waitbar(0, 'Exporting');
            end
            drawnow;
        end
        
        function vizualizeWithString(this, name)
            try
                this.name = name;
                set(this.waitbarHandle, 'visible', 'on');
            catch
                this.waitbarHandle = waitbar(0, name);
            end
            drawnow;
        end
        
        function devizualize(this)
            try
                set(this.waitbarHandle, 'visible', 'off');
            catch
                
            end
            drawnow;
        end
    end
    
end

