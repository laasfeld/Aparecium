function result = alphabet(varargin)
%UNTITLED2 returns an alphabet 
%   alphabet() returns an upper case version of alphabet as a string
%   alphabet(i) returns the i-th element of the alphabet 
alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
if isequal(numel(varargin), 0)
    result = alphabet;
    return
elseif isequal(numel(varargin), 1)
    index = varargin{1};
    result = alphabet(index);
end

