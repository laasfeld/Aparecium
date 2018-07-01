function handles = generateApareciumExperimentInput(handles, experimentDataStructure)
    if(isstruct(experimentDataStructure))
        originalID = experimentDataStructure.wellID';
        numberOfCycles = size(experimentDataStructure.timeOfMeasurements, 1);
        numberOfChannels = experimentDataStructure.numberOfChannels;
        channelNames = experimentDataStructure.channelNames;

        [height,width,wellID,inUse] = generateGhostplate(originalID);
        try
            measurements = generateMeasurements(originalID, wellID, experimentDataStructure.measurements, numberOfCycles, numberOfChannels, width, height);
            handles.apareciumExperimentInput.setMeasurements(measurements);
        catch
            'measurements not defined in experiment'
        end
        handles.apareciumExperimentInput.setMode('addTreatments')
        handles.apareciumExperimentInput.setWells(wellID);
        handles.apareciumExperimentInput.setInUse(inUse);
        handles.apareciumExperimentInput.setNumberOfCycles(numberOfCycles);
        handles.apareciumExperimentInput.setChannelNames(channelNames);
        handles.apareciumExperimentInput.setCycleTimeMoments(experimentDataStructure.timeOfMeasurements);
    elseif iscell(experimentDataStructure)
        experimentDataStructure = experimentDataStructure{1};
        originalID = experimentDataStructure.wellID';
        numberOfCycles = size(experimentDataStructure.timeOfMeasurements, 1);
        numberOfChannels = experimentDataStructure.numberOfChannels;
        channelNames = experimentDataStructure.channelNames;

        [height,width,wellID,inUse] = generateGhostplate(originalID);
        try
            measurements = generateMeasurements(originalID, wellID, experimentDataStructure.measurements, numberOfCycles, numberOfChannels, width, height);
            handles.apareciumExperimentInput.setMeasurements(measurements);
        catch
            'measurements not defined in experiment'
        end
        handles.apareciumExperimentInput.setMode('addTreatments')
        handles.apareciumExperimentInput.setWells(wellID);
        handles.apareciumExperimentInput.setInUse(inUse);
        handles.apareciumExperimentInput.setNumberOfCycles(numberOfCycles);
        handles.apareciumExperimentInput.setChannelNames(channelNames);
    end
end

function reshapedMeasurements = generateMeasurements(originalID, wellID, measurements, numberOfCycles, numberOfChannels, width, height)
    reshapedMeasurements = zeros(width, height, numberOfCycles, numberOfChannels);
    for col = 1 :  width 
        for row = 1 : height
            wellIndex =  find(strcmp(originalID, wellID{col, row}));
            if isempty(wellIndex)
                reshapedMeasurements(col, row, 1 : numberOfCycles, 1 : numberOfChannels) = 0;
            else
                for cycle = 1 : numberOfCycles
                    for channel = 1 : numberOfChannels
                        reshapedMeasurements(col, row, cycle, channel) = measurements{wellIndex}((cycle-1) * numberOfChannels + channel); 
                    end
                end
            end
        end
    end
end
