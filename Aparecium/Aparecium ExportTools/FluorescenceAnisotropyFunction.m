function [ fluorescenceAnisotropy ] = FluorescenceAnisotropyFunction(parallelIntensityes, perpendicularIntentsities)
%UNTITLED2 Calculate fluorescence anisotropy
%   First argument is singe, vector or matrix value of parallelIntensities,
%   Second argument is singe, vector or matrix value of
%   parallelIntensities. Both inputs must be matrices of the same size.

fluorescenceAnisotropy = (parallelIntensityes-perpendicularIntentsities)./(parallelIntensityes + 2*perpendicularIntentsities);

end

