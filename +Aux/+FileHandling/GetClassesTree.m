function parents = GetClassesTree(classes)
% Get a parent pointer vector for the inheritance structure of the classes
%
% This function supports only single inheritances!
%
% Inputs:
%   classes : a 1xN class array of classes to be scanned through
%
% Outputs:
%   parents : a 1xN vector of parent pointers for <classes>
%
% See also: META.CLASS, META.CLASS.FROMNAME,
%           AUX.FILEHANDLING.GETRECURSIVECLASSES, TREEPLOT, TREELAYOUT

% Go through the classes array and store all names of the first (and
% single) superclass
getParentFun = @(x) x.SuperclassList(1).Name;
parentNames = arrayfun(getParentFun, classes, 'UniformOutput', false);

% Now compare these names to the ones in the classes array and get their
% indices (empty if no match)
findParentIdxFun = @(x) find(strcmp(x, {classes.Name}), 1);
parents = cellfun(findParentIdxFun, parentNames, 'UniformOutput', false);

% Replace empty matches by zeros (root node)
parents(cellfun('isempty', parents)) = {0};

% Convert the cell array into a row vector
parents = [parents{:}];
end