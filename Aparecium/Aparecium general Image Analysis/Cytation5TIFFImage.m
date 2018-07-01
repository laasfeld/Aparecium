classdef Cytation5TIFFImage < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        imageData
        xmlStruct
    end
    
    methods
        function this = Cytation5TIFFImage(imagePath)
            this.imageData = bfopen(imagePath);
            this.generateXMLStruct();
        end
        
        function image = getImage(this)
           image = this.imageData{1}{1}; 
        end
        
        function imageTime = getImageTime(this)
            this.generateXMLStruct();
            date = this.xmlStruct.ImageReference.Date;
            month = str2double(date(1:2));
            day = str2double(date(4:5));
            year = str2double(['20', date(7:8)]);
            time = this.xmlStruct.ImageReference.Time;
            hour = str2double(time(1:2));
            minute = str2double(time(4:5));
            second = str2double(time(7:8));
            fullDate = [year, month, day, hour, minute, second];
            imageTime = datenum(fullDate);
        end
        
        function wellName = getWellName(this)
            wellName = this.xmlStruct.ImageReference.Well;
        end
        
        function generateXMLStruct(this)
            metadata = this.imageData{1, 2};
            value = metadata.get('Global Comment');
            newValue = regexprep(value, '</Channel>','');
            newValue = ['<BTIImageMetaData>', newValue];
            try
                this.xmlStruct = XMLStringToVariable(newValue);
            catch
                this.xmlStruct = xml_parse(newValue);
            end
        end
        
        function imageFocus = getImageFocus(this)
            imageFocus = str2double(this.xmlStruct.ImageReference.ZStackPosition);
        end
        
        function readStepIndex = getReadStepSequance(this)
            readStepIndex = str2double(this.xmlStruct.ImageReference.ReadStepIndex);
        end
        
        function kineticSequence = getKineticSequence(this)
            kineticSequence = str2double(this.xmlStruct.ImageReference.KineticSequence);
        end
        
    end
    
end