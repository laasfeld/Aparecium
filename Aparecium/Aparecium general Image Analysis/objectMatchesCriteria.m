function result = objectMatchesCriteria(singlePixelIdxList, eccentricity, functionHandle)
    try
        result = functionHandle(singlePixelIdxList, eccentricity);
    catch
        result = 0;
    end
    
end

