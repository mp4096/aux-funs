function AuxFunsInstall
% Installation function for the 'aux-funs' mini-toolbox
% Please run it only from the installation folder!

% Get the current path
currPath = cd;

% =========================================================================
% Perform a very simple check if the current path is the right one
% =========================================================================
% 2 means any file
licenseFound = exist('./LICENSE', 'file') == 2;
% 7 means any folder
auxFolderFound = exist('./+Aux', 'dir') == 7;

if ~(licenseFound && auxFolderFound)
    error('You are probably not in the aux-funs directory!');
end
% =========================================================================

% Seems to be ok now, so add it to the paths and update the hash
addpath(currPath);
rehash;

try
    savepath;
    fprintf('aux-funs installed successfully! Enjoy!\n');
catch
    warning(['The updated MATLAB path could not be saved. ', ...
        'This can happen if you do not have admin rights on this ', ...
        'computer. aux-funs will be installed only for this session.']);
end
end