function [ TFI ] = TotalFluorescenceIntensityFunction(parallelIntensities, perpendicularIntentsities)
%UNTITLED2 Calculate total fluorescence intensity
%   First argument is singe, vector or matrix value of parallelIntensities,
%   Second argument is singe, vector or matrix value of
%   parallelIntensities. Both inputs must be matrices of the same size.

TFI = parallelIntensities + 2*perpendicularIntentsities;

end

