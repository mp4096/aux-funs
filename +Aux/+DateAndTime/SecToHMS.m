function hmsString = SecToHMS(t, short)
% Display an time interval measured in seconds in the long/short HMS format
%
% E.g. 102.10 s is equal to '0h 01m 42s 100ms' or '01m 42s 100ms' in the
% short format. In the short format, all zero values are omitted.
%
% Inputs:
%   t         : a vector or a scalar with time specifications in seconds
%   [short]   : output in the short format if true, false by default
%
% Outputs:
%   hmsString : a string or a cell array of strings (if length(t) > 1)
%               containing the formatted time
%
% See also: DATESTR


% Check the inputs and use the long format by default
if nargin == 1
    short = false;
end


    function str = PrintTime(t)
        % Define a nested function for time printing
        
        % Get hours, minutes, seconds and milliseconds
        h = floor(t/3600);
        m = floor((t - h*3600)/60);
        s = floor(t - h*3600 - m*60);
        ms = t - floor(t);
        
        % Print them
        strCell{1} = sprintf('%ih', h);
        strCell{2} = sprintf('%02im', m);
        strCell{3} = sprintf('%02is', s);
        strCell{4} = sprintf('%03ims', round(ms*1000));
        
        % Remove zero values if short output is required
        if short
            strCell([h, m, s, ms] == 0) = [];
        end
        
        % Join the strings (' ' as the default separator)
        str = strjoin(strCell);
    end

% Apply the printing function to the times array
hmsString = arrayfun(@PrintTime, t, 'UniformOutput', false);

% Unpack the cell array if the time input was scalar
if length(t) == 1
    hmsString = hmsString{1};
end
end