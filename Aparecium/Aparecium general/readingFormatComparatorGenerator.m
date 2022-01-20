function comparator = readingFormatComparatorGenerator(wellID, comparatorIndex)
% This method generates a function
    switch comparatorIndex
        case 11
            comparator = @comparator11;
    end

end

