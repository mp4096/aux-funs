function [status, value] = ExtractValue(parameterName, varargin)
status = 0;
N = length(varargin);

if (mod(N, 2) ~= 0)
    errorString = [ 'Invalid number of arguments: ' ...
        'Missing names or values'];
    error(errorString);
end

input = reshape(varargin, 2, N/2)';

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

if (status == -2)
    error(value);
end
end