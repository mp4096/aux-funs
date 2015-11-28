function filenames = GetFiles(folder, extension)
% Get all filenames in the specifed folder of the specified extension
% The filtering by extension is case-insensitive.
%
% Input:
%   folder      : path to the folder to be scanned
%   [extension] : desired file extension, returns all files if empty,
%                 specified with '\w'-chars only. Default: []
%
% Output:
%   filenames   : column cell array with the detected filenames
%

% =========================================================================
% Pre-processing of the extension specification
% =========================================================================
if nargin == 1
    % Default value
    extension = [];
else
    % Check the extension specification. It may not contain any chars
    % different from 'a'...'z', 'A'...'Z', '0'...'9' and '_'.
    if ~strcmp(extension, regexprep(extension, '[^\w]', ''))
        error(['Invalid extension specification! ', ...
            'Non-''\w'' chars are not allowed.']);
    end
end
% =========================================================================


% =========================================================================
% Scan for files
% =========================================================================

% Normalise folder string
folder = Aux.FileHandling.FormatFolderPath(folder);

% If the extension is specified, search for it specifically, else get all
% files in the directory
if ~isempty(extension)
    searchString = [folder, '*.', extension];
else
    searchString = folder;
end

% Get the listing of objects within the folder
detectedObjects = dir(searchString);

% Delete directories (if no extensions were specified)
detectedObjects([detectedObjects.isdir]) = [];

% Repack the fields of a struct array into a cell array
filenames = {detectedObjects.name};
% Make it a column cell array
filenames = filenames(:);

% Add folder path to the filenames
catFun = @(fname) strcat(folder, fname);
filenames = cellfun(catFun, filenames, 'UniformOutput', false);
% =========================================================================


% =========================================================================
% If no output arguments, print results to the Command Window
% =========================================================================
if nargout == 0
    fprintf('\nScanned path ''%s'', detected %i file(s)', ...
        folder, length(filenames));
    
    if ~isempty(extension)
        fprintf(' with the specified extension');
    end
    
    fprintf(':\n\t%s\n', strjoin(filenames, '\n\t'));
end
% =========================================================================
end
