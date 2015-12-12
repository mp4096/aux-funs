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

% Define the default escape combinations if no second argument
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

% Create a map with the characters to be escaped as keys
escMap = containers.Map(escChrs(:, 1), escChrs(:, 2), 'UniformValues', 1);

% Split the raw string into normal and special (i.e. to be escaped)
% characters. Notice the 'CollapseDelimiters' option, it is mandatory here.
[normalChars, specialChars] = ...
    strsplit(rawStr, escChrs(:, 1), 'CollapseDelimiters', false);

% Replace the special characters with the values from the map
specialChars = values(escMap, specialChars);

% Zip the escaped special and normal characters together. Pad the special
% characters with a empty cell so that both arrays have the same length.
escStr = [normalChars; [specialChars, {''}]];
escStr = escStr(:).';

% Join the cells into one string (without separators)
escStr = strjoin(escStr, '');
end
