function SaveAndStampTime(expr, format, lineLim)

% TODO Better argins handling
switch nargin
    case 3
        % Activate line limit
        lineLimActive = true;
    case 2
        % Deactivate line limit
        lineLimActive = false;
    case 1
        lineLimActive = false;
        % Specify format
        format = 'full';
    case 0
        lineLimActive = false;
        format = 'full';
        % Specify default regexp
        expr = '^( *)%( *)Last changed:';
end

% =========================================================================
% Get the active document and perform checks
% =========================================================================
currDoc = matlab.desktop.editor.getActive;

% Check if a document is opened in editor
if isempty(currDoc)
    fprintf('No files are currently opened in Editor.\n');
    return
end

% Check if the opened document is a MATLAB function
if ~strcmp(currDoc.Language, 'MATLAB')
    fprintf('The active document is not a valid MATLAB file.\n');
    return
end

% Check if the opened document is empty
if isempty(currDoc.Text)
    fprintf('The active document is empty.\n');
    return
end

% Check if the document can be saved, i.e. has a persistent location on the
% system drive
try
    currDoc.save;
catch
    fprintf(['Could not save current document. Please make sure ' ...
        'it has a persistent location.\n']);
    return
end

% Generate a filename for the backup, regexp .m$ matches .m at the end of
% the string
filenameBackup = regexprep(currDoc.Filename, '.m$', '.bak');
% Backup the active document
try
    movefile(currDoc.Filename, filenameBackup);
catch
    fprintf(['Could not create a backup file. ', ...
        'The original file was not modified!']);
    return
end

% Store the current position within the document
currPos = currDoc.Selection(1 : 2);
% =========================================================================



% =========================================================================
% Make a timestamp
% =========================================================================
% Generate a timestamp according to the specified format
timestamp = Aux.DateAndTime.GetTimestamp(format);

% Read the current document line by line
% Notice: char(10) is equivalent to fprintf('\n')
lines = textscan(currDoc.Text, ...
    '%s', 'delimiter', char(10), 'whitespace', '');
lines = reshape(lines{1}, 1, []);

% Iterate only over non-empty lines
nonEmptyIdx = find(cellfun('isempty', lines) == 0);
% Exclude lines that are after the line limit
if lineLimActive
    nonEmptyIdx(nonEmptyIdx > lineLim) = [];
end

for j = 1 : 1 : length(nonEmptyIdx)
    idx = nonEmptyIdx(j);
    
    % Seek for a match to the specified regexp
    exprMatch = regexp(lines{idx}, expr, 'match');
    if ~isempty(exprMatch)
        % If a match was found, replace this line with a new one
        lines{idx} = [exprMatch{1}, ' ', timestamp];
    end
end
% =========================================================================


% =========================================================================
% Write the new text to the file
% =========================================================================
% Join the lines into a single string
txt = strjoin(lines, char(10));

% Open this file and dump the edited string into it (we may do this since a
% backup was created previously)
fID = [];
try
    fID = fopen(currDoc.Filename, 'w');
    fwrite(fID, txt, 'char');
    fclose(fID);
catch
    fprintf(['Could not write to the file ''%s''. ', ...
        'Please recover the backup ''%s''.'], filename, filenameBackup);
    if ~isempty(fID)
        fclose(fID);
    end
    return
end
% =========================================================================


% =========================================================================
% Reload the file
% =========================================================================
currDoc.reload;
% Go to the saved position
currDoc.goToPositionInLine(currPos(1), currPos(2));
% =========================================================================
end