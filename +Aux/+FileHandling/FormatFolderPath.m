function formattedFolderPath = FormatFolderPath(folderPath)
% Normalise a folder path
%
% Input:
%   folderPath          : an arbitrary folder path or an empty string
%
% Output:
%   formattedFolderPath : a formatted folder path with slashes instead
%                         of backslashes (if any) and a slash at the
%                         end. If an empty string was specified at the
%                         input, return the local directory ('./')
%

% If an the input is an empty string, return a relative path to the current
% working directory
if isempty(folderPath)
    formattedFolderPath = './';
    return
end

% Otherwise, remove backslashes and add a slash at the end
formattedFolderPath = folderPath;

formattedFolderPath(formattedFolderPath == '\') = '/';
if formattedFolderPath(end) ~= '/'
    formattedFolderPath = [formattedFolderPath, '/'];
end

end
