function CheckInvalidKey(key, allowedKeys, varargin)
if ~Aux.KeyValueUtils.CheckString(key, allowedKeys)
    if isempty(varargin)
        s = '';
    else
        s = sprintf(varargin{:});
    end
    s = [s sprintf(' Unknown key ''%s''. ', key)];
    s = [s sprintf('Following keys are allowed:\n')];
    for i = 1 : 1 : length(allowedKeys)
        s = [s sprintf('\t%s\n', allowedKeys{i})]; %#ok<AGROW>
    end
    error('%s', s);
end
end