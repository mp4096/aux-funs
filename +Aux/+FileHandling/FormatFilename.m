function [fullFormattedFilename, onlyFilename, location] = ...
    FormatFilename(filename, extension)
% Normalise a filename

if nargin == 1
    extension = '';
end

extension = strrep(extension, '.', '');

% Separate the location from the filename
[location, onlyFilename, ~] = fileparts(filename);
location = [strrep(location, '\', '/'), '/'];

% Store the full path to the file (with extension)
if isempty(extension)
    fullFormattedFilename = [location, onlyFilename];
else
    fullFormattedFilename = [location, onlyFilename, '.', extension];
end
end