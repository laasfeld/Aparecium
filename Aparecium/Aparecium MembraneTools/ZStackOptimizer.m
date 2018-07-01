classdef ZStackOptimizer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        slopes = [];
        manual3 = [];
        resulting = cell(0,0);
    end
    
    methods
        function this = ZStackOptimizer()
            
        end
        
        function res = optimize(this, x)
             in.upper = x(1);
             in.lower = x(2);
             in.threshold = x(3);
             in.method = 'sobel';
             in.edgeThreshold = x(4);
             in.smallSizeCutoff = x(5);
            truePositives = 0;
            trueNegatives = 0;
            falsePositives = 0;
            falseNegatives = 0;
            
            % ns means non-strict meaning that we can give a tiny bit more freedom.
            
            nsTruePositives = 0; 
            nsTrueNegatives = 0;
            nsFalsePositives = 0;
            nsFalseNegatives = 0; 

            for imageIndex = 1 : size(this.slopes, 3)
                in.slopes = this.slopes(:,:,imageIndex);
                %edges3 = logical(in.slopes);
                [edges3, probabilityImage] = ZStackBinary(in);
                manual3 = this.manual3(:,:,imageIndex);
                se = strel('disk',1);
                manual4 = imdilate(manual3, se);                              
                
                man3 = logical(manual3);
                localTruePositives = sum(sum(man3&edges3)); % True positives
                localFalseNegatives = sum(sum(logical(man3)&~edges3)); % False negatives
                %localTrueNegatives = sum(sum(~logical(man3)&~edges3));%
                %True negatives, currently not needed
                localFalsePositives = sum(sum(~logical(man3)&edges3)); % False positives
                
                truePositives = truePositives + localTruePositives;
                falsePositives = falsePositives + localFalsePositives;
                falseNegatives = falseNegatives + localFalseNegatives;
                
                probTruePositives = 0;
                probTrueNegatives = 0;
                probFalsePositives = 0;
                probFalseNegatives = 0;
                
%                 for index = 1 : numel(manual3)
%                     if(manual3(index) == 1)
%                         probTruePositives = probTruePositives + probabilityImage(index);
%                         probFalseNegatives = probFalseNegatives + 1 - probabilityImage(index);
%                     else
%                         probFalsePositives = probFalsePositives + probabilityImage(index);
%                         probTrueNegatives = probTrueNegatives + 1 - probabilityImage(index);
%                     end
%                 end
                
                nsprobTruePositives = 0;
                nsprobTrueNegatives = 0;
                nsprobFalsePositives = 0;
                nsprobFalseNegatives = 0;
                
%                 for index = 1 : numel(manual3)
%                     if(manual4(index) == 1)
%                         nsprobTruePositives = nsprobTruePositives + probabilityImage(index);
%                         nsprobFalseNegatives = nsprobFalseNegatives + 1 - probabilityImage(index);
%                     else
%                         nsprobFalsePositives = nsprobFalsePositives + probabilityImage(index);
%                         nsprobTrueNegatives = nsprobTrueNegatives + 1 - probabilityImage(index);
%                     end
%                 end
                
                for index = 1 : numel(manual3)
                    if(manual4(index) == 1)
                        if(edges3(index) == 1)
                            nsTruePositives = nsTruePositives+1;
                            
                        else
                            nsFalseNegatives = nsFalseNegatives+1;
                            
                        end
                    else
                        if(edges3(index) == 1)
                            nsFalsePositives = nsFalsePositives+1;

                        else
                            nsTrueNegatives = nsTrueNegatives+1;
                        end
                    end
                end
                
                disp(['per image correct percentage=', num2str(localTruePositives/(localTruePositives+localFalsePositives)), ' score is ', num2str(-(sqrt(localTruePositives/(localTruePositives+localFalseNegatives))*(localTruePositives/localFalsePositives)^2))]);
                disp(['per image correct found pixels percentage=', num2str(localTruePositives/(localTruePositives+localFalseNegatives))]);
                %disp(['per image correct probability percentage =', num2str(probTruePositives/(probTruePositives+probFalsePositives)), ' score is ', num2str(-(sqrt(probTruePositives/(probTruePositives+probFalseNegatives))*(probTruePositives/probFalsePositives)^2))]);
                %disp(['per image correct probability found pixels percentage=', num2str(probTruePositives/(probTruePositives+probFalseNegatives))]);
                %disp(['per image correct non-strict probability percentage =', num2str(nsprobTruePositives/(nsprobTruePositives+nsprobFalsePositives)), ' score is ', num2str(-(sqrt(nsprobTruePositives/(nsprobTruePositives+nsprobFalseNegatives))*(nsprobTruePositives/nsprobFalsePositives)^2))]);
                %disp(['per image correct non-strict probability found pixels percentage=', num2str(nsprobTruePositives/(nsprobTruePositives+nsprobFalseNegatives))]);
                disp('  ');
            end
            res = -(sqrt(truePositives/(truePositives+falseNegatives))*(truePositives/falsePositives)^2);
            if isnan(res)
                res = 0;
            end
            %disp(x)
            disp(truePositives/(truePositives+falsePositives));
            disp(['non-strict correct percentage=', num2str(nsTruePositives/(nsTruePositives+nsFalsePositives))]);
            disp('');
        end
        
        function res = optimizeCellX(this, x)
            config = CellXConfiguration.readXML('C:\Users\Kasutaja\Documents\slopeC01Parameters.xml');
            config.setSeedRadiusLimit([round(x(1)) round(x(2))]);
            config.setMembraneLocation(round(x(3)));
            config.setMembraneWidth(round(x(4)));
            config.setMaximumCellLength(round(x(5)));
            config.setMaximumMinorAxisLengthHoughRadiusRatio(x(6));
            config.setOverlapResolveThreshold(x(7));
            config.setSeedSensitivity(x(8));
            config.setIdPrecisionRate(x(9));
            config.requiredFractionOfAcceptedMembranePixels = x(10);
            config.intensityClassesCount = round(x(11));
            config.wiener2params = [x(12), x(13)];
            config.isHoughTransformOnCLAHE = round(x(14));
            config.maximumNumberOfCentroids = round(x(15));
            config.isGraphCutOnCLAHE = round(x(16));
            config.houghTransformGradientThreshold = x(17);
            config.seedMaskRadiusFraction = x(18);
            config.pixelBorderFractionOfMaxCellLength = x(19);
            config.maxFlowGridConnectivity = max([min([round(x(20))*4 + 4, 8]), 4]);
            config.isNonConvexRegionDetectionEnabled = round(x(21));
            config.minimumLengthOfLowEnergyMembraneRegion = round(x(22));
            config.maximumSmoothingDistance = round(x(23));
            config.maximumExpansionFraction = x(24);
            config.requiredFractionOfGoodRays = x(25);
            config.requiredCorrelationFraction = x(26);
            truePositives = 0;
            trueNegatives = 0;
            falsePositives = 0;
            falseNegatives = 0;
            
            nsTruePositives = 0; % ns means non-strict meaning that we can give a tiny bit more freedom.
            nsTrueNegatives = 0;
            nsFalsePositives = 0;
            nsFalseNegatives = 0; 
            
            for imageIndex = 1 : size(this.slopes, 3) - 1
                in.slopes = this.slopes(:,:,imageIndex);
                try
                    edges3 = cellXBinary(config, this.slopes(:,:,imageIndex));
                catch ME
                    if strcmp(ME.message, 'None of the labeled regions contains the seed centroid')
                        continue;
                    elseif strcmp(ME.message, 'Insufficient number of outputs from right hand side of equal sign to satisfy assignment.')
                        continue 
                    else
                        continue;
                    end
                end
                    
                this.resulting{end+1} = edges3;
                manual3 = this.manual3(:,:,imageIndex);
                se = strel('disk',1);
                manual4 = imdilate(manual3, se);
                localTruePositives = 0;
                localTrueNegatives = 0;
                localFalsePositives = 0;
                localFalseNegatives = 0;
                
                
                
                for index = 1 : numel(manual3)
                    if(manual3(index) == 1)
                        if(edges3(index) == 1)
                            truePositives = truePositives+1;
                            localTruePositives = localTruePositives + 1;
                        else
                            falseNegatives = falseNegatives+1;
                            localFalseNegatives = localFalseNegatives + 1;
                        end
                    else
                        if(edges3(index) == 1)
                            falsePositives = falsePositives+1;
                            localFalsePositives = localFalsePositives + 1;
                        else
                            trueNegatives = trueNegatives+1;
                            localTrueNegatives = localTrueNegatives + 1;
                        end
                    end
                end
                
                
                
                for index = 1 : numel(manual3)
                    if(manual4(index) == 1)
                        if(edges3(index) == 1)
                            nsTruePositives = nsTruePositives+1;
                            
                        else
                            nsFalseNegatives = nsFalseNegatives+1;
                            
                        end
                    else
                        if(edges3(index) == 1)
                            nsFalsePositives = nsFalsePositives+1;

                        else
                            nsTrueNegatives = nsTrueNegatives+1;
                        end
                    end
                end
                
                disp(['per image correct percentage=', num2str(localTruePositives/(localTruePositives+localFalsePositives)), ' score is ', num2str(-(sqrt(localTruePositives/(localTruePositives+localFalseNegatives))*(localTruePositives/localFalsePositives)^2))]);
                disp(['per image correct found pixels percentage=', num2str(localTruePositives/(localTruePositives+localFalseNegatives))]);
                %disp(['per image correct probability percentage =', num2str(probTruePositives/(probTruePositives+probFalsePositives)), ' score is ', num2str(-(sqrt(probTruePositives/(probTruePositives+probFalseNegatives))*(probTruePositives/probFalsePositives)^2))]);
                %disp(['per image correct probability found pixels percentage=', num2str(probTruePositives/(probTruePositives+probFalseNegatives))]);
                %disp(['per image correct non-strict probability percentage =', num2str(nsprobTruePositives/(nsprobTruePositives+nsprobFalsePositives)), ' score is ', num2str(-(sqrt(nsprobTruePositives/(nsprobTruePositives+nsprobFalseNegatives))*(nsprobTruePositives/nsprobFalsePositives)^2))]);
                %disp(['per image correct non-strict probability found pixels percentage=', num2str(nsprobTruePositives/(nsprobTruePositives+nsprobFalseNegatives))]);
                disp('  ');
            end
            res = -(sqrt(truePositives/(truePositives+falseNegatives))*(truePositives/falsePositives)^2);
            if isnan(res)
                res = 0;
            end
            %disp(x)
            disp(truePositives/(truePositives+falsePositives));
            disp(['non-strict correct percentage=', num2str(nsTruePositives/(nsTruePositives+nsFalsePositives))]);
            disp('');
            
            
        end
        
    end
    

    
end

