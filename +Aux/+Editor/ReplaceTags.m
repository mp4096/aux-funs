function [] = ReplaceTags(inFile, outFile, tagsToReplace, ...
    replaceBy )
% REPLACETAGS Function to replace the tags collected in the tagsToReplace 
% by cell by the values in the replaceBy cell array

% Read Code
hTemplate = fopen(inFile, 'r');
templateContent = fread(hTemplate, [1, inf], '*char');
fclose(hTemplate);

if numel(tagsToReplace) == numel(replaceBy)
    nRepl = numel(tagsToReplace);
else
    error('Cells tagsToReplace and replaceBy must be of same length');
end

% replace tags
for i = 1 : nRepl
    % replace                       
    templateContent = strrep(templateContent, tagsToReplace{i}, ...
        replaceBy{i});
end

% save file
hTemplate = fopen(outFile, 'w');
fwrite(hTemplate, templateContent, 'char');
fclose(hTemplate);

end

