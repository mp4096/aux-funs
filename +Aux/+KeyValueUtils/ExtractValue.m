function [status, value] = ExtractValue(parameterName, varargin)

status = 0;
numArgs = length(varargin);

if mod(numArgs, 2) ~= 0
    error('Invalid number of arguments: Missing names or values');
end

input = reshape(varargin, 2, numArgs/2)';

parameterIndex = strcmp(input(:, 1), parameterName);

switch sum(parameterIndex)
    case 0
        status = -1;
        value = 'Parameter not found!';
    case 1
        value = input{parameterIndex == 1, 2};
    otherwise
        status = -2;
        value = 'Parameter value ambiguous!';
end

if status == -2
    error(value);
end
end
