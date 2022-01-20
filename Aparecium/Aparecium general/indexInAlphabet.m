function index = indexInAlphabet(string)
% Calculates what the index of the string is in the extended alphabet
%   Detailed explanation goes here
    twoLetterAlphabet = alphabet(numel(alphabet)^2, true);
    index = find(strcmp(twoLetterAlphabet, string));
end

