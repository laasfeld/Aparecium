classdef volumeLinearEquationsSolver < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        
    end
    
    methods(Static)
        function volumes = calculateVolumes(unneeded1, unneeded2, pipetingSimulatorInterface)
            disp('playing')
            equations = cell(pipetingSimulatorInterface.PipetingSimulator.getLinearEquations());
            groupedEquations = pipetingSimulatorInterface.PipetingSimulator.getGroupedEquations();
            
            variablesToSolveFor = [cell(pipetingSimulatorInterface.PipetingSimulator.getVolumesToSolveFor()), cell(pipetingSimulatorInterface.PipetingSimulator.getVolumesToSolveFor())];
            
            concentrationsToSolveFor = [unique(cell(pipetingSimulatorInterface.PipetingSimulator.getConcentrationToSolveFor())), unique(cell(pipetingSimulatorInterface.PipetingSimulator.getConcentrationToSolveFor()))];
            variablesToSolveFor = [variablesToSolveFor;concentrationsToSolveFor];
            knownValues = cell(pipetingSimulatorInterface.PipetingSimulator.getKnownValueEquations());
            variablesToSolveFor = volumeLinearEquationsSolver.groupedSolve(groupedEquations, variablesToSolveFor, knownValues);
%             [eq2, variablesToSolve] = volumeLinearEquationsSolver.singleSolve(equations, variablesToSolveFor);
%             while~(isequal(eq2, equations) && isequal(variablesToSolveFor, variablesToSolve))
%                 variablesToSolveFor = variablesToSolve;
%                 equations = eq2;
%                 [eq2, variablesToSolve] = volumeLinearEquationsSolver.singleSolve(equations, variablesToSolveFor);       
%             end
%             equations2 = equations;
%             finalWellMoleEquations = cell(pipetingSimulatorInterface.PipetingSimulator.getFinalWellMoleLinearEquations());
%             nonFinalWellMoleEquations = cell(pipetingSimulatorInterface.PipetingSimulator.getNonFinalWellMoleLinearEquations());
%             finalWellVolumeEquations = cell(pipetingSimulatorInterface.PipetingSimulator.getFinalWellVolumeLinearEquations());
%             nonFinalWellVolumeEquations = cell(pipetingSimulatorInterface.PipetingSimulator.getNonFinalWellVolumeLinearEquations());
%             special = cell(pipetingSimulatorInterface.PipetingSimulator.getSpecialLinearEquations());
%              
%             %equations = volumeLinearEquationsSolver.deleteRedundancy(equations);
%             index = 0;
%             while index < numel(equations)
%                index = index + 1;
%                if isempty(regexp(equations{index}, '=\d', 'once'))
%                    try
%                        variable = equations{index}(1:strfind(equations{index}, ' =')-1);
%                        solution = num2str(double(solve(vpa(equations{index}), variable)));
%                        %equations(index) = [];
%                        %index = index - 1;
%                        for index2 = 1 : numel(equations)
%                            equations{index2} = regexprep(equations{index2}, [' ', variable, ' '], solution);
%                            equations{index2} = regexprep(equations{index2}, [variable, ' ='], [solution, ' =']);
%                        end
%                        
%                        for index2 = 1 : numel(finalWellMoleEquations)
%                            finalWellMoleEquations{index2} = regexprep(finalWellMoleEquations{index2}, [' ', variable, ' '], solution);
%                        end
%                        
%                        for index2 = 1 : numel(nonFinalWellMoleEquations)
%                            nonFinalWellMoleEquations{index2} = regexprep(nonFinalWellMoleEquations{index2}, [' ', variable, ' '], solution);
%                        end
%                        
%                        for index2 = 1 : size(variablesToSolveFor, 1)
%                            variablesToSolveFor{index2, 2} = regexprep(variablesToSolveFor{index2, 2}, variable, solution);
%                        end
%                        
%                        for index2 = 1 : numel(nonFinalWellVolumeEquations)
%                            nonFinalWellVolumeEquations{index2} = regexprep(nonFinalWellVolumeEquations{index2}, [' ', variable, ' '], solution);
%                        end
%                        
%                        for index2 = 1 : numel(finalWellVolumeEquations)
%                            finalWellVolumeEquations{index2} = regexprep(finalWellVolumeEquations{index2}, [' ', variable, ' '], solution);
%                        end
%                        
%                        for index2 = 1 : size(variablesToSolveFor, 1)
%                            if(strcmp(variablesToSolveFor{index2, 1}, variable))
%                               variablesToSolveFor{index2, 2} = solution;
%                            end
%                        end
%                        
%                        for index2 = 1 : numel(special)
%                            special{index2} = regexprep(special{index2}, [' ', variable, ' '], solution);
%                            special{index2} = regexprep(special{index2}, [variable, ' ='], [solution, ' =']);
%                        end                       
%                        
%                     catch
%                        
%                     end
%                 end
%             end
%             
%             numberOfEquations = pipetingSimulatorInterface.experiment.getNumberOfTreatments() - 1;
%             % after first replacements, final (measurement) well mole
%             % equations should be solvable for each well
%             
%             
%             counter = 0;
%             solutions = cell(1, numel(1 : numberOfEquations : numel(finalWellMoleEquations)/numberOfEquations));
%             for index = 1 : numel(finalWellVolumeEquations)
%                counter = counter + 1;
%                neededEquations = [finalWellMoleEquations((index - 1)*numberOfEquations + 1 : index * numberOfEquations); finalWellVolumeEquations(index)]; 
%                solutions{counter} = solve(neededEquations{:});
%             end
% 
%             for index = 1 : numel(solutions)
%                 if ~isempty(solutions{index})
%                     variables = fields(solutions{index});
%                     for variableIndex = 1 : numel(variables)
%                         variable = variables{variableIndex};
%                         value = char(solutions{index}.(variables{variableIndex}));
%                         for index2 = 1 : numel(equations)
%                             equations{index2} = regexprep(equations{index2}, [' ', variables{variableIndex}, ' '], value);
%                             equations{index2} = regexprep(equations{index2}, [variable, ' ='], [value, ' =']);
%                         end
% 
%                         for index2 = 1 : numel(finalWellMoleEquations)
%                            finalWellMoleEquations{index2} = regexprep(finalWellMoleEquations{index2}, [' ', variables{variableIndex}, ' '], value);
%                         end
% 
%                         for index2 = 1 : numel(nonFinalWellMoleEquations)
%                            nonFinalWellMoleEquations{index2} = regexprep(nonFinalWellMoleEquations{index2}, [' ', variables{variableIndex}, ' '], value);
%                         end
% 
%                         for index2 = 1 : numel(nonFinalWellVolumeEquations)
%                            nonFinalWellVolumeEquations{index2} = regexprep(nonFinalWellVolumeEquations{index2}, [' ', variable, ' '], value);
%                         end
% 
%                         for index2 = 1 : numel(finalWellVolumeEquations)
%                            finalWellVolumeEquations{index2} = regexprep(finalWellVolumeEquations{index2}, [' ', variable, ' '], value);
%                         end
% 
%                         for index2 = 1 : size(variablesToSolveFor, 1)
%                             if(strcmp(variablesToSolveFor{index2, 1}, variable))
%                                 variablesToSolveFor{index2, 2} = value;
%                             end
%                         end
% 
%                         for index2 = 1 : numel(special)
%                             special{index2} = regexprep(special{index2}, [' ', variable, ' '], value);
%                             special{index2} = regexprep(special{index2}, [variable, ' ='], [value, ' =']);
%                         end                    
% 
% 
%                     end
%                 end
%             end
% 
% 
%             for index = 1 : numel(equations)
%                try
%                     value = char(solve(equations{index}));
%                     for index2 = 1 : numel(variablesToSolveFor)
%                         if(strfind(equations{index}, variablesToSolveFor{index2, 1}))
%                             variable = variablesToSolveFor{index2, 1};
%                         end
%                     end
%                     for index2 = 1 : numel(equations)
%                         equations{index2} = regexprep(equations{index2}, [' ', variable, ' '], value);
%                         equations{index2} = regexprep(equations{index2}, [variable, ' ='], [value, ' =']);
%                     end
% 
%                     for index2 = 1 : numel(finalWellMoleEquations)
%                        finalWellMoleEquations{index2} = regexprep(finalWellMoleEquations{index2}, [' ', variable, ' '], value);
%                     end
% 
%                     for index2 = 1 : numel(nonFinalWellMoleEquations)
%                        nonFinalWellMoleEquations{index2} = regexprep(nonFinalWellMoleEquations{index2}, [' ', variable, ' '], value);
%                     end
% 
%                     for index2 = 1 : size(variablesToSolveFor, 1)
%                         variablesToSolveFor{index2, 2} = regexprep(variablesToSolveFor{index2, 2}, variable, value);
%                     end
%                     
%                     for index2 = 1 : numel(special)
%                         special{index2} = regexprep(special{index2}, [' ', variable, ' '], value);
%                     end  
%                 catch
% 
%                 end
%             end
%            
%             for index = numel(nonFinalWellMoleEquations) : - 1 : 1
%                 try
%                     solve(nonFinalWellMoleEquations{index});
%                 catch exception
%                     if strcmp(exception.identifier, 'symbolic:mupadengine:feval:FevalError')
%                        nonFinalWellMoleEquations(index) = [];
%                     end
%                 end
%             end
%             
%             neededEquations = [nonFinalWellVolumeEquations; special];
% %             
% %             
% %             % check for equations that can´t be solved
%             for equationIndex = numel(equations) : -1 : 1
%                try
%                    sol = solve(equations{equationIndex});
%                    if isempty(sol)
%                        equations(equationIndex) = [];
%                    end
%                catch MException
%                    if strcmp(MException.identifier, 'symbolic:mupadengine:feval:FevalError') || strcmp(MException.identifier, 'symbolic:solve:NoVariableGiven')
%                        equations(equationIndex) = [];
%                    end
%                end
%             end
% %             
%             % check if equations are basically the same, remove
%             % replications of the same equation
%             
% % in this version this exact approach causes problems since if some
% % equations are directly solved to a value and the values are shared then
% % some of the equations are lost which are not the same
%             simplified = cell(size(equations));
%             for equationIndex = 1 : numel(equations)
%                 eq = char(simplify(solve(equations{equationIndex})));
%                 % check if answer is numeric
%                 if isempty(str2num(eq))
%                     simplified{equationIndex} = eq;
%                 else
%                     simplified{equationIndex} = ['DirectlySolvable', num2str(equationIndex)];
%                 end
%             end
%             [unneeded, indices] = unique(simplified); 
%             equations = equations(indices);
            
    
            
%             matlabVersion = version;
%             generalVersion = str2num(matlabVersion(1));
%             if generalVersion > 8
%                 for i = 1 : numel(equations)
%                     equationsVpa{i} = vpa(equations{i});
%                 end
%                 solutions = vpasolve(equationsVpa{:});
%                 variables = fields(solutions);
%                 for variableIndex = 1 : numel(variables)
%                     variable = variables{variableIndex};
%                     value = char(solutions.(variable));
% 
%                     for index2 = 1 : size(variablesToSolveFor, 1)
%                         if(strcmp(variablesToSolveFor{index2, 1}, variable))
%                             variablesToSolveFor{index2, 2} = value;
%                         end
%                     end                
%                 end
%             else
%                 %solutions = solve(equations{:});
%                 variablesToSolveFor = volumeLinearEquationsSolver.alternativeSolve(equations, variablesToSolve);
%             end
%             
% 
%             variablesToSolveFor2 = volumeLinearEquationsSolver.alternativeSolve(equations, variablesToSolve);
            results = cell(0, numel(variablesToSolveFor));
            for index = 1 : size(variablesToSolveFor, 1)
                results{index} = roundsd(str2double(variablesToSolveFor{index, 2}), 4);
            end
            resultsAsMatrix = cell2mat(results);
            pipetingSimulatorInterface.PipetingSimulator.setCalculatedVolumes(resultsAsMatrix);
        end
        
        function equations = deleteRedundancy(equations)
            for index = 1 : numel(equations)
                equations(index) = regexprep(equations(index), '+1\*', '+');
                equations(index) = regexprep(equations(index), '-1\*', '+');
                equations(index) = regexprep(equations(index), '+0', '');
                equations(index) = regexprep(equations(index), '-0+', '+');
                equations(index) = regexprep(equations(index), '\(0\)', '0');
                equations(index) = regexprep(equations(index), '(0\+', '\(');
                equations(index) = regexprep(equations(index), '-\)', '\)');
                equations(index) = regexprep(equations(index), '\(\)', '');
                equations(index) = regexprep(equations(index), '\(\+', '(');
                equations(index) = regexprep(equations(index), '-0)', ')');
                equations(index) = regexprep(equations(index), '+)', ')');
            end
        end
        
        function [variablesToSolveFor] = alternativeSolve(equations, variablesToSolveFor)
            newEq = cell(numel(equations), 1); 
            for i = 1 : numel(equations)
                index = strfind(equations{i},'=');
                newEq{i} = [equations{i}(1:index-1),'-(',equations{i}(index+1:end), ')'];
            end
            
            indexCounter = 1;
            remapper = [];
            for i = 1 : size(variablesToSolveFor, 1)
               if isempty(str2num(variablesToSolveFor{i, 2}))
                  for equationIndex = 1 : numel(equations)
                      newEq = regexprep(newEq,[' ', variablesToSolveFor{i, 1},' '], [' x(',num2str(indexCounter), ') ']);
                      newEq = regexprep(newEq,[variablesToSolveFor{i, 1},' '], [' x(',num2str(indexCounter), ') ']);
                     
                  end
                  remapper(indexCounter) = i;
                  indexCounter = indexCounter + 1;
               end
            end
            
            functionString = ['@(x) [abs(', newEq{1},')'];
            for i = 2 : numel(newEq)
                functionString = [functionString, ',abs(', newEq{i},')'];
            end
            functionString = [functionString, ']'];
            functionHandle = str2func(functionString);
            try
                options = optimset('Display','iter','TolFun',1e-16,'MaxFunEvals',100000,'MaxIter',8000, 'TolX', 1e-5);
            catch MException
                options = optimoptions('fsolve','Display','iter','TolFun', 1e-16,'MaxFunctionEvaluations',100000,'MaxIterations',8000);
            end
                solution = fsolve(functionHandle, ones(numel(remapper),1), options);
            for parameter = 1 : numel(solution)
                variablesToSolveFor{remapper(parameter), 2} = num2str(solution(parameter)); 
            end
        end
        
        function variablesToSolveFor = groupedSolve(equations, variablesToSolveFor, knownValues)
            equations = cell(equations);
            
            variables = cell(numel(knownValues), 1);
            values = cell(numel(knownValues), 1);
            for variableIndex = 1 : numel(knownValues)
                variables{variableIndex} = symvar(knownValues{variableIndex});
                values{variableIndex} = num2str(double(solve(knownValues{variableIndex})));
            end
            
            for equationGroupIndex = 1 : numel(equations)
                   allVariables = cell(0,0);
                   for equationIndex = numel(equations{equationGroupIndex}) : -1 : 1
                        for variableIndex = 1 : numel(knownValues)
                            variable = variables{variableIndex};
                            value = values{variableIndex};
                            equations{equationGroupIndex}{equationIndex} = regexprep(equations{equationGroupIndex}{equationIndex}, variable, value);
                        end
                   end
            end
            clear variables values
            'siin'
            
            for variableIndex = 1 : numel(knownValues)
                variable = symvar(knownValues{variableIndex});
                for unknownVariableIndex = 1 : size(variablesToSolveFor, 1)
                    if strcmp(variablesToSolveFor{unknownVariableIndex, 1}, variable)
                        variablesToSolveFor{unknownVariableIndex, 2} = num2str(double(solve(knownValues{variableIndex})));
                    end
                end
            end

            while(1)
                for equationGroupIndex = 1 : numel(equations)

                   allVariables = cell(0,0);
                   for equationIndex = numel(equations{equationGroupIndex}) : -1 : 1
                       try
                            solve(equations{equationGroupIndex}{equationIndex});
                       catch MException
                           if strcmp(MException.identifier, 'symbolic:mupadengine:feval:FevalError') || strcmp(MException.identifier, 'symbolic:solve:NoVariableGiven')
                               equations{equationGroupIndex}(equationIndex) = [];
                               continue;
                           end
                       end
                       allVariables = [allVariables; symvar(equations{equationGroupIndex}{equationIndex})];                  
                   end
                   numberOfVariables = numel(unique(allVariables));
                   if (numberOfVariables <= numel(equations{equationGroupIndex}) && numberOfVariables > 0)


                       solutions = solve(equations{equationGroupIndex}{:});

                       variables = fields(solutions);
                       if isequal(numel(solutions), 0)
                          continue; 
                       end
                       if isequal(numel(variables), 1) %% && isequal(numel(equations{equationGroupIndex}), 1)
                          variables = symvar(equations{equationGroupIndex}{1});
                          try
                            value = char(solutions.('s'));
                          catch MException
                             'here'
                          end
                          solutions = struct;
                          solutions.(variables{1}) = value;
                       end

                        try
                             for variableIndex = 1 : numel(variables)
                                variable = variables{variableIndex};
                                value = char(solutions.(variable));
                             end
                       catch MException
                       % probably one of the solutions is directly
                       % solvable 
                           solutions = solve(equations{equationGroupIndex}{1:end-1});

                           variables = fields(solutions);
                           MException

                       end
                       
                       
                       for variableIndex = 1 : numel(variables)

                                variable = variables{variableIndex};
                                try
                                    value = char(solutions.(variable));
                                catch
                                   'bla' 
                                end

                            for index2 = 1 : size(variablesToSolveFor, 1)
                                if(strcmp(variablesToSolveFor{index2, 1}, variable) && ~isempty(str2num(value)))
                                    variablesToSolveFor{index2, 2} = value;
                                end
                            end                
                       end
                       
                       for index2 = 1 : size(variablesToSolveFor, 1)
                           if ~isempty(str2num(variablesToSolveFor{index2, 2}))
                              for index3 = 1 : numel(equations)
                                  for index = 1 : numel(equations{index3})
                                     equations{index3}{index} = regexprep(equations{index3}{index}, [' ', variablesToSolveFor{index2, 1}, ' '], num2str(variablesToSolveFor{index2, 2}));
                                     equations{index3}{index} = regexprep(equations{index3}{index}, [variablesToSolveFor{index2, 1}, ' '], num2str(variablesToSolveFor{index2, 2}));
                                  end
                              end
                           end
                       end
                   end
                end
               canBreak = 1;
               for variableIndex = 1 : size(variablesToSolveFor, 1)
                   if isequal(variablesToSolveFor{variableIndex, 1}, variablesToSolveFor{variableIndex, 2})
                      canBreak = 0;
                      'cant break yet'
                      'missing value'
                      variablesToSolveFor{variableIndex, 1}
                      break;
                   end
               end
               
               if(canBreak)
                   break;
               end
               
            end
        end
        
        function [equations, variablesToSolveFor] = singleSolve(equations, variablesToSolveFor)
            warning('off','symbolic:sym:sym:DeprecateExpressions');
            index = 0;
            while index < numel(equations)
               index = index + 1;
               if isempty(regexp(equations{index}, '=\d', 'once'))
                   try
                       variable = equations{index}(1:strfind(equations{index}, ' =')-1);
                       solution = num2str(double(solve(vpa(sym(equations{index}), variable))));
                       %equations(index) = [];
                       %index = index - 1;
                       for index2 = 1 : numel(equations)
                           equations{index2} = regexprep(equations{index2}, [' ', variable, ' '], solution);
                           equations{index2} = regexprep(equations{index2}, [variable, ' ='], [solution, ' =']);
                       end 
                       
                       for index2 = 1 : size(variablesToSolveFor, 1)
                           if(strcmp(variablesToSolveFor{index2, 1}, variable))
                              variablesToSolveFor{index2, 2} = solution;
                           end
                       end
                    catch
                       
                    end
               end
            end
            
            %             % check for equations that can´t be solved
            for equationIndex = numel(equations) : -1 : 1
               try
                   sol = solve(vpa(sym(equations{equationIndex})));
                   if isempty(sol)
                       equations(equationIndex) = [];
                   end
               catch MException
                   if strcmp(MException.identifier, 'symbolic:mupadengine:feval:FevalError') || strcmp(MException.identifier, 'symbolic:solve:NoVariableGiven')
                       equations(equationIndex) = [];
                   end
               end
            end
            
                        simplified = cell(size(equations));
            for equationIndex = 1 : numel(equations)
                eq = char(simplify(solve(equations{equationIndex})));
                % check if answer is numeric
                if isempty(str2num(eq))
                    simplified{equationIndex} = eq;
                else
                    simplified{equationIndex} = ['DirectlySolvable', num2str(equationIndex)];
                end
            end
            [unneeded, indices] = unique(simplified); 
            equations = equations(indices);
            

            for equationIndex = numel(equations):-1:1
                try
                    eq = char(simplify(solve(sym(equations{equationIndex}))));
               catch MException
                   if strcmp(MException.identifier, 'symbolic:mupadengine:feval:FevalError') || strcmp(MException.identifier, 'symbolic:solve:NoVariableGiven')
                       equations(equationIndex) = [];
                       continue;
                   end
               end
                % check if answer is numeric
                if isempty(str2num(eq))
                    simplified{equationIndex} = eq;
                else
                    variable = '';
                    solution = solve(equations{equationIndex});
                    for index2 = 1 : size(variablesToSolveFor, 1)
                       tempVariable = variablesToSolveFor{index2, 1};
                       if ~isempty(strfind(equations{equationIndex}, [' ', tempVariable, ' ']))
                           variable = variablesToSolveFor{index2, 1};
                           break;
                       end
                    end
                    if strcmp(variable, '')
                        continue;
                    end
                    equations(equationIndex) = [];
                    for index2 = 1 : numel(equations)                        
                        equations{index2} = regexprep(equations{index2}, [' ', variable, ' '], char(solution));                        
                    end
                    
                   for index2 = 1 : size(variablesToSolveFor, 1)
                       if(strcmp(variablesToSolveFor{index2, 1}, variable))
                          variablesToSolveFor{index2, 2} = char(solution);
                       end
                   end
                end
            end
            
            for index2 = 1 : size(variablesToSolveFor, 1)
               if ~isempty(str2num(variablesToSolveFor{index2, 2}))
                  for index = 1 : numel(equations)
                     equations{index} = regexprep(equations{index}, [' ', variablesToSolveFor{index2, 1}, ' '], num2str(variablesToSolveFor{index2, 2}));
                     equations{index} = regexprep(equations{index}, [variablesToSolveFor{index2, 1}, ' '], num2str(variablesToSolveFor{index2, 2}));
                  end
               end
           end
           warning('on','symbolic:sym:sym:DeprecateExpressions'); 
        end
        
    end
end

