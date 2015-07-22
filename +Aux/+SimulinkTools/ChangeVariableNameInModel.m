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
VarUsage = Simulink.findVars(mdlName);
UserBlocks = {};
for i = 1 : numel(VarUsage)
    UserBlocks = {UserBlocks{:}, VarUsage(i).Users{:}};
end
% Remove duplicate entries and the parant model
UserBlocks = unique(UserBlocks);
UserBlocks = UserBlocks(~strcmp(UserBlocks, mdlName));
% =========================================================================


% =========================================================================
% Replace the variables
% =========================================================================
% Find parameters of the UserBlocks
UserBlocksDialogParam = get_param(UserBlocks,'DialogParameters');

% Loop through UserBlocks
for i = 1 : length(UserBlocks)
    % Find dialog parameter names of the current UserBlock
    UserBlocksFieldnames = fieldnames(UserBlocksDialogParam{i});
    % Loop through all parameters of the current block
    for j = 1 : length(UserBlocksFieldnames)
        parValOld = get_param(UserBlocks{i}, UserBlocksFieldnames{j});
        if ischar(parValOld)
            parValNew = regexprep(parValOld, ...
                varNameOldRegExp, regexptranslate('escape', varNameNew));
            if ~strcmp(parValOld, parValNew)
                set_param(UserBlocks{i}, UserBlocksFieldnames{j}, parValNew);
                fprintf('Replaced parameter %s in block %s \n', ...
                    UserBlocksFieldnames{j}, UserBlocks{i});
            end
        end
    end
end
% =========================================================================
end