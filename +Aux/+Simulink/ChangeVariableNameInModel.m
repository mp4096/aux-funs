function [] = ChangeVariableNameInModel(mdlName, varNameOld, varNameNew)
% this funciton finds all usages of 'varNameOld' in the simulink model
% 'mdlName' and replaces them with 'varNameNew'
% ATTENTION: The model must be able to compile, thus the variable which is
% replaced has to exist

% find blocks which use the variable
VarUsage = Simulink.findVars(mdlName, 'Name', varNameOld);
UserBlocks = VarUsage.Users;

% Find parameters of the UserBlocks
UserBlocksDialogParam = get_param(UserBlocks,'DialogParameters');

% Loop through UserBlocks
for i = 1 : length(UserBlocks)
    % Find dialog parameter names of the current UserBlock
    UserBlocksFieldnames = fieldnames(UserBlocksDialogParam{i});
    % Loop through all parameters of the current block  
    for j = 1 : length(UserBlocksFieldnames)
        if strcmp(varNameOld, get_param(UserBlocks{i}, UserBlocksFieldnames{j}))
            set_param(UserBlocks{i}, UserBlocksFieldnames{j}, varNameNew);
            fprintf('Replaced parameter %s in block %s \n', UserBlocksFieldnames{j}, ...
                UserBlocks{i});
        end
    end
end        

end