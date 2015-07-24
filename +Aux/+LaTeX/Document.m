classdef Document < Aux.KeyValueUtils.KeyValueMixin
    % A class for creating LaTeX documents
    
    properties (SetAccess = immutable, GetAccess = public)
        location = ''; % path to the document folder (rel/abs)
        filename = ''; % document filename without the extension
        fullPath = ''; % full path to document (with the extension)
    end
    
    properties (Access = protected)
        f = -1;             % file handle, error code by default
        indentDepth = 0;    % indent depth counter
        fileOpened = false; % flag for the file status, true if opened
        arrayStretch = 1.4; % default array stretch in the document
        softTabsLen = 3;    % length of the soft tabs
    end
    
    
    methods (Access = protected)
        function IndentR(obj)
            % Increase the indent depth (move to the right)
            %
            % See also: AUX.LATEX.DOCUMENT.INDENTL,
            %           AUX.LATEX.DOCUMENT.INDENTRESET
            obj.indentDepth = obj.indentDepth + 1;
        end
        
        function IndentL(obj)
            % Decrease the indent depth (move to the left)
            %
            % See also: AUX.LATEX.DOCUMENT.INDENTR,
            %           AUX.LATEX.DOCUMENT.INDENTRESET
            if obj.indentDepth ~= 0
                obj.indentDepth = obj.indentDepth - 1;
            end
        end
        
        function IndentReset(obj)
            % Reset the indent depth (set it to 0)
            %
            % See also: AUX.LATEX.DOCUMENT.INDENTR,
            % AUX.LATEX.DOCUMENT.INDENTL
            
            obj.indentDepth = 0;
        end
    end
    
    % =====================================================================
    % Constructor and destructor
    % =====================================================================
    methods
        function obj = Document(fullFilename, varargin)
            % Class constructor
            %
            % Inputs:
            %   fullFilename : filename specification. It can be specified
            %                  as a full absolute or relative path. If only
            %                  the filename is specified, the current
            %                  working directory is used.
            %   [varargin]   : arguments passed through to the 'fopen'
            %                  function. Default values: create new or
            %                  overwrite file, system native machine
            %                  format, UTF-8 encoding.
            %
            % Outputs:
            %   obj           : handle to the constructed object
            %
            % See also: FOPEN
            
            [obj.fullPath, obj.filename, obj.location] = ...
                Aux.FileHandling.FormatFilename(fullFilename, 'tex');
            
            if nargin == 1
                % Use default values
                % permissions:      'w' (create new or overwrite)
                % machineFormat:    'n' (system native)
                % encoding:         'UTF-8'
                obj.f = fopen(obj.fullPath, 'w', 'n', 'UTF-8');
            else
                % If any additional arguments are specified, use them when
                % opening the file
                obj.f = fopen(obj.fullPath, varargin{:});
            end
            
            obj.fileOpened = true;
            
            % Check if the file was created/opened successfully
            if obj.f == -1
                error('Could not create/open file ''%s''', obj.fullPath);
            end
        end
        
        function delete(obj)
            % Class destructor
            %
            % Used to close the opened or created file and thus unlock
            % access to it
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.CLOSE, FCLOSE
            
            obj.Close;
        end
    end
    % =====================================================================
    
    methods
        function ret = IsOpened(obj)
            % Check if the file is opened
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.CLOSE
            
            ret = obj.fileOpened;
        end
        
        function Close(obj)
            % Close file (if opened)
            %
            % See also: FCLOSE, AUX.LATEX.LATEXDOCUMENT.DELETE
            
            if obj.fileOpened
                fclose(obj.f);
                obj.fileOpened = false;
            end
        end
        
        function Reopen(obj)
            % Reopen file (if not opened)
            %
            % See also: FOPEN, AUX.LATEX.LATEXDOCUMENT.CLOSE
            
            if ~obj.fileOpened
                obj.f = fopen(obj.fullPath, 'a');
                obj.fileOpened = true;
            end
        end
        
        function NewLn(obj, num)
            % Add a new line
            %
            % Inputs:
            %   [num] : number of new lines to add. Default value: 1
            
            if nargin == 1
                num = 1;
            end
            
            fprintf(obj.f, repmat('\r\n', 1, num));
        end
        
        function PutIndent(obj, num)
            % Put an indent
            %
            % Inputs:
            %   [num] : indent depth. Use the current indent depth
            %           counter value by default
            
            if nargin == 1
                num = obj.indentDepth;
            end
            
            % Use soft tabs as configured
            fprintf(obj.f, repmat(blanks(obj.softTabsLen), 1, num));
        end
        
        function WrtNI(obj, varargin)
            % Write line without indent and without new line at the end
            %
            % Input:
            %   varargin : values that will be passed to the 'fprintf'
            %              method, writing to the current file
            %
            % See also: FPRINTF, AUX.LATEX.LATEXDOCUMENT.WRT,
            %           AUX.LATEX.LATEXDOCUMENT.WRTLN
            
            fprintf(obj.f, varargin{:});
        end
        
        function Wrt(obj, varargin)
            % Write line with indent and without new line at the end
            %
            % Inputs:
            %   varargin : values that will be passed to the 'fprintf'
            %              method, writing to the current file
            %
            % See also: FPRINTF, AUX.LATEX.LATEXDOCUMENT.WRTNI,
            %           AUX.LATEX.LATEXDOCUMENT.WRTLN
            
            obj.PutIndent;
            obj.WrtNI(varargin{:});
        end
        
        function WrtLn(obj, varargin)
            % Write line with indent and with a new line at the end
            %
            % Inputs:
            %   varargin : values that will be passed to the 'fprintf'
            %              method, writing to the file 'obj.f'
            %
            % See also: FPRINTF, AUX.LATEX.LATEXDOCUMENT.WRTNI,
            %           AUX.LATEX.LATEXDOCUMENT.WRT
            
            obj.Wrt(varargin{:});
            obj.NewLn;
        end
        
        function BegEnv(obj, name, params)
            % Begin an environment
            %
            % Inputs:
            %   name     : environment name (to be put in curly brackets)
            %   [params] : environment parameters attached directly after
            %              environment name
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.ENDENV
            
            switch nargin
                case 2
                    obj.WrtLn('\\begin{%s}', name);
                case 3
                    obj.WrtLn('\\begin{%s}%s', name, params);
                otherwise
                    error('Invalid input arguments');
            end
            
            % Increase the indent counter
            obj.IndentR;
        end
        
        function EndEnv(obj, name)
            % End an environment
            %
            % Inputs:
            %   name : environment name (to be put in curly brackets)
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.BEGENV
            
            % Decrease the indent counter
            obj.IndentL;
            obj.WrtLn('\\end{%s}', name);
        end
        
        function ListEnv(obj, envType, items)
            % List environment
            %
            % E.g. 'enumerate', 'itemize' or 'description'
            %
            % Input:
            %   envType : environment name (as a string)
            %   items   : items, a Nx1 or Nx2 cell array containing the
            %             items to be set in the list
            
            
            % Get number of columns
            numCols = size(items, 2);
            
            % Begin environment
            obj.BegEnv(envType);
            
            switch numCols
                case 1
                    printFun = @(i) obj.WrtLn('\\item %s', i);
                    cellfun(printFun, items);
                case 2
                    printFun = @(d, i) obj.WrtLn('\\item[%s] %s', d, i);
                    cellfun(printFun, items{:, 1}, items{:, 2});
                otherwise
                    error(['This method accepts only Nx1 or ' ...
                        'Nx2 cell arrays!']);
            end
            
            % End environment
            obj.EndEnv(envType);
            obj.NewLn;
        end
        
        function NewSectioning(obj, title, depth, addToToC)
            % Add a new sectioning command
            %
            % Inputs:
            %   title      : sectioning title, can be a cell array if a
            %                short title (in square brackets) is needed.
            %                The first element is the full title of the
            %                section, the second element is the short one.
            %   depth      : sectioning depth (see below)
            %   [addToToC] : whether this section should be added to the
            %                table of contents (ToC) -- yes per default
            %
            % Depth types:
            % 0 - chapter
            % 1 - section
            % 2 - subsection
            % 3 - subsubsection
            % 4 - paragraph
            % 5 - subparagraph
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.BEGENV,
            %           AUX.LATEX.LATEXDOCUMENT.ENDENV
            
            % Check the input arguments and set the default value for the
            % addToToC flag
            if nargin == 3
                addToToC = true;
            elseif nargin == 4
                addToToC = logical(addToToC);
            else
                error('Invalid input arguments!');
            end
            
            % Switch depth key
            switch depth
                case 0
                    depthName = 'chapter';
                case 1
                    depthName = 'section';
                case 2
                    depthName = 'subsection';
                case 3
                    depthName = 'subsubsection';
                case 4
                    depthName = 'paragraph';
                case 5
                    depthName = 'subparagraph';
                otherwise
                    error('Invalid depth parameter');
            end
            
            if ~addToToC
                depthName = [depthName '*'];
            end
            
            obj.NewLn(2);
            
            if iscell(title) && (numel(title) == 2)
                % Add a short title and a full one
                obj.WrtLn('\\%s[%s]{%s}', depthName, title{2}, title{1});
            else
                % There is only one title
                obj.WrtLn('\\%s{%s}', depthName, title);
            end
        end
        
        function SpecFontSize(obj, size)
            % Specify font size (from -4 to 5)
            %
            % Input:
            %   size : a scalar from -4 to 5 specifying font size
            
            switch size
                case -4
                    sizeName = 'tiny';
                case -3
                    sizeName = 'scriptsize';
                case -2
                    sizeName = 'footnotesize';
                case -1
                    sizeName = 'small';
                case 0
                    sizeName = 'normalsize';
                case 1
                    sizeName = 'large';
                case 2
                    sizeName = 'Large';
                case 3
                    sizeName = 'LARGE';
                case 4
                    sizeName = 'huge';
                case 5
                    sizeName = 'Huge';
                otherwise
                    error('Invalid font size specification!');
            end
            
            obj.WrtNI('\\%s', sizeName);
        end
        
        function Label(obj, name)
            % Add a label
            %
            % Input:
            %   name : label name
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.CAPTION
            
            obj.WrtLn('\\label{%s}', name);
        end
        
        function PrintColor(obj, name, color)
            % Print a color specification (rgb)
            %
            % Inputs:
            %   name  : color type, e.g. 'cellcolor' or 'color'
            %   color : color specification
            
            obj.WrtNI('\\%s[rgb]{%.2f, %.2f, %.2f}', ...
                name, color(1), color(2), color(3));
        end
        
        function Caption(obj, name)
            % Add a caption
            %
            % Inputs:
            %   name : caption name
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.LABEL
            
            obj.WrtLn('\\caption{%s}', name);
        end
        
        function IncludeGraphics(obj, filename, sizeSpec)
            % Include graphics command. No indent is used!
            %
            % Inputs:
            %   filename   : image filename
            %   [sizeSpec] : size specification
            
            switch nargin
                case 2
                    obj.WrtNI('\\includegraphics{%s}', filename);
                case 3
                    obj.WrtNI('\\includegraphics[%s]{%s}', sizeSpec, ...
                        filename);
                otherwise
                    error('Invalid input arguments');
            end
        end
        
        function AddRichTable(obj, richTable)
            % Add an 'Aux.DataTypes.RichTable' object to the document
            %
            % Inputs:
            %   richTable : handle to a 'RichTable' object
            
            
            % =============================================================
            % Prepare the alignment and column separators string
            % =============================================================
            separators = repmat({''}, 1, richTable.numCols + 1);
            separators(logical(richTable.sepVer)) = {'|'};
            alignment = [separators; richTable.alignment, {''}];
            alignment = ['{', strjoin(alignment(:)), '}'];
            % =============================================================
            
            
            obj.WrtLn('\\renewcommand{\\arraystretch}{%.2f}', ...
                richTable.arrayStretch);
            
            % Start environments
            obj.BegEnv('center');
            obj.BegEnv('longtable', alignment);
            
            
            % =============================================================
            % Print items
            % =============================================================
            colorsBkg = richTable.ColorsItems('Bkg');
            colorsFrg = richTable.ColorsItems('Frg');
            
            for i = 1 : 1 : richTable.numRows
                if richTable.sepHor(i)
                    obj.WrtLn('\\hline');
                end
                
                obj.PutIndent;
                
                for j = 1 : 1 : richTable.numCols
                    obj.SpecFontSize(richTable.fontSize);
                    obj.WrtNI(' ');
                    obj.PrintColor('cellcolor', colorsBkg{i, j});
                    obj.WrtNI(' ');
                    obj.PrintColor('color', colorsFrg{i, j});
                    obj.WrtNI(' ');
                    
                    if j == richTable.numCols
                        printSpec = '%s \\\\\r\n';
                    else
                        printSpec = '%s & ';
                    end
                    
                    if i <= richTable.numRowsH
                        mode = richTable.modeH;
                    else
                        mode = richTable.modeT;
                    end
                    
                    switch mode
                        case 'normal'
                            pFun = @(s) s;
                        case 'verbatim'
                            pFun = @(s) ['\verb|', s, '|'];
                        case 'escape'
                            pFun = @Aux.LaTeX.Escape;
                    end
                    
                    obj.WrtNI(printSpec, pFun(richTable.items{i, j}));
                end
            end
            
            if richTable.sepHor(end)
                obj.WrtLn('\\hline');
            end
            % =============================================================
            
            if ~isempty(richTable.caption)
                obj.Caption(richTable.caption);
            end
            
            if ~isempty(richTable.label)
                obj.Label(['tab:' richTable.label]);
            end
            
            obj.EndEnv('longtable');
            obj.EndEnv('center');
            obj.WrtLn('\\renewcommand{\\arraystretch}{%.2f}', ...
                obj.arrayStretch);
        end
        
        function ClearPage(obj)
            % Add a clear page command
            obj.WrtLn('\\clearpage');
        end
    end
    
    methods (Hidden)
        function Set.array_stretch(obj, val)
            % Configure the array stretch value in the document
            % 
            % Inputs:
            %   val : array stretch in relative units (1.4 by default)
            
            obj.arrayStretch = val;
        end
        
        function Set.soft_tabs_length(obj, val)
            % Configure the soft tabs lengths
            % 
            % Inputs:
            %   val : number of whitespaces in a tab (3 by default)
            
            obj.softTabsLen = val;
        end
    end
end