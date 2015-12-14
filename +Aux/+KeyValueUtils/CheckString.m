function [ret, pos] = CheckString(stringToCheck, allowedValues)
pos = find(strcmp(stringToCheck, allowedValues));
ret = ~isempty(pos);
end
