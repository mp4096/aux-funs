function escStr = Escape(rawStr, escChrs)
% Escape LaTeX special characters (only single chars)
%
% Following chars will be escaped by default:
% %, $, #, _, &, {, }, \, ~
%
% Inputs:
%   str       : input string
%   [escChrs] : Nx2 cell array with chars to be escaped, optional
%               The first column should contain the special characters to
%               be escaped, the second column specifies their replacements.
%
% Outputs:
%   ret       : output string

if nargin == 1
    escChrs = { ...
        '%', '{\%}'; ...
        '$', '{\$}'; ...
        '#', '{\#}'; ...
        '_', '{\_}'; ...
        '&', '{\&}'; ...
        '{', '{\{}'; ...
        '}', '{\}}'; ...
        '\', '{\textbackslash}'; ...
        '~', '{\textasciitilde}'; ...
        };
end

% 'compFun' compares a char ('c') with the list of special characters
compFun = @(c) cellfun(@(x) x == c, escChrs(:, 1));
% 'replFun' replaces a special char ('c') with its escaped counterpart
replFun = @(c) escChrs{compFun(c), 2};

% Get the indices of all special characters in the raw string
idx = arrayfun(@(c) any(compFun(c)), rawStr);
% Convert the raw string into a cell array of single chars (since an
% escaped char can be longer than one character)
escStr = num2cell(rawStr);
% Replace the special chars
escStr(idx) = cellfun(replFun, escStr(idx), 'UniformOutput', false);
% Join the cells into one string (without separators)
escStr = strjoin(escStr, '');
end