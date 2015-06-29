function ToggleTags(varargin)
% Toggles marked commented blocks in the active file opened in editor
%
% This function makes a .bak backup of the currently opened file and then
% overwrites it. Nevertheless, please use source control.
%
% Inputs:
%   varargin  : an arbitrary number of tags, which are identified as
%               '% =<`tagname`<=' and '% =>`tagname`>=' in the code.
%               Default value is 'default'.

% =========================================================================
% Check input arguments and prepare the tags
% =========================================================================
if nargin == 0
    tags = {'default'};
else
    tags = varargin;
    % varargin is a row cell array, but just make it sure
    tags = reshape(tags, 1, []);
    
    % Check if all input arguments are strings
    if ~all(cellfun(@isstr, tags))
        error('Invalid input arguments: Only strings are allowed!');
    end
    
    % Check if all input arguments match to the regexp (\w*), i.e. each
    % argument is exactly one word with symbols from the set {a-z, A-Z,
    % underscore, 0-9}
    if ~all(strcmp(regexp(tags, '(\w*)', 'once', 'match'), tags))
        error('Invalid input arguments: Tag name must be one word (\w*)!');
    end
end

tagsOpen  = cellfun(@(s) ['%=<', s, '<='], tags, 'UniformOutput', false);
tagsClose = cellfun(@(s) ['%=>', s, '>='], tags, 'UniformOutput', false);
% =========================================================================


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
% Toggle comments
% =========================================================================
% Read the current document line by line
% Notice: char(10) is equivalent to fprintf('\n') and all whitespaces are
% preserved
lines = textscan(currDoc.Text, '%s', ...
    'Delimiter', char(10), 'whitespace', '');
lines = reshape(lines{1}, 1, []);

% No tag is active
currTag = 0;
currIndent = '';

% Iterate only over non-empty lines
nonEmptyIdx = find(cellfun(@isempty, lines) == 0);
for j = 1 : 1 : length(nonEmptyIdx)
    idx = nonEmptyIdx(j);
    
    % =====================================================================
    % Detect tags
    % =====================================================================
    % Apart from the whitespaces the current line must be a perfect match
    % to the opening or closing tag
    tagCompStr = strrep(lines{idx}, ' ', '');
    idxOpenTag  = find(strcmp(tagCompStr, tagsOpen), 1);
    idxCloseTag = find(strcmp(tagCompStr, tagsClose), 1);
    % If nothing found, set the tag index to zero
    if isempty(idxOpenTag)
        idxOpenTag  = 0;
    end
    if isempty(idxCloseTag)
        idxCloseTag = 0;
    end
    % Store whether the current line contains a tag
    isATag = (idxOpenTag > 0) || (idxCloseTag > 0);
    % =====================================================================
    
    
    % =====================================================================
    % Decide the current environment (toggling block or not)
    % =====================================================================
    % Process opening tags...
    if (currTag == 0) && (idxOpenTag > 0)
        % If we were not within a toggling block and now see an opening
        % tag, set the current tag index to this new tag index
        currTag = idxOpenTag;
        % Furthermore, remember the active indent width
        currIndent = regexp(lines{idx}, '^( *)', 'match');
        currIndent = currIndent{1};
    elseif (currTag > 0) && (idxOpenTag > 0)
        % If we were within a toggling block and now see a new opening
        % tag, this is nesting and it is not supported
        error('Nested tag blocks in line %i!', idx);
    end
    
    % Process opening tags...
    if currTag == idxCloseTag
        % If we are within some toggling block and now see a corresponding
        % closing tag, then the toggling block is over and we are in the
        % inactive environment
        currTag = 0;
        % Also set the indent to zero
        currIndent = '';
    elseif (currTag ~= idxCloseTag) && (idxCloseTag > 0)
        % If we are within some toggling block and now see a different
        % closing tag, then something is wrong
        error('Unexpected closing tag in line %i!', idx);
    end
    % =====================================================================
    
    
    % =====================================================================
    % Comments toggling
    % =====================================================================
    % If a toggling block is active and the current line does not contain
    % any tags, toggle comments
    if (currTag ~= 0) && (~isATag)
        % Match to the regexp anchored to the string beginning and allowing
        % any number of whitespaces before and after the percent symbol
        [match0, match1] = regexp(lines{idx}, '(^( *)%( *))');
        
        if isempty(match0)
            % If no match, then the line is active and should be commented
            lines{idx} = [currIndent, '% ', noLeadingWs];
        else
            % Else delete the comment symbol
            lines{idx}(match0(1) : match1(1)) = [];
            lines{idx} = [currIndent, lines{idx}];
        end
    end
    % =====================================================================
end

% If at the end we still are in some toggling environment, then the tags
% were incorrectly specified
if currTag > 0
    error('Tags mismatch!');
end
% =========================================================================


% =========================================================================
% Write the new text to the file
% =========================================================================
% Join the lines into a single string
txt = strjoin(lines, char(10));

% Store the filename before the active document is closed
filename = currDoc.Filename;

% Save and close the active document
currDoc.save;
currDoc.closeNoPrompt;

% Open this file and dump the edited string into it (we may do this since a
% backup was created previously)
fID = [];
try
    fID = fopen(filename, 'w');
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
% Open the file again
% =========================================================================
edit(filename);

% Go to the saved position
currDoc = matlab.desktop.editor.getActive;
currDoc.goToPositionInLine(currPos(1), currPos(2));
% =========================================================================
end