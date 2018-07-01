u = 0;
% upper = 66 (0.65) , lower = 38 (0.37) optimum
% size threshold optimum = 462
% edge Threshold addition optimum = 130 (total threshold = 321+130 = 451)
% for other images *1.75
res = zeros(1000, 2);
    for edgeThreshold = 1:1:400
        edgeThreshold
        in.upper = 0.65;
        in.lower = 0.37;
        in.threshold = 198;
        in.method = 'sobel';
        in.edgeThreshold = edgeThreshold;
        edges3 = ZStackBinary(in);
        resultant = zeros(904,1224);
        truePositives = 0;
        trueNegatives = 0;
        falsePositives = 0;
        falseNegatives = 0;
        for index = 1 : 904*1224
        if(manual3(index) == 1)
        if(edges3(index) == 1)
        truePositives = truePositives+1;
        else
        falseNegatives = falseNegatives+1;
        end
        else
        if(edges3(index) == 1)
        falsePositives = falsePositives+1;
        else
        trueNegatives = trueNegatives+1;
        end
        end
        end
        res(edgeThreshold,1) = sqrt(truePositives)*(truePositives/(truePositives+falsePositives))^7;
        res(edgeThreshold,2) = truePositives/(truePositives+falsePositives);
    end