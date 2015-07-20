function classes = GetRecursiveClasses(name)
% Get recursively all classes within a package and its subpackages
%
% Inputs:
%   name    : a string with the package name
%
% Outputs:
%   classes : a 1xN class array of all classes within package <name>
%
% See also: META.CLASS, META.CLASS.FROMNAME,
%           AUX.FILEHANDLING.GETRECURSIVEPACKAGES
%           AUX.FILEHANDLING.GETRECURSIVEFUNCTIONS

% Get a recursive list of all packages
packages = Aux.FileHandling.GetRecursivePackages(name);

% Delete packages that contain no classes
noClasses = cellfun('isempty', {packages.ClassList});
packages(noClasses) = [];

% Unfold and concatenate the classes list into a 1xN array
classes = {packages.ClassList};
classes = cat(1, classes{:})';
end