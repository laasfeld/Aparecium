classdef CalculationMethod < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        formulae
        groups
        measurementStructure
        timewiseBlankStructure
        formulaIsSet = 0;
        channelNames
        subgroupStartValue = 1;
        previousValues = 0;
        apareciumExperimentInput = [];
    end
    
    methods
        function this = CalculationMethod(ApareciumExperimentInput)
            this.apareciumExperimentInput = ApareciumExperimentInput;
        end
        
        function addFormulae(this, formulae)
            this.formulaIsSet = 1;
            this.formulae = formulae;
            this.previousValues = [];
        end
        
        function formulae = getFormulae(this)
           formulae = this.formulae; 
        end
        
        function channelNames = getChannelNames(this)
           channelNames = this.channelNames; 
        end
        
        function setSubgroupStartValue(this, subgroupStartValue)
            this.subgroupStartValue = subgroupStartValue;
            this.previousValues = [];
        end
        
        function [result, groups] = calculate(this, experiment, groupingStructure, sharedBlankStructure, timewiseBlankMatrix)
            if isequal(this.previousValues, {experiment, groupingStructure, sharedBlankStructure, timewiseBlankMatrix, this.formulae, this.subgroupStartValue})
                
                result = this.measurementStructure;
                groups = this.groups;
            else
                disp('calculating');
                this.previousValues = {experiment, groupingStructure, sharedBlankStructure, timewiseBlankMatrix, this.formulae, this.subgroupStartValue};
                this.channelNames = experiment.getChannelNames();
                this.groupWells(experiment, groupingStructure, sharedBlankStructure, timewiseBlankMatrix);
                this.generateMeasurementsStructure(experiment);
                useEnteredValuesAsBlanks = 0;
                if this.formulaIsSet
                    for calculationStep = 1 : numel(this.formulae)
                       acronyme = this.formulae{calculationStep}.acronyme;
                       functionName = listOfFormulae.findFunctionByAcronyme(acronyme);
                       resultStructure = cell(numel(this.groups), 1);
                       if strcmp(acronyme, 'Blank correct')
                           for group = 1 : numel(this.groups)
                               for subgroup = numel(this.groups{group}): -1 : this.subgroupStartValue
                                  for well = 1 : numel(this.groups{group}{subgroup})
                                      insertionStructure = cell(0,0);
                                      for channel = numel(this.channelNames):-1:1
                                         clear blankValues;
                                         valuesToBeBlanked = this.measurementStructure{group}{subgroup}{well}{channel};
                                         for blankWell = 1 : numel(this.measurementStructure{group}{1})
                                            blankValues(blankWell, :) = this.measurementStructure{group}{1}{blankWell}{channel};
                                         end
                                         
                                         %% important
                                            % in cases when blank is not
                                            % measured at the exact same
                                            % time moment it is not
                                            % possible to do absolutely
                                            % correct blank correction. but
                                            % there are several
                                            % possibilities for
                                            % approximations
                                            % here we approximate that the
                                            % closest measured value is the
                                            % estimate for the blank value
                                         %%
                                         
                                         if exist('blankValues', 'var')
                                            someBlankValueExists = ~isempty(find(isnan(blankValues)==0, 1));
                                            someNanValueExists = ~isempty(find(isnan(blankValues)==1, 1));
                                            if someNanValueExists && someBlankValueExists
                                               newBlankValues = blankValues;
                                               for row = 1 : size(blankValues, 1)
                                                  nonNanIndices = find(~isnan(blankValues(row, :)) == 1);
                                                  for col = 1 : size(blankValues, 2)                                              
                                                     if isnan(blankValues(row, col))
                                                         differenceIndex = abs(col - nonNanIndices);
                                                         [unneeded, bestIndex] = min(differenceIndex);
                                                         newBlankValues(row, col) = blankValues(row, nonNanIndices(bestIndex));
                                                     end
                                                  end
                                               end
                                               blankValues = newBlankValues;
                                            end
                                            
                                            
                                            formula = [functionName, '(valuesToBeBlanked, blankValues)'];
                                            %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                            insertionStructure = [eval(formula),insertionStructure];
                                            %this.measurementStructure{group}{subgroup}{well} = [eval(formula), this.measurementStructure{group}{subgroup}{well}];
                                         elseif isequal(useEnteredValuesAsBlanks, 1)
                                             blankValues = zeros(size(valuesToBeBlanked)) * externalBlankArray(channel);
                                             formula = [functionName, '(valuesToBeBlanked, blankValues)'];
                                             %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                             insertionStructure = [eval(formula),insertionStructure];
                                             
                                         else
                                             answer = questdlg('One of the groups had no blank value. Would you like to enter a value which should be used to blank these groups (external blank)?', 'Blanking question', 'Yes', 'No', 'Yes');
                                             switch answer
                                                
                                                 case 'Yes'
                                                    useEnteredValuesAsBlanks = 1;
                                                    externalBlankArray = zeros(1, numel(this.channelNames));
                                                    for channelIndex = numel(this.channelNames): -1 :1
                                                         result = inputdlg(['Enter external blank value for ', this.channelNames{channelIndex}]);
                                                         externalBlankArray(channelIndex) = str2double(result{1});
                                                    end
                                                    
                                                    blankValues = zeros(size(valuesToBeBlanked)) * externalBlankArray(channel);
                                                    formula = [functionName, '(valuesToBeBlanked, blankValues)'];
                                                    %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                                    insertionStructure = [eval(formula),insertionStructure];
                                             
                                                 case 'No'
                                                    warndlg('One of the groups had no blank value. Cannot perform blank correction!')
                                                    error('One of the groups had no blank value. Cannot perform blank correction!')
                                             end
                                         end
                                      end
                                      this.measurementStructure{group}{subgroup}{well} = [insertionStructure, this.measurementStructure{group}{subgroup}{well}];
                                  end
                               end
                           end 
                           %this.measurementStructure = resultStructure;
                       elseif strcmp(acronyme, 'Blank normalize')
                           resultStructure = cell(numel(this.groups), 1);
                           warningDisplayed = 0;
                           for group = 1 : numel(this.groups)
                               for subgroup = this.subgroupStartValue : numel(this.groups{group})
                                  for well = 1 : numel(this.groups{group}{subgroup})
                                      
                                      for channel = numel(this.channelNames):-1:1
                                         blankValues = [];
                                         if ~isempty(this.measurementStructure{group}{1})
                                             valuesToBeBlanked = this.measurementStructure{group}{subgroup}{well}{channel};
                                             for blankWell = 1 : numel(this.measurementStructure{group}{1})
                                                blankValues(blankWell, :) = this.measurementStructure{group}{1}{blankWell}{channel};
                                             end
                                             if exist('blankValues', 'var')
                                                formula = [functionName, '(valuesToBeBlanked, blankValues)'];
                                                %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                                this.measurementStructure{group}{subgroup}{well} = [eval(formula), this.measurementStructure{group}{subgroup}{well}];
                                             else                                         
                                                 errordlg('One of the groups had no blank value. Cannot perform blank normalization!')
                                                 error('One of the groups had no blank value. Cannot perform blank normalization!')
                                             end
                                         else
                                             if ~warningDisplayed
                                                warndlg('At least one of the groups did not have a blank well set, calculation was not performed for this group');
                                             end
                                             warningDisplayed = 1;
                                         end

                                      end
                                  end
                               end        
                           end 
                           %this.measurementStructure = resultStructure;

                      elseif strcmp(acronyme, 'Timewise blank normalize')
                           resultStructure = cell(numel(this.groups), 1); 
                           warningDisplayed = 0;
                           for group = 1 : numel(this.groups)
                               for subgroup = this.subgroupStartValue : numel(this.groups{group})
                                  if ~isempty(this.measurementStructure{group}{subgroup})
                                      for well = 1 : numel(this.groups{group}{subgroup})
                                          insertionStructure = cell(0,0);
                                          for channel = numel(this.channelNames):-1:1
                                             blankValues = [];

                                             valuesToBeBlanked = this.measurementStructure{group}{subgroup}{well}{channel};
                                             blankValues =  valuesToBeBlanked(this.timewiseBlankStructure{group}{subgroup}(well, :));
                                             if exist('blankValues', 'var')
                                                formula = [functionName, '(valuesToBeBlanked, blankValues)'];
                                                %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                                insertionStructure = [eval(formula), insertionStructure];
                                                %this.measurementStructure{group}{subgroup}{well} = [eval(formula), this.measurementStructure{group}{subgroup}{well}]; 
                                             else                                         
                                                 errordlg('One of the wells had no blank value. Cannot perform timewise blank normalization!')
                                                 error('One of the wells had no blank value. Cannot perform timewise blank normalization!')
                                             end                                   
                                          end
                                          this.measurementStructure{group}{subgroup}{well} = [insertionStructure, this.measurementStructure{group}{subgroup}{well}];
                                      end                                    
                                  else
                                      ['No measurements in subgoup ', subgroup];
                                  end
                               end        
                           end 
                           %this.measurementStructure = resultStructure;

                       elseif strcmp(acronyme, 'FA') || strcmp(acronyme, 'TFI')

                           blankHasBeenCalculated = 0;
                           for formulaIndex = 1 : calculationStep
                              if strcmp(this.formulae{formulaIndex}.acronyme, 'Blank correct')
                                  blankHasBeenCalculated = 1;
                              end
                           end

                           if isequal(blankHasBeenCalculated, 1)
                               blankedChannelNames = GetFunctionOutputArguments(experiment.getChannelNames(), 'Blank correct');
                               parallelIndex = find(strcmp(this.channelNames, blankedChannelNames{1}) == 1);
                               perpIndex = find(strcmp(this.channelNames, blankedChannelNames{2}) == 1);
                           end



                           resultStructure = cell(numel(this.groups), 1);                     
                           for group = 1 : numel(this.groups)
                               resultStructure{group} = cell(numel(this.groups{group}), 1);
                               for subgroup = this.subgroupStartValue : numel(this.groups{group})
                                  resultStructure{group}{subgroup} = cell(numel(this.groups{group}{subgroup}), 1); 
                                  for well = 1 : numel(this.groups{group}{subgroup}) 
                                     if isequal(blankHasBeenCalculated, 0)
                                        parallelIntensity = this.measurementStructure{group}{subgroup}{well}{end-1}; % ignore warning, it is used in eval
                                        perpendicularIntensity = this.measurementStructure{group}{subgroup}{well}{end}; % ignore warning, it is used in eval
                                     else
                                        parallelIntensity = this.measurementStructure{group}{subgroup}{well}{parallelIndex}; % ignore warning, it is used in eval
                                        perpendicularIntensity = this.measurementStructure{group}{subgroup}{well}{perpIndex}; % ignore warning, it is used in eval
                                     end
                                     formula = [functionName, '(parallelIntensity, perpendicularIntensity)'];
                                     %this.measurementStructure{group}{subgroup}{well}{end+1} = eval(formula);
                                     this.measurementStructure{group}{subgroup}{well} = [eval(formula), this.measurementStructure{group}{subgroup}{well}]; 
                                  end
                              end
                           end                           
                           %this.channelNames = GetFunctionOutputArguments(this.channelNames, acronyme);
                       elseif strcmp(acronyme, 'Timewise blank correction')
                           resultStructure = cell(numel(this.groups), 1); 
                           warningDisplayed = 0;
                           for group = 1 : numel(this.groups)
                               for subgroup = this.subgroupStartValue : numel(this.groups{group})
                                  if ~isempty(this.measurementStructure{group}{subgroup})
                                      for well = 1 : numel(this.groups{group}{subgroup})
                                          for channel = numel(this.channelNames):-1:1
                                             blankValues = [];

                                             valuesToBeBlanked = this.measurementStructure{group}{subgroup}{well}{channel};
                                             blankValues =  valuesToBeBlanked(this.timewiseBlankStructure{group}{subgroup}(well, :));
                                             if exist('blankValues', 'var')
                                                formula = [functionName, '(valuesToBeBlanked, blankValues)'];
                                                %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                                this.measurementStructure{group}{subgroup}{well} = [eval(formula), this.measurementStructure{group}{subgroup}{well}]; 
                                             else                                         
                                                 errordlg('One of the wells had no blank value. Cannot perform timewise blank correction!')
                                                 error('One of the wells had no blank value. Cannot perform timewise blank correction!')
                                             end                                   
                                          end
                                      end
                                  else
                                      ['No measurements in subgoup ', subgroup];
                                  end
                               end        
                           end 
                           %this.measurementStructure = resultStructure;
                       elseif strcmp(acronyme, 'Linear time model blank correction')
                           resultStructure = cell(numel(this.groups), 1); 
                           warningDisplayed = 0;
                           for group = 1 : numel(this.groups)
                               for subgroup = this.subgroupStartValue : numel(this.groups{group})
                                  if ~isempty(this.measurementStructure{group}{subgroup})
                                      for well = 1 : numel(this.groups{group}{subgroup})
                                          insertionStructure = cell(0,0);
                                          for channel = numel(this.channelNames):-1:1
                                             blankValues = [];
                                             valuesToBeBlanked = this.measurementStructure{group}{subgroup}{well}{channel};
                                             valuesToBeBlankedTimes = this.apareciumExperimentInput.getCycleTimeMomentsOfWell(this.groups{group}{subgroup}{well});
                                                                                           
                                             for blankWell = 1 : numel(this.measurementStructure{group}{1})
                                                blankValues(blankWell, :) = this.measurementStructure{group}{1}{blankWell}{channel};
                                             end
                                             % find the time for each blank
                                             % measurement to serve as the
                                             % X variable of linear
                                             % regression model
                                             blankTimes = [];
                                             
                                             for blankWell = 1 : numel(this.measurementStructure{group}{1})
                                                 blankTimes(blankWell, :) = this.apareciumExperimentInput.getCycleTimeMomentsOfWell(this.groups{group}{1}{blankWell});
                                             end
                                                 
                                             if exist('blankValues', 'var')
                                                formula = [functionName, '(valuesToBeBlanked, valuesToBeBlankedTimes, blankValues, blankTimes)'];
                                                %resultStructure{group}{subgroup}{well}{channel} = eval(formula);
                                                insertionStructure = [eval(formula),insertionStructure];
                                                
                                             else                                         
                                                 errordlg('One of the wells had no blank value. Cannot perform timewise blank correction!')
                                                 error('One of the wells had no blank value. Cannot perform timewise blank correction!')
                                             end            
                                          end
                                          this.measurementStructure{group}{subgroup}{well} = [insertionStructure, this.measurementStructure{group}{subgroup}{well}];
                                      end
                                  else
                                      ['No measurements in subgoup ', subgroup];
                                  end
                               end        
                           end 
                       else
                           [usedChannels, usedChannelNames] = this.findUsedChannels(calculationStep);
                           %replace spaces since spaces will break inline and
                           %eval
                           this.formulae{calculationStep}.formula = regexprep(this.formulae{calculationStep}.formula,' ','_');
                           usedChannelNames = regexprep(usedChannelNames, ' ', '_');
                           f = inline(this.formulae{calculationStep}.formula, usedChannelNames{:});
                           resultStructure = cell(numel(this.groups), 1); 
                           for group = 1 : numel(this.groups)
                               resultStructure{group} = cell(numel(this.groups{group}), 1);
                               for subgroup = this.subgroupStartValue : numel(this.groups{group})
                                  resultStructure{group}{subgroup} = cell(numel(this.groups{group}{subgroup}), 1); 
                                  for well = 1 : numel(this.groups{group}{subgroup})
                                     inlineInput = cell(length(usedChannels),1);
                                     for channel = 1 : length(usedChannels)
                                         try
                                            inlineInput{channel} = this.measurementStructure{group}{subgroup}{well}{usedChannels(channel)};
                                         catch MException
                                             'siin'
                                         end
                                     end
                                     try
                                        this.measurementStructure{group}{subgroup}{well} = [f(inlineInput{:}), this.measurementStructure{group}{subgroup}{well}]; 
                                        %resultStructure{group}{subgroup}{well}{1} = f(inlineInput{:});
                                     catch
                                         'Error in calculation';
                                     end
                                  end
                              end
                           end
                           %this.measurementStructure = resultStructure;
                           %this.channelNames = GetFunctionOutputArguments(this.channelNames, acronyme);
                       end  
                       this.channelNames = [GetFunctionOutputArguments(this.channelNames, acronyme), this.channelNames];
                    end

                else
                    warndlg('No formula chosen, calculations have not been performed, please enter a valid formula using the calculation formula panel');
                end
                result = this.measurementStructure;
                groups = this.groups;
            end
        end
        
        function groupWells(this, experiment, groupingStructure, sharedBlankStructure, timewiseBlankStructure)
            wells = reshape(experiment.getWells, numel(groupingStructure(:,:,1)), 1);
            groupingStructure2 = reshape(groupingStructure, numel(groupingStructure(:,:,1)), 2);
            reshapedsharedBlankStructure = reshape(sharedBlankStructure, numel(sharedBlankStructure(:, :, 1)), size(sharedBlankStructure, 3));
            reshapedTimewiseBlankStructure = reshape(timewiseBlankStructure, numel(timewiseBlankStructure(:, :, 1)), size(timewiseBlankStructure, 3));
            groupsInUse = unique(groupingStructure2(:,1));
            
            % group 0 is for unused wells so remove that one
            groupsInUse(groupsInUse == 0) = [];
            this.groups = [];
            % add the ordinary wells
            for group = groupsInUse'
               wellsInGroup = find(groupingStructure2(:,1) == group);
               subgroupsInUse = unique(groupingStructure2(wellsInGroup,2));
               wellNamesInGroup = wells(wellsInGroup);
               for subgroup = subgroupsInUse'                  
                   this.groups{group}{subgroup + 1} = wellNamesInGroup(groupingStructure2(wellsInGroup, 2) == subgroup);
                   this.timewiseBlankStructure{group}{subgroup + 1} = logical(reshapedTimewiseBlankStructure(wellsInGroup(groupingStructure2(wellsInGroup, 2) == subgroup), :));
               end
            end
            
            for group = groupsInUse'
                sharedBlankWells = wells(reshapedsharedBlankStructure(:, group) == 1);
                this.groups{group}{1} = [this.groups{group}{1}; sharedBlankWells];
            end
            % add the shared blanks
        end
        
        function [usedChannels, usedChannelNames] = findUsedChannels(this, formulaIndex)
            calculationCharacters = {'+', '-', '/', '*', '(', ')', '.'};
            usedChannels=[];
            for channel = 1 : numel(this.channelNames)
                if ~isequal(this.channelNames{channel}, [])
                    this.channelNames{channel} = regexprep(this.channelNames{channel}, '�', 'o');
                    this.formulae{formulaIndex}.formula = regexprep(this.formulae{formulaIndex}.formula, '�', 'o');

                    this.channelNames{channel} = regexprep(this.channelNames{channel}, '�', 'u');
                    this.formulae{formulaIndex}.formula = regexprep(this.formulae{formulaIndex}.formula, '�', 'u');

                    this.channelNames{channel} = regexprep(this.channelNames{channel}, '�', 'a');
                    this.formulae{formulaIndex}.formula = regexprep(this.formulae{formulaIndex}.formula, '�', 'a');

                    this.channelNames{channel} = regexprep(this.channelNames{channel}, '�', 'o');
                    this.formulae{formulaIndex}.formula = regexprep(this.formulae{formulaIndex}.formula, '�', 'o');

                    channelNames = regexprep(this.channelNames{channel}, ' ', '_');
                    formula = regexprep(this.formulae{formulaIndex}.formula, ' ', '_');
                
                    if strfind(formula, channelNames)>0
                        allow = 1;
                        findIndex = strfind(formula, channelNames);
                        endIndex = findIndex + numel(channelNames)-1;
                        for presenceIndex = 1 : numel(findIndex)
                            if (isequal(findIndex(presenceIndex), 1) || ~isempty(cell2mat(strfind(calculationCharacters, formula(findIndex(presenceIndex) - 1))))) && (endIndex(presenceIndex) >= numel(formula) || ~isempty(cell2mat(strfind(calculationCharacters, formula(endIndex(presenceIndex) + 1)))))

                            else
                                allow = 0;
                               break; 
                            end
                        end
                        if allow
                            usedChannels(end+1) = channel;
                        end
                    end
                end
            end
            % generate a new cell array of channels used
            usedChannelNames = cell(length(usedChannels),1);
            for channel = 1:length(usedChannels)
                usedChannelNames{channel} = this.channelNames{usedChannels(channel)};              
            end 
            
        end
        
        function generateMeasurementsStructure(this, experiment)
            this.measurementStructure = [];
            for group = 1 : numel(this.groups)
                for subgroup = 1 : numel(this.groups{group}) % NB this must start from 1 and not from this.subgroupStartValue since otherwise blanks are not correctly calculated
                    for well = 1 : numel(this.groups{group}{subgroup})
                        for channel = 1 : experiment.getNumberOfChannels
                            this.measurementStructure{group}{subgroup}{well}{channel} = experiment.getMeasurementsOfWell(this.groups{group}{subgroup}{well}, channel);
                        end
                    end
                end
            end
        end
    end   
end