function PrintTrim(h, filename, varargin)
% Print from a figure handle and trim the resulting image
%
% Inputs:
% h          : figure handle; current figure if h == -1
% filename   : output filename (with or without extension)
% [varargin] : optional arguments as key-value pairs
%
% See also: PRINT
%


% =========================================================================
% Define optional keys, their default values and validation functions
% =========================================================================
% Key name -- Key description -- Default value -- Validation function
keys(1, :) = { ...
    'PrintType', ...
    'Printing driver, {''png''} or ''pdf''', ...
    'png', ...
    @CheckPrintType, ...
    };

allowedPrintTypes = {'png', 'pdf'};

keys(2, :) = { ...
    'DPI', ...
    'Print resolution in dots per inch, {300}', ...
    300, ...
    @CheckDPI, ...
    };

keys(3, :) = { ...
    'FigureWidth', ...
    'Figure width in mm before trimming, {210}', ...
    210, ...
    @CheckFigureWidth, ...
    };

keys(4, :) = { ...
    'AspectRatio', ...
    'Height to width ratio, {1}', ...
    1, ...
    @CheckAspectRatio, ...
    };
% =========================================================================


% =========================================================================
% Create the input parser and parse optional inputs
% =========================================================================
p = inputParser;
p.FunctionName = 'Aux.FigureOperations.PrintTrim';

for k = keys'
    p.addParameter(k{1}, k{3}, k{4});
end

p.parse(varargin{:});
% =========================================================================


% =========================================================================
% Print info in the command window if called without input arguments
% =========================================================================
if nargin == 0
    PrintHelp();
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
filename = regexprep(filename, '\.(png|pdf)$', '', 'preservecase');
% =========================================================================


% =========================================================================
% Set printing properties
% =========================================================================
% Store parsing results
dpi = p.Results.DPI;
% `validatestring` required for partial specifications
printType = validatestring(p.Results.PrintType, allowedPrintTypes);
figureWidth = p.Results.FigureWidth; % millimetres
aspectRatio = p.Results.AspectRatio;

% Convert millimetres to centimetres
figureWidth = figureWidth/10;

% Set paper size and units
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperSize', [1, aspectRatio].*figureWidth);
set(h, 'PaperPosition', [0, 0, 1, aspectRatio].*figureWidth);
% =========================================================================


% =========================================================================
% Print figure
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


% =========================================================================
% Helper functions
% =========================================================================
    function PrintHelp()
        % Print help header
        help Aux.FigureOperations.PrintTrim
        
        % Print allowed keys
        fprintf('  Allowed keys:\n')
        % Get maximum length of the first entries
        maxKeyLen = max(cellfun('length', keys(:, 1)));
        % Calculate padding for each entry based on the maximum length
        padWs = @(k) blanks(maxKeyLen + 3 - length(k));
        % Fun to print one key and its description
        printFun = @(k, d) fprintf('\t''%s''%s: %s\n', k, padWs(k), d);
        % Perform this printing for a cell array
        cellfun(printFun, keys(:, 1), keys(:, 2));
        
        fprintf('\n')
    end

    function CheckPrintType(val)
        validatestring(val, allowedPrintTypes, ...
            'Aux.FigureOperations.PrintTrim', 'PrintType');
    end

    function CheckDPI(val)
        if ~isnumeric(val)
            error('DPI value must be specified as a numeric scalar!');
        elseif val <= 0
            error('DPI value must be strictly positive!');
        end
    end

    function CheckFigureWidth(val)
        if ~isnumeric(val)
            error('Figure width must be specified as a numeric scalar!');
        elseif val <= 0
            error('Figure width must be strictly positive!');
        end
    end

    function CheckAspectRatio(val)
        if ~isnumeric(val)
            error('Aspect ratio must be specified as a numeric scalar!');
        elseif val <= 0
            error('Aspect ratio must be strictly positive!');
        end
    end
% =========================================================================
end
