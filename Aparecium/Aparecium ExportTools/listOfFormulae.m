classdef listOfFormulae < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
    end
    
    methods(Static)
        function nameAsString = findFunctionByAcronyme(acronyme)
            load listOfFunctionsStruct
            nameAsString = '';
            for formulaIndex = 1 : numel(formula)
                if strcmp(formula{formulaIndex}.acronyme, acronyme)
                    nameAsString = formula{formulaIndex}.functionName
                    break;
                end
            end
        end
        
        function builtInFormulaAcronyme = chooseBuiltInFormula()
            load listOfFunctionsStruct
            listString = cell(0, 0);
            for formulaIndex = 1 : numel(formula)
                listString{end+1} = formula{formulaIndex}.acronyme;
            end
            [Selection, ok] = listdlg('ListString' ,listString,'ListSize',[600 300],'SelectionMode','single','Name','Select builtin formula');
            builtInFormulaAcronyme = listString{Selection};
        end
    end
    
end

