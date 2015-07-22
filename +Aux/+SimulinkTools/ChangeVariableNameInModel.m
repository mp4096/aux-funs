function ChangeVariableNameInModel(mdlName, varNameOld, varNameNew)
% Find a variable in a Simulink model and rename it in all instances
%
% This function finds all usages of 'varNameOld' in the Simulink model
% 'mdlName' and replaces them with 'varNameNew'. It also works on fields
% and structure names.
%
% ATTENTION: The model must be able to compile, thus the variable which is
% replaced has to exist.
%
% Inputs:
%   mdlName    : name of the model to be treated
%   varNameOld : name of the variable/structure/field to be changed
%   varNameNew : new name of the variable/structure/field


% =========================================================================
% Make the regular expression
% =========================================================================
% It matches the given variable name preceeded and succeeded by any
% non-wording character
varNameOldRegExp = ...
    ['(?<!\w)(' regexptranslate('escape', varNameOld) ')(?!\w)'];
% =========================================================================


% =========================================================================
% Open the model and find _all_ blocks which use workspace variables
% =========================================================================
open(mdlName);
varUsage = Simulink.findVars(mdlName);
userBlocks = {varUsage.Users};
userBlocks = cat(1, userBlocks{:});

% Remove duplicate entries and the parant model
userBlocks = unique(userBlocks);
userBlocks = userBlocks(~strcmp(userBlocks, mdlName));
% =========================================================================


% =========================================================================
% Replace the variables
% =========================================================================
% Find parameters of 'userBlocks'
userBlocksDialogParam = get_param(userBlocks,'DialogParameters');

% Loop through 'userBlocks'
for i = 1 : length(userBlocks)
    % Find dialog parameter names of the current 'userBlock'
    userBlocksFieldnames = fieldnames(userBlocksDialogParam{i});
    % Loop through all parameters of the current block
    for j = 1 : length(userBlocksFieldnames)
        parValOld = get_param(userBlocks{i}, userBlocksFieldnames{j});
        if ischar(parValOld)
            parValNew = regexprep(parValOld, ...
                varNameOldRegExp, regexptranslate('escape', varNameNew));
            if ~strcmp(parValOld, parValNew)
                set_param(userBlocks{i}, userBlocksFieldnames{j}, parValNew);
                fprintf('Replaced parameter %s in block %s \n', ...
                    userBlocksFieldnames{j}, userBlocks{i});
            end
        end
    end
end
% =========================================================================
end