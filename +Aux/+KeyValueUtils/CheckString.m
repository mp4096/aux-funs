function [ret, pos] = CheckString(stringToCheck, allowedValues)
fun = @(x) strcmp(x, stringToCheck);
pos = find(cellfun(fun, allowedValues));
ret = ~isempty(pos);
end