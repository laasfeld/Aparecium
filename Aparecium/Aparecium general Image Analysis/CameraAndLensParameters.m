classdef CameraAndLensParameters < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        magnification = 4 % standard magnification
        pixelSize = 6.45 % standard pixel size of CCD camera in um
        fromImage = 1 % attempt to read the values from the image if possible
    end
    
    methods
        function this = CameraAndLensParameters()
            
        end
    end
    
end

