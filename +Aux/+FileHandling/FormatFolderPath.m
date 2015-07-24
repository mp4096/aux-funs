function formattedFolderPath = FormatFolderPath(folderPath)
% Normalise a folder path
%
% Inputs:
%   folderPath           : an arbitrary folder path or an empty string
%
% Outputs:
%   formattedFolderPath  : a formatted folder path with slashes instead
%                          of backslashes (if any) and a slash at the
%                          end. If an empty string was specified at the
%                          input, return the local directory ('./')
%
% See also: AUX.FILEHANDLING.FORMATFILENAME

% If an empty string, return local folder
if isempty(folderPath)
    formattedFolderPath = './';
    return
end

% Otherwise remove backslashes and add a slash at the end
formattedFolderPath = folderPath;

formattedFolderPath = strrep(formattedFolderPath, '\', '/');
if formattedFolderPath(end) ~= '/'
    formattedFolderPath = [formattedFolderPath '/'];
end
end