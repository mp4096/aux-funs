function CheckInvalidKey(key, allowedKeys, varargin)
if ~Aux.KeyValueUtils.CheckString(key, allowedKeys)
    if isempty(varargin)
        s = '';
    else
        s = [sprintf(varargin{:}), ' '];
    end
    
    s = [s, sprintf('Unknown key ''%s''. ', key)];
    s = [s, sprintf('Following keys are allowed:\n')];
    
    printFun = @(x) sprintf('\t%s\n', x);
    strAllowedKeys = cellfun(printFun, allowedKeys, 'UniformOutput', 0);
    s = [s, strjoin(strAllowedKeys)];
    
    error('%s', s);
end
end