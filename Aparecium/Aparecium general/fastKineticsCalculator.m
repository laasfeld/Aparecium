function [ specificTimeForWell ] = fastKineticsCalculator(ID,readingFormat, cycleTime, time )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
     timePerWell=cycleTime/size(ID, 1);
        load('plate96WellLayout')
        
        % remove any spaces from ID
        for index = 1 : numel(ID)
           ID{index} = regexprep(ID{index}, ' ', '');
           if isequal(numel(ID{index}), 2)
               ID{index} = [ID{index}(1),'0',ID{index}(2)];
           end
        end
        
        switch readingFormat
        % use fliplr to reflect a matrix
        
        case 1 %start from upper left, bidirectional horizontal-Checked
            for i=2:2:size(plate96WellLayout,2)
                plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end

            end
        case 2 %start from upper right, bidirectional horizontal-Checked
            plate96WellLayout=flipud(plate96WellLayout);% flip all rows
            for i=2:2:size(plate96WellLayout,2)
                plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 3%-Checked
            for i=1:size(ID,1)% start upper left horizontal unidirectional
               specificTimeCorrection(i)=timePerWell*(i-1);% i is the index in ID and shows the specifi time correction applied to that well
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 4%-NotChecked
            plate96WellLayout=flipud(plate96WellLayout);% flip all rows
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 5%-Not checked
            plate96WellLayout=fliplr(plate96WellLayout);% flip upside down
            for i=2:2:size(plate96WellLayout,2)
                plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 6%-Not checked

            plate96WellLayout=fliplr(plate96WellLayout);
            plate96WellLayout=flipud(plate96WellLayout);% flip all rows
            for i=2:2:size(plate96WellLayout,2)
                plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 7
            plate96WellLayout=fliplr(plate96WellLayout);% flip upside down
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 8%start bottom right horizontal unidirectional
            plate96WellLayout=flipud(plate96WellLayout);% flip upside down
            plate96WellLayout=fliplr(plate96WellLayout);
            for i=size(ID,1):-1:1
               specificTimeCorrection(i)=timePerWell*(i-1);% i is the index in ID and shows the specifi time correction applied to that well
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 9 
            plate96WellLayout=plate96WellLayout';
            for i=2:2:size(plate96WellLayout,2)
                plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
            end
            a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 10

             plate96WellLayout=flipud(plate96WellLayout);
             plate96WellLayout=plate96WellLayout';
             for i=2:2:size(plate96WellLayout,2)
                 plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
             end
             a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end

        case 11
             plate96WellLayout=plate96WellLayout';
             a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end

        case 12
             plate96WellLayout=flipud(plate96WellLayout);
             plate96WellLayout=plate96WellLayout';
             a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end

        case 13
              plate96WellLayout=fliplr(plate96WellLayout);
              plate96WellLayout=plate96WellLayout';
              for i=2:2:size(plate96WellLayout,2)
                 plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
              end
              a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 14

              plate96WellLayout=flipud(plate96WellLayout);
              plate96WellLayout=fliplr(plate96WellLayout);
              plate96WellLayout=plate96WellLayout';
              for i=2:2:size(plate96WellLayout,2)
                 plate96WellLayout(:,i)=flipud(plate96WellLayout(:,i));% flip every second row
              end
              a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
            k=1;
            for i=1:a
                if(ismember(plate96WellLayout{i}, ID))
                    tempPlate96WellLayout{k}=plate96WellLayout{i};
                    k=k+1;       
                end
            end
        case 15

              plate96WellLayout=plate96WellLayout';
              plate96WellLayout=flipud(plate96WellLayout);
              a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
                k=1;
                for i=1:a
                    if(ismember(plate96WellLayout{i}, ID))
                        tempPlate96WellLayout{k}=plate96WellLayout{i};
                        k=k+1;       
                    end
                end
        case 16

              plate96WellLayout=flipud(plate96WellLayout);
              plate96WellLayout=plate96WellLayout';
              plate96WellLayout=flipud(plate96WellLayout);
              a=size(plate96WellLayout,1)*size(plate96WellLayout,2);
              k=1;
              for i=1:a
                 if(ismember(plate96WellLayout{i}, ID))
                     tempPlate96WellLayout{k}=plate96WellLayout{i};
                     k=k+1;       
                 end
              end         
        end
    specificTimeForWell = zeros(numel(ID), numel(time));
    for i=1:size(ID,1)
        try
           specificTimeForWell(i,:)=time+timePerWell*(find(ismember(tempPlate96WellLayout, ID{i}))-1);% i is the index in ID and shows the specifi time correction applied to that well
        catch
           'siin'
        end
    end
    %time=specificTimeForWell;
end