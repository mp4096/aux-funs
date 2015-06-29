function SaveAndStampTime(expr, format)

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
% =========================================================================



% =========================================================================
% Toggle comments
% =========================================================================
% Read the current document line by line
% Notice: char(10) is equivalent to fprintf('\n')
lines = textscan(currDoc.Text, '%s', 'delimiter', char(10), 'whitespace', '');
lines = reshape(lines{1}, 1, []);

% Iterate only over non-empty lines
nonEmptyIdx = find(cellfun('isempty', lines) == 0);
for j = 1 : 1 : length(nonEmptyIdx)
    idx = nonEmptyIdx(j);
    lines{idx} = regexprep(lines{idx}, expr, timestamp);
end


end