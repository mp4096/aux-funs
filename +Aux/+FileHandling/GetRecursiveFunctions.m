function funs = GetRecursiveFunctions(name)
% Get recursively all functions within a package and its subpackages
%
% Inputs:
%   name : a string with the package name
%
% Outputs:
%   funs : a 1xN class array of all functions within package <name>
%
% See also: META.METHOD, AUX.FILEHANDLING.GETRECURSIVECLASSES,
%           AUX.FILEHANDLING.GETRECURSIVEPACKAGES

% Get a recursive list of all packages
packages = Aux.FileHandling.GetRecursivePackages(name);

% Delete packages that contain no functions
noFuns = cellfun('isempty', {packages.FunctionList});
packages(noFuns) = [];

% Unfold and concatenate the functions list into a 1xN array
funs = {packages.FunctionList};
funs = cat(1, funs{:})';
end