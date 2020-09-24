for k = 1 : 9
    for image = [1,2,4,5]
        for imagingLoc = 1 : 10
            pool = [];
            for comb = 1 : numel(spotAnalysisResults{k})
                pool = [pool, spotAnalysisResults{k}{comb}{image}(imagingLoc)];
            end
            means(k, image, imagingLoc) = mean(pool);
        end
    end
end

means(:,3,:) = [];
meanMean = mean(means, 3);

figure
hold on
for i = 1 : 4
plot(1:9, meanMean(:,i));
end

for k = 1 : 9
    for image = [1,2,4,5]
        for imagingLoc = 1 : 10
            pool = [];
            for comb = 1 : numel(spotAnalysisResults{k})
                pool = [pool, spotAnalysisResults{k}{comb}{image}(imagingLoc)];
            end
            deviations(k, image, imagingLoc) = std(pool);
        end
    end
end

deviations(:,3,:) = [];
devMean = mean(deviations, 3);

figure
hold on
for i = 1 : 4
plot(1:9, devMean(:,i));
end

for k = 1 : 9
    for image = [1,2,4,5]
        for imagingLoc = 1 : 10
            pool = [];
            for comb = 1 : numel(spotAnalysisResults{k})
                pool = [pool, spotAnalysisResults{k}{comb}{image}(imagingLoc)];
            end
            relativeDeviations(k, image, imagingLoc) = std(pool)/mean(pool);
        end
    end
end

relativeDeviations(:,3,:) = [];
relativeDeviationsMean = mean(relativeDeviations, 3);

figure
hold on
for i = 1 : 4
    plot(1:9, relativeDeviationsMean(:,i));
end

relativeDeviations = [];
for run = 1 : 100
    for image = [1,2,4,5]
        for k = 1 : 9    
            for imagingLoc = 1 : 10
                pool = [];
                indices = randperm(10, imagingLoc);
                for comb = 1 : numel(spotAnalysisResults{k})                    
                    %pool = [pool, std(spotAnalysisResults{k}{comb}{image}(indices))/mean(spotAnalysisResults{k}{comb}{image}(indices))];
                    pool = [pool, mean(spotAnalysisResults{k}{comb}{image}(indices))];

                end
                relativeDeviations(image, k,  imagingLoc, run) = mean(pool);
            end
        end
    end
end
relativeDeviations(3,:,:,:) = [];
runMeanRelativeDeciations = mean(relativeDeviations, 4);
for i = 1 : 4
    figure
    surf(squeeze(runMeanRelativeDeciations(i,:,:)));
end