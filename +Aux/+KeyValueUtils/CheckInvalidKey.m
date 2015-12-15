function CheckInvalidKey(key, allowedKeys, varargin)
if ~Aux.KeyValueUtils.CheckString(key, allowedKeys)
    if isempty(varargin)
        s = '';
    else
        s = [sprintf(varargin{:}), ' '];
    end
    
    s = [s, sprintf('Unknown key ''%s''. ', key)];
    s = [s, sprintf('Following keys are allowed:\n\t')];
    s = [s, strjoin(sort(allowedKeys), '\n\t')];
    
    error('%s', s);
end
end
