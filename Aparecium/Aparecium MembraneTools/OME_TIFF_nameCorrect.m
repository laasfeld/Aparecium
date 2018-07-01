function OME_TIFF_nameCorrect()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

kaust = 'D:\171013_170346_171013_Experiment1_D3R in time_but\171013_170346_Plate 1\001\';
pildid = dir(kaust);
nimed = cell(numel(pildid), 1);
for a = 1 : numel(pildid)
    if ~isempty(strfind(pildid(a).name, '.tif'))
        nimed{a} = pildid(a).name;
    end
end

for i = numel(nimed) : -1 : 1
    try
       if strcmp(nimed{i}(1), '_') || strcmp(nimed{i}(1), '[') || strcmp(nimed{i}(1), '^')

       else
          nimed(i) = []; 
       end
    catch
        nimed(i) = []; 
    end
end
%nimed(1:2) = [];
doNotCloseMatlabpoolPool = 0;
doNotCloseParpool = 0;
try
    matlabpool
catch MException
    if(strcmp(MException.identifier, 'distcomp:interactive:OpenConnection'))
        doNotCloseMatlabpoolPool = 1;
    elseif strcmp(MException.identifier,'MATLAB:UndefinedFunction')
        try
            pool = parpool;
            doNotCloseMatlabpoolPool = 1;
        catch Exception2
            if strcmp(MException.identifier, 'parallel:convenience:ConnectionOpen')
                doNotCloseParpool = 1;
            end
        end
    else
                
    end
end
nimed(cellfun(@isempty, nimed)) = [];
for a = 1 : numel(nimed)
    l = Cytation5TIFFImage([kaust, '\', nimed{a}]);
    wellinimi = l.getWellName();
    index = l.getReadStepSequance() + 1;
    if index < 10
        index = ['0', num2str(index)];    
    else
        index = num2str(index);
    end
    
    if(isempty(strfind(nimed{a}, 'Bright Field')))
       channelIndex = '2';
       channelName = 'RFP';
    else
       channelIndex = '1';
       channelName = 'Bright Field';
    end
    
    kineticIndex = l.getKineticSequence() + 1;
    if kineticIndex < 10
        kineticIndex = ['00', num2str(kineticIndex)];
    elseif kineticIndex < 100 
        kineticIndex = ['0', num2str(kineticIndex)];
    else
        kineticIndex = num2str(kineticIndex);
    end
    
    failinimi = [wellinimi,'_',index,'_',channelIndex,'_1Z',num2str(l.getImageFocus() - 1),'_',channelName,'_',kineticIndex,'.tif'];
    result = java.io.File([kaust, '\', nimed{a}]).renameTo(java.io.File([kaust, '\', failinimi]));
    if isequal(result, 0)
       
    end
end

if doNotCloseMatlabpoolPool
    
else
    try
        matlabpool close;
    catch
        
    end
end

if doNotCloseParpool
    
else
    pool.delete();
end

end



