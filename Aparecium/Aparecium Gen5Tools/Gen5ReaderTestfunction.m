result = [];
testPath = 'C:\Users\dell\Desktop\Bakalaureuse töö bioorgaanikas\Aparecium project\NeoASCII reader development\erinevate procedurite näidiskatsed\'
%% configuration 1 test
fileName = [testPath, 'Konfig1\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{1} = 'Success'
catch
    result{1} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 2 test

fileName = [testPath, 'Konfig1\160222_125616_NoName_User_Poolel plaadil samplid.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{2} = 'Success'
catch
    result{2} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 3 test

fileName = [testPath, 'Konfig1\160222_125616_NoName_User_Samplid teist pidi.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{3} = 'Success'
catch
    result{3} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 4 test

fileName = [testPath, 'Konfig2\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{4} = 'Success'
catch
    result{4} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 5 test

fileName = [testPath, 'Konfig3\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{5} = 'Success'
catch
    result{5} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 6 test

fileName = [testPath, 'Konfig4\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{6} = 'Success'
catch
    result{6} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 7 test

fileName = [testPath, 'Konfig5\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{7} = 'Success'
catch
    result{7} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 8 test

fileName = [testPath, 'Konfig6\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{8} = 'Success'
catch
    result{8} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 9 test

fileName = [testPath, 'Konfig7\160222_125616_NoName_User.txt'];
NeoReader = NeoASCIIReader();
try
    NeoReader.readFile(fileName);
    result{9} = 'Success'
catch
    result{9} = 'Fail'
end
clear fileName;
clear NeoReader;

%% configuration 10 test

% fileName = [testPath, 'Konfig8\160222_125616_NoName_User.txt'];
% NeoReader = NeoASCIIReader();
% try
%     NeoReader.readFile(fileName);
%     result{10} = 'Success'
% catch
%     result{10} = 'Fail'
% end
% clear fileName;
% clear NeoReader;


%% configuration 11 test

% fileName = [testPath, 'Konfig8\160222_125616_NoName_User_Erinevad intervallid.txt'];
% NeoReader = NeoASCIIReader();
% try
%     NeoReader.readFile(fileName);
%     result{11} = 'Success'
% catch
%     result{11} = 'Fail'
% end
% clear fileName;
% clear NeoReader;