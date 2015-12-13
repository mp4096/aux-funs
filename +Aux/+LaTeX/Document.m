classdef Document < Aux.KeyValueUtils.KeyValueMixin
    % A class for creating single LaTeX files
    %
    % See also: AUX.LATEX.PROJECT, AUX.LATEX.ESCAPE
    
    
    % =====================================================================
    % File paths
    % =====================================================================
    properties (SetAccess = immutable, GetAccess = public)
        location = ''; % path to the document folder (rel/abs)
        filename = ''; % document filename without the extension
        fullPath = ''; % full path to document (with the extension)
    end
    % =====================================================================
    
    % =====================================================================
    % Private file handling and indenting properties
    % =====================================================================
    properties (Access = private)
        f = -1;             % file handle, error code by default
        fileOpened = false; % flag for the file status, true if opened
        
        indentDepth = 0;    % indent depth counter
        softTabsLen = 4;    % length of the soft tabs
        
        arrayStretch = 1.4; % default array stretch in the document
    end
    % =====================================================================
    
    
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
            
            % Process the filename specification
            [obj.fullPath, obj.filename, obj.location] = ...
                Aux.FileHandling.FormatFilename(fullFilename, 'tex');
            
            % Set default fopen options
            if nargin == 1
                % permissions:      'w' (create new or overwrite)
                % machineFormat:    'n' (system native)
                % encoding:         'UTF-8'
                fopenOptions = {'w', 'n', 'UTF-8'};
            else
                % If there are any additional options, use them for fopen
                fopenOptions = varargin;
            end
            
            % Open the specified file
            obj.OpenFile(fopenOptions{:})
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
    
    % =====================================================================
    % Private file opening method
    % =====================================================================
    methods (Access = private)
        function OpenFile(obj, varargin)
            % Opens the document file
            %
            % See also: FOPEN
            
            if obj.fileOpened
                % File already opened, do nothing and return
                return
            end
            
            % Open the document file with specified options
            obj.f = fopen(obj.fullPath, varargin{:});
            
            % Check if the file was created/opened successfully
            if obj.f == -1
                error('Could not create/open file ''%s''', obj.fullPath);
            end
            
            % Everything seems to be ok
            obj.fileOpened = true;
        end
    end
    % =====================================================================
    
    % =====================================================================
    % Protected indenting methods
    % =====================================================================
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
    
    % =====================================================================
    % Service and file handling methods
    % =====================================================================
    methods
        function ret = IsOpened(obj)
            % Check if the LaTeX file is opened
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.CLOSE
            
            ret = obj.fileOpened;
        end
        
        function OpenOutsideMATLAB(obj, force)
            % Open the LaTeX document in the standard external program
            % outside MATLAB. If the file is still opened for writing in
            % MATLAB, an error is thrown. If the force flag is specified,
            % the file is closed in MATLAB and opened outside.
            %
            % Input
            %   [force] : force open 
            %
            % See also: ISPC, WINOPEN, OPEN
            
            % Check the arguments. No forced open if no arguments
            % specified. One actually has to store a non-empty char in
            % 'force'. If an empty char is stored, the comparison below
            % also returns an empty char which is not allowed for &&
            if nargin == 1
                force = ' ';
            end
            
            % Check if opened and if forced, throw appropriate errors and
            % warnings
            if (force ~= 'f') && obj.IsOpened
                error(['Cannot open the document outside MATLAB ', ...
                    'while it is still opened for writing!']);
            elseif obj.IsOpened
                obj.Close;
                warning(['The opened file was closed in order to ', ...
                    'open it outside MATLAB. Please reopen it manually.']);
            end
            
            % Depending on whether we're on a PC or not, open the file with
            % an appropriate function
            if ispc
                winopen(obj.fullPath);
            else
                open(obj.fullPath);
            end
        end
        
        function Close(obj)
            % Closes the LaTeX file (if opened)
            %
            % See also: FCLOSE, AUX.LATEX.LATEXDOCUMENT.DELETE
            
            if obj.fileOpened
                % Try to close the file
                try
                    fclose(obj.f);
                    % Change the file status only if fclose was successful
                    obj.fileOpened = false;
                catch
                    error('Could not close file ''%s''!', obj.filename);
                end
            end
        end
        
        function Reopen(obj)
            % Reopens the LaTeX file (if not already opened)
            %
            % See also: FOPEN, AUX.LATEX.LATEXDOCUMENT.CLOSE
            
            obj.OpenFile('a');
        end
    end
    % =====================================================================
    
    % =====================================================================
    % Public low-level file writing methods
    % =====================================================================
    methods
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
            fprintf(obj.f, blanks(obj.softTabsLen*num));
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
    end
    % =====================================================================
    
    % =====================================================================
    % Public high-level writing methods
    % =====================================================================
    methods
        function ListEnv(obj, envType, items)
            % List environment
            %
            % E.g. 'enumerate', 'itemize' or 'description'
            %
            % Input:
            %   envType : environment name (as a string)
            %   items   : items, a Nx1 or Nx2 cell array containing the
            %             items to be set in the list
            
            % Get number of columns and items
            [numItems, numCols] = size(items);
            
            % Begin environment
            obj.BegEnv(envType);
            
            % Select the right printing string
            switch numCols
                case 1
                    prtStr = '\\item %s';
                case 2
                    prtStr = '\\item[%s] %s';
                otherwise
                    error(['This method accepts only Nx1 or ', ...
                        'Nx2 cell arrays!']);
            end
            
            % Print the items. Notice that one may not use cellfun here, as
            % the write order matters!
            for i = 1 : 1 : numItems
                obj.WrtLn(prtStr, items{i, :});
            end
            
            % Close the environment
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
                    error('Invalid depth parameter!');
            end
            
            % Add asterisk if the section should not be added to ToC
            if ~addToToC
                depthName = [depthName, '*'];
            end
            
            % Add two new lines before the new section
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
            colorsBkg = richTable.GetColorsItems('Bkg');
            colorsFrg = richTable.GetColorsItems('Frg');
            
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
                        mode = richTable.modeB;
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
    % =====================================================================
    
    % =====================================================================
    % Set methods
    % =====================================================================
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
            %   val : number of whitespaces in a tab (4 by default)
            
            obj.softTabsLen = val;
        end
    end
    % =====================================================================
end
