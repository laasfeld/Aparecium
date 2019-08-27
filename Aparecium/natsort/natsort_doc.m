%% NATSORT Examples
% The function <https://www.mathworks.com/matlabcentral/fileexchange/34464
% |NATSORT|> sorts a cell array of strings (1xN char), taking into account
% any number values within the strings. This is known as a _natural order
% sort_ or an _alphanumeric sort_. Note that MATLAB's inbuilt
% <http://www.mathworks.com/help/matlab/ref/sort.html |SORT|> function sorts
% only by character order, as does |SORT| in most programming languages.
%
% For sorting filenames or filepaths use
% <https://www.mathworks.com/matlabcentral/fileexchange/47434 |NATSORTFILES|>.
%
% For sorting the rows of a cell array of strings use
% <https://www.mathworks.com/matlabcentral/fileexchange/47433 |NATSORTROWS|>.
%
%% Basic Usage: Integer Numbers
% By default |NATSORT| interprets consecutive digits as being part of a
% single integer, each number is considered to be as wide as one character:
A = {'a2', 'a10', 'a1'};
sort(A)
natsort(A)
B = {'v10.6', 'v9.10', 'v9.5', 'v10.10', 'v9.10.20', 'v9.10.8'};
sort(B)
natsort(B)
%% Output 2: Sort Index
% The second output argument is a numeric array of the sort indices |ndx|,
% such that |Y = X(ndx)| where |Y = natsort(X)|:
[~,ndx] = natsort(A)
%% Output 3: Debugging Array
% The third output is a cell array which contains individual characters and
% numbers (after converting to numeric). This is useful for confirming that
% the numbers are being correctly identified by the regular expression.
% Note that the rows of the debugging cell array are
% <https://www.mathworks.com/company/newsletters/articles/matrix-indexing-in-matlab.html
% linearly indexed> from the input cell array.
[~,~,dbg] = natsort(B)
%% Regular Expression: Decimal Numbers, E-notation, +/- Sign
% The |NATSORT| algorithm uses <http://www.mathworks.com/help/matlab/ref/regexp.html
% |REGEXP|> to detect numbers in the strings, and so provides a convenient
% way to specify the format of the numbers, e.g. decimal, +/- sign, etc..
% Simply provide an appropriate <http://www.mathworks.com/help/matlab/matlab_prog/regular-expressions.html
% regular expression> as the second input argument |xpr|:
C = {'test+Inf', 'test11.5', 'test-1.4', 'test', 'test-Inf', 'test+0.3'};
sort(C)
natsort(C, '(-|+)?(Inf|\d+\.?\d*)')
D = {'0.56e007', '', '4.3E-2', '10000', '9.8'};
sort(D)
natsort(D, '\d+\.?\d*(E(+|-)?\d+)?')
%% Regular Expression: Hexadecimal, Octal, and Binary Integers
% Integers encoded in hexadecimal, octal, or binary may also be parsed and
% sorted correctly. This requires both an appropriate regular expression
% that can detect the integers correctly and also a suitable |SSCANF|
% format string for converting the detected number string into numeric
% values (see the section " |SSCANF| Format String"):
E = {'a0X7C4z', 'a0X5z', 'a0X18z', 'aFz'};
sort(E)
natsort(E, '(?<=a)(0X)?[0-9A-F]+', '%x')
F = {'a11111000100z', 'a0B101z', 'a0B000000000011000z', 'a1111z'};
sort(F)
natsort(F, '(0B)?[01]+', '%b')
%% Regular Expression: Interactive Regular Expression Tool
% Regular expressions are powerful and compact, but getting them right is
% not always easy. One assistance is to download my interactive tool
% <https://www.mathworks.com/matlabcentral/fileexchange/48930 |IREGEXP|>,
% which lets you quickly try different regular expressions and see all of
% <https://www.mathworks.com/help/matlab/ref/regexp.html |REGEXP|>'s
% outputs displayed and updated as you type.
%% |SSCANF| Format String: Hexadecimal, Octal, Binary, and 64 Bit Integers
% The default format string |'%f'| will correctly parse many common number
% types: this includes decimal integers, decimal digits, |NaN|, |Inf|,
% and numbers written in E-notation. For hexadecimal, octal, binary, and
% 64-bit integers the format string must be specified as an input argument:
% the supported <http://www.mathworks.com/help/matlab/ref/sscanf.html
% |SSCANF|> formats are shown in this table:
%
% <html>
% <table>
%  <tr><th>Format String</th><th>Number Types</th></tr>
%  <tr><td>%e, %f, %g</td>   <td>floating point numbers</td></tr>
%  <tr><td>%b</td>           <td>binary integer (custom parsing, not SSCANF)</td></tr>
%  <tr><td>%d</td>           <td>signed decimal</td></tr>
%  <tr><td>%i</td>           <td>signed decimal, octal, or hexadecimal</td></tr>
%  <tr><td>%ld, %li</td>     <td>signed 64 bit, decimal, octal, or hexadecimal</td></tr>
%  <tr><td>%u</td>           <td>unsigned decimal</td></tr>
%  <tr><td>%o</td>           <td>unsigned octal</td></tr>
%  <tr><td>%x</td>           <td>unsigned hexadecimal</td></tr>
%  <tr><td>%lu, %lo, %lx</td><td>unsigned 64-bit decimal, octal, or hexadecimal</td></tr>
% </table>
% </html>
%
% For example large
% integers can be converted to 64-bit numerics, with their full precision:
natsort({'a18446744073709551615z', 'a18446744073709551614z'}, [], '%lu')
%% Sort Options: Case Sensitivity
% By default |NATSORT| provides a case-insensitive sort of the input
% strings. An optional argument controls the case sensitivity: the option
% |'ignorecase'| treats all letter characters as upper-case when sorting:
G = {'a2', 'A20', 'A1', 'a10','A2', 'a1'};
natsort(G, [], 'ignorecase') % default
natsort(G, [], 'matchcase')
%% Sort Options: Sort Direction
% By default |NATSORT| provides an ascending sort of the input strings. An
% optional argument controls the sort direction (characters and numbers
% are either both ascending or both descending):
H = {'2', 'a', '3', 'B', '1'};
natsort(H, [], 'ascend') % default
natsort(H, [], 'descend')
%% Sort Options: Order of Numbers Relative to Characters
% By default |NATSORT| treats the detected numbers as if they sorted with
% the digit characters. An optional argument allows the numbers to be
% sorted before or after all characters:
X = num2cell(char(32+randperm(63)));
cell2mat(natsort(X, [], 'asdigit')) % default
cell2mat(natsort(X, [], 'beforechar'))
cell2mat(natsort(X, [], 'afterchar'))