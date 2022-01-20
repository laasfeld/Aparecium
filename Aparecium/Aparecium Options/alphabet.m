function result = alphabet(varargin)
%UNTITLED2 returns an alphabet 
%   alphabet() returns an upper case version of alphabet as a string
%   alphabet(i) returns the i-th element of the alphabet 
%   alphabet(i, true) returns the alphabet from start to the i-th element
alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
if isequal(numel(varargin), 0)
    result = alphabet;
    return
elseif isequal(numel(varargin), 1)
    index = varargin{1};
    if numel(alphabet) >= index
        result = alphabet(index);
    else
        doubleAlphabet = cell(numel(alphabet)^2 + numel(alphabet), 1);
        doubleAlphabet(1:numel(alphabet)) = cellstr(alphabet');
        counter = numel(alphabet);
        for firstLetter = 1 : numel(alphabet)
            for secondLetter = 1 : numel(alphabet)
                counter = counter + 1;
                doubleAlphabet(counter) = {[alphabet(firstLetter), alphabet(secondLetter)]}; 
            end
        end
        result = doubleAlphabet{index};
    end
elseif isequal(numel(varargin), 2)
    index = varargin{1};
    if varargin{2}
        
    end    
        
    if numel(alphabet) >= index
        if varargin{2}
            result = alphabet(1:index);
        else
            result = alphabet(index);
        end
        return
    else
        doubleAlphabet = cell(numel(alphabet)^2 + numel(alphabet), 1);
        doubleAlphabet(1:numel(alphabet)) = cellstr(alphabet');
        counter = numel(alphabet);
        for firstLetter = 1 : numel(alphabet)
            for secondLetter = 1 : numel(alphabet)
                counter = counter + 1;
                doubleAlphabet(counter) = {[alphabet(firstLetter), alphabet(secondLetter)]}; 
            end
        end                  
    end 
    if varargin{2}
        result = doubleAlphabet(1:index);        
    else
        result = doubleAlphabet{index};
    end
    end
end

