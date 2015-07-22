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
varNameNew = regexptranslate('escape', varNameNew);
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
userBlocksDialogParam = get_param(userBlocks, 'DialogParameters');

% Find dialog parameter names of the current 'userBlock'
userBlocksFieldnames = ...
    cellfun(@fieldnames, userBlocksDialogParam, 'UniformOutput', false);

% Replicate user blocks so that they match the number of the fieldnames
userBlocksFlat = cellfun(@(x, y) repmat({x}, length(y), 1), ...
    userBlocks, userBlocksFieldnames, 'UniformOutput', false);

% Flatten the cell arrays
userBlocksFieldnames = cat(1, userBlocksFieldnames{:});
userBlocksFlat = cat(1, userBlocksFlat{:});

% Get only char parameters of the 'userBlocksFlat'
fun = @(b, f) ischar(get_param(b, f));
idx = cellfun(fun, userBlocksFlat, userBlocksFieldnames);

% Perform low-level replace using the specified names
fun = @(x, y) LowLevelReplace(x, y, varNameOldRegExp, varNameNew);
cellfun(fun, userBlocksFlat(idx), userBlocksFieldnames(idx));
% =========================================================================
end

function LowLevelReplace(block, fieldname, oldVarExpr, newVar)
parValOld = get_param(block, fieldname);
parValNew = regexprep(parValOld, oldVarExpr, newVar);
if ~strcmp(parValOld, parValNew)
    set_param(block, fieldname, parValNew);
    fprintf( ...
        'Replaced parameter ''%s'' in block ''%s'': ', fieldname, block);
    fprintf('''%s'' -> ''%s''\n', parValOld, parValNew);
end
end