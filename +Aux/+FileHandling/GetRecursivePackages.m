function packages = GetRecursivePackages(name)
% Get the meta.package information from a package name recursively
%
% Inputs:
%   name     : a string with the package name
%
% Outputs:
%   packages : a 1xN package array of all subpackages within package <name>
%
% See also: META.PACKAGE, META.PACKAGE.FROMNAME

% Get the root package
mp = meta.package.fromName(name);

% Check if it is valid
if isempty(mp)
    error('''%s'' is not a valid package name!', name);
end

% Make a cell array of subpackages
subNames = {mp.PackageList.Name};

% Apply this function to all subpackages
packages = cellfun(@Aux.FileHandling.GetRecursivePackages, subNames, ...
    'UniformOutput', false);

% Pack the results into a vector
packages = [mp, packages{:}];
end