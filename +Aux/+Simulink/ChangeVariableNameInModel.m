function [] = ChangeVariableNameInModel(mdlName, varNameOld, varNameNew)
% this funciton finds all usages of 'varNameOld' in the simulink model
% 'mdlName' and replaces them with 'varNameNew'
% ATTENTION: The model must be able to compile, thus the variable which is
% replaced has to exist. 
% Also works on fields and structure names.
%
% Inputs:
%   mdlName:    Name of the model to be treated
%   varNameOld: Name of the variable/structure/field to be changed
%   varNameNew: New name of the variable/structure/field 

% =========================================================================
% Make the regular expression
% =========================================================================
% It matches the given variable name preceeded and succeeded by any
% non-wording character
varNameOldRegExp = ...
    ['(?<!\w)(' regexptranslate('escape', varNameOld) ...
                ')(?!\w)'];
% =========================================================================


% =========================================================================
% Open the model and find ALL blocks which use workspace variables
% =========================================================================
open(mdlName);
VarUsage = Simulink.findVars(mdlName);
UserBlocks = {};
for i = 1 : numel(VarUsage)
    UserBlocks = {UserBlocks{:}, VarUsage(i).Users{:}};
end
% remove duplicate entries and the parant model
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