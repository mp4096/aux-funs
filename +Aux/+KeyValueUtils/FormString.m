function out = FormString(in)
if iscell(in)
    out = sprintf(in{:});
else
    out = in;
end
end