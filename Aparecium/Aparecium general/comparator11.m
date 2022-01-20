function result = comparator11(wellIDs, index1, index2)
    wellID1 = wellIDs{index1};
    wellID2 = wellIDs{index2};
    wellID1NumericalRowValue = indexInAlphabet(regexp(wellID1,'([A-Z]{1,2})', 'match', 'once'));  
    wellID1NumericalColumnValue = str2num(regexp(wellID1,'(\d{1,2})', 'match', 'once'));  
    
    wellID2NumericalRowValue = indexInAlphabet(regexp(wellID2,'([A-Z]{1,2})', 'match', 'once'));  
    wellID2NumericalColumnValue = str2num(regexp(wellID2,'(\d{1,2})', 'match', 'once'));  
    
    if wellID2NumericalColumnValue > wellID1NumericalColumnValue
        result = -1;
        return
    elseif wellID2NumericalColumnValue < wellID1NumericalColumnValue
        result = 1;
        return
    elseif isequal(wellID2NumericalColumnValue, wellID1NumericalColumnValue)
        if wellID2NumericalRowValue > wellID1NumericalRowValue
            result = -1;
            return
        elseif wellID2NumericalRowValue < wellID1NumericalRowValue
            result = 1;
            return
        elseif isequal(wellID1NumericalRowValue, wellID2NumericalRowValue)
            result = 0;
            return
        end
    end
end