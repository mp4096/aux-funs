function PrintTrim(h, filename, varargin)
% Print from a figure handle and trim the resulting image
%
% Inputs:
% h          : figure handle; current figure if h == -1
% filename   : output filename (with or without extension)
% [varargin] : optional arguments as key-value pairs
%
% See also: PRINT

keys = { ...
    {'PrintType', 'Printing driver, {''png''} or ''pdf'''}, ...
    {'DPI', 'Print resolution in dots per inch, {300}'}, ...
    {'FigureWidth', 'Figure width in mm before trimming, {210}'}, ...
    {'AspectRatio', 'Height to width ratio, {1}'}, ...
    };

% =========================================================================
% Print info in the command window if called without input arguments
% =========================================================================
if nargin == 0
    % If the function was called without any arguments, print a short
    % key-value pairs summary.
    help Aux.FigureOperations.PrintTrim
    
    fprintf('\tAllowed keys:\n')
    % Fun to get length of the first entry
    len1 = @(k) length(k{1});
    % Fun to get maximum length of the first entries
    maxLen1 = @(ks) max(cellfun(len1, ks));
    % Calculate padding for each entry based on the maximum entry length
    padWhitesp = @(k, ks) maxLen1(ks) + 3 - len1(k);
    % Fun to print one key and its description
    sngPrintFun = @(k, ks) ...
        fprintf('\t''%s''%s: %s\n', k{1}, blanks(padWhitesp(k, ks)), k{2});
    % Perform this printing for a cell array
    cwPrintFun = @(ks) cellfun(@(x) sngPrintFun(x, ks), ks);
    cwPrintFun(keys);
    return
end
% =========================================================================


% =========================================================================
% Process the figure handle argument
% =========================================================================
% Check if the figure handle exists. Return otherwise.
if isempty(h)
    error('Cannot print from a non-existing handle!');
end

% Get the current figure if h == -1
if h == -1
    h = gcf;
end

% Compatibility with the new MATLAB gcf format
if ~isnumeric(h) && isfield(h, 'Number')
    h = h.Number;
end
% =========================================================================


% =========================================================================
% Process the filename argument
% =========================================================================
% Remove extension
filename = regexprep(filename, '.(png|pdf)$', '', 'preservecase');
% =========================================================================


% =========================================================================
% Process the optional input arguments
% =========================================================================
% Check if the input keys are allowed
allowedKeys = [keys{:}];
allowedKeys = allowedKeys(1 : 2 : end);
for i = 1 : 2 : length(varargin)
    Aux.KeyValueUtils.CheckInvalidKey(varargin{i}, allowedKeys);
end

% Use standard values if not specified in varargin
dpi = 300;
printType = 'png';
figureWidth = 210; % millimetres
aspectRatio = 1;

% Check and set print type
[s, v] = Aux.KeyValueUtils.ExtractValue('PrintType', varargin{:});
if s == 0
    if ~ischar(v)
        error(['Print type must be specified as a string, either ', ...
            '''png'' or ''pdf''!']);
    end
    
    Aux.KeyValueUtils.CheckInvalidKey( ...
        v, {'png', 'pdf'}, 'Print type specification:');
    printType = v;
end

% Check and set DPI
[s, v] = Aux.KeyValueUtils.ExtractValue('DPI', varargin{:});
if s == 0
    if ~isnumeric(v)
        error('DPI value must be specified as a numeric scalar!');
    elseif v <= 0
        error('DPI value must be strictly positive!');
    end
    
    dpi = v(1);
end

% Check and set the figure width
[s, v] = Aux.KeyValueUtils.ExtractValue('FigureWidth', varargin{:});
if s == 0
    if ~isnumeric(v)
        error('DPI value must be specified as a numeric scalar!');
    elseif v <= 0
        error('DPI value must be strictly positive!');
    end
    
    figureWidth = v;
end

[s, v] = Aux.KeyValueUtils.ExtractValue('AspectRatio', varargin{:});
if s == 0
    aspectRatio = v;
end
% =========================================================================


% =========================================================================
% Set printing properties
% =========================================================================
% Convert millimetres to centimetres
figureWidth = figureWidth/10;

% Set paper size and units
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperSize', [1 aspectRatio].*figureWidth);
set(h, 'PaperPosition', [0 0 1 aspectRatio].*figureWidth);
% =========================================================================


% =========================================================================
% Print
% =========================================================================
switch printType
    case 'pdf'
        filename = [filename '.pdf'];
        print(h, filename, '-dpdf');
        [~, ~] = dos( ...
            sprintf('pdfcrop -margins 0 %s %s', filename, filename));
    case 'png'
        filename = [filename '.png'];
        print(h, filename, '-dpng', sprintf('-r%i', dpi));
        [~, ~] = dos(sprintf('mogrify -trim %s', filename));
end
% =========================================================================
end