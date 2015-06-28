function timestamp = GetTimestamp(timestampFormat)
% Outputs the current time and date in the specified format
%
% Provides a concise interface so that you do not have to remember all that
% date and time formatting string specifications. The time is always in the
% 24h format (no am/pm).
%
% Inputs:
%   timestampFormat : a string specifying the timestamp format. Available
%                     values: {iso}, short, full
%
% Examples:
%   {iso} : 2015-06-28T16:44:46
%   short : 28 June 2015, 16:44
%   full  : Sunday, 28 June 2015, 16:45:06
%
% See also: DATETIME

% Check the input arguments
if nargin == 0
    timestampFormat = 'iso';
end

% Choose the format string
switch timestampFormat
    case 'iso'
        % Date-time format as specified in ISO 8601, see
        % https://en.wikipedia.org/wiki/ISO_8601
        % Date and time are separated with a T
        
        formatString = 'yyyy-mm-ddTHH:MM:SS';
    case 'short'
        formatString = 'dd mmmm yyyy, HH:MM';
    case 'full'
        formatString = 'dddd, dd mmmm yyyy, HH:MM:SS';
    otherwise
        error('Unknown format specification: ''%s''!', ...
            timestampFormat);
end;

timestamp = datestr(now, formatString);
end