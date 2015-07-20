classdef LaTeXDocument < handle
    %LATEXDOCUMENT A class for creating LaTeX documents
    
    properties (SetAccess = immutable, GetAccess = public)
        % location - File location
        % I.e. the full path to the directory containing the file
        % Can be relative or absolute
        location = '';
        % filename - Filename
        % Only the filename (excluding the '.tex' extension)
        filename = '';
        % path - Full path to file
        % Concatenated location and filename + the '.tex' extension
        path = '';
    end
    
    properties (Access = protected)
        % f - File handle
        % Error code set as default value.
        f = -1;
        % indentDepth - Indent depth
        % This counter variable is used to track the current indent depth
        indentDepth = 0;
        % fileOpened - Flag to check whether the file is currently opened
        fileOpened = false;
    end
    
    
    methods (Access = protected)
        function IndentR(obj)
            % Increase the indent depth (move to the right)
            %
            % See also: INDENTL, INDENTRESET
            obj.indentDepth = obj.indentDepth + 1;
        end
        
        function IndentL(obj)
            % Decrease the indent depth (move to the left)
            %
            % See also: INDENTR, INDENTRESET
            if obj.indentDepth ~= 0
                obj.indentDepth = obj.indentDepth - 1;
            end
        end
        
        function IndentReset(obj)
            % Reset the indent depth (set it to 0)
            %
            % See also: INDENTR, INDENTL
            obj.indentDepth = 0;
        end
    end
    
    methods (Access = public, Static = true)
        function escapedString = EscapeLaTeXChars(str, escChrs, escSubs)
            % Escape special LaTeX characters
            %
            % Following chars will be escaped by default:
            % %, $, #, _, &, {, }, \, ~
            %
            % Inputs:
            %    str       : input string
            %    [escChrs] : cell array with chars to be escaped, optional
            %    [escSubs] : cell array with escaped characters, optional
            %                (must be the same length as 'escChrs')
            %
            % Outputs:
            %    ret       : output string
            %
            % This function was adapted from the function 'escapeString'
            % from Christian
            % http://www.mathworks.de/matlabcentral/fileexchange/
            % authors/257141
            %
            % http://www.mathworks.de/matlabcentral/fileexchange/
            % 41512-escapestring-convert-special-characters-in-a-
            % string-into-their-escape-sequences
            %
            %
            % Code covered by BSD license
            
            escapedString = '';
            
            if nargin == 1
                escChrs = {'%', '$', '#', '_', '&', '{', '}', ...
                    '\', '~'};
                escSubs = {'{\%}', '{\$}', '{\#}', '{\_}', ...
                    '{\&}', '{\{}', '{\}}', '{\textbackslash}', ...
                    '{\textasciitilde}'};
            end
            
            % Disable performance warnings, since performance is not
            % important here
            for i = 1 : 1 : length(str)
                for j = 1 : 1 : length(escChrs)
                    found = false;
                    if str(i) == escChrs{j}
                        escapedString = ...
                            [escapedString, escSubs{j}]; %#ok<AGROW>
                        found = true;
                        break
                    end
                end
                if ~found
                    escapedString = [escapedString, str(i)]; %#ok<AGROW>
                end
            end
        end
        
        function RunPDFLaTeX(fullFilename, varargin)
            % Run 'pdflatex' with specified parameters
            %
            % Notice that the file must be closed before calling this
            % method!
            %
            % Inputs:
            %   fullFilename : the '.tex'-file to be compiled
            %   [varargin]   : optional parameters as key-values. See below
            %                  for available keys.
            %
            % Keys:
            %   num_comp_runs : number of compilation runs, 2 by default
            %   pdflatex_args : 'pdflatex' arguments, default argument:
            %                   '-interaction=batchmode'
            %   debug_mode    : debug mode on or off, use logical value.
            %                   In debug mode, the source code and all
            %                   auxiliary files are not deleted after
            %                   compilation
            %   echo_mode     : if activated (logical value), echoes the
            %                   command line output to the MATLAB command
            %                   window
            
            [texFileLocation, ~, ~] = fileparts(fullFilename);
            texFileLocation = [strrep(texFileLocation, '\', '/'), '/'];
            
            % Run PDFLaTeX several times to resolve all references, 2 by
            % default
            [s, v] = Aux.KeyValueUtils.ExtractValue('num_comp_runs', varargin{:});
            if s == 0
                numComp = v;
            else
                numComp = 2;
            end
            
            % Extract arguments for 'pdflatex'
            [s, v] = Aux.KeyValueUtils.ExtractValue('pdflatex_args', varargin{:});
            if s == 0
                args = v;
            else
                args = ['-output-directory=' texFileLocation ...
                    ' -interaction=batchmode'];
            end
            
            % Extract debug flag, no debug by default
            [s, v] = Aux.KeyValueUtils.ExtractValue('debug_mode', varargin{:});
            if s == 0
                debug = logical(v);
            else
                debug = false;
            end
            
            % Extract echo flag, silent mode by default. If, however,
            % echoing is turned on, then append '-interaction=nonstopmode'
            % to the arguments string. 'pdflatex' will take the latest
            % interaction mode specification, thus enabling some output to
            % the MATLAB Command Window
            [s, v] = Aux.KeyValueUtils.ExtractValue('echo_mode', varargin{:});
            if s == 0
                echo = logical(v);
                args = [args ' -interaction=nonstopmode'];
            else
                echo = false;
            end
            
            % Start compilation
            % Use '[~, ~] = ' to suppress output to MATLAB Command Window
            if echo
                for i = 1 : 1 : numComp
                    fprintf('%i... ', i);
                    [~, ~] = dos(['pdflatex ' args ' ' fullFilename], ...
                        '-echo');
                end
            else
                for i = 1 : 1 : numComp
                    fprintf('%i... ', i);
                    [~, ~] = dos(['pdflatex ' args ' ' fullFilename]);
                end
            end
            
            % Delete the aux files, if no debug mode
            [fPath, fName, ~] = fileparts(fullFilename);
            fPath = strrep(fPath, '\', '/');
            basename = [fPath, '/', fName];
            
            toDelete{1} = [basename '.aux'];
            toDelete{2} = [basename '.out'];
            toDelete{3} = [basename '.log'];
            toDelete{4} = [basename '.tex'];
            toDelete{5} = [basename '.lot'];
            toDelete{6} = [basename '.lof'];
            toDelete{7} = [basename '.toc'];
            
            if ~debug
                for i = 1 : 1 : numel(toDelete)
                    % Notice that the files must be deleted only if they
                    % exist; otherwise, MATLAB throws a warning.
                    if exist(toDelete{i}, 'file')
                        delete(toDelete{i});
                    end
                end
            end
        end
    end
    
    methods
        function obj = LaTeXDocument(fullFilename, varargin)
            % Class constructor
            %
            % Inputs:
            %   fullFilename : filename specification. It can be specified
            %                  as a full absolute or relative path. If only
            %                  the filename is specified, the current
            %                  working directory is used
            %   [varargin]   : arguments passed through to the 'fopen'
            %                  function. Default values: create new or 
            %                  overwrite file, system native machine 
            %                  format, UTF-8 encoding
            %
            % Outputs:
            %   obj           : handle to the constructed object
            %
            % See also: FOPEN
            
            [obj.path, obj.filename, obj.location] = ...
                Aux.FileHandling.FormatFilename(fullFilename, 'tex');
            
            if nargin == 1
                % Use default values
                % permissions:      'w' (create new or overwrite)
                % machineFormat:    'n' (system native)
                % encoding:         'UTF-8'
                obj.f = fopen(obj.path, 'w', 'n', 'UTF-8');
            else
                % If any additional arguments are specified, use them when
                % opening the file
                obj.f = fopen(obj.path, varargin{:});
            end
            
            obj.fileOpened = true;
            
            % Check if the file was created/opened successfully
            if obj.f == -1
                error('Could not create/open file ''%s''', obj.path);
            end
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
                obj.f = fopen(obj.path, 'a');
                obj.fileOpened = true;
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
            
            % Use soft tabs with 3 spaces
            fprintf(obj.f, repmat('   ', 1, num));
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
            % Add a 'Aux.DataTypes.RichTable' object to the document
            %
            % Inputs:
            %   table : handle to a 'RichTable' object
            
            
            % =============================================================
            % Prepare the alignment and column separators string
            % =============================================================
            alignment = '{ ';
            
            for i = 1 : 1 : richTable.numCols
                % We do not really need to pre-allocate this string here,
                % since the number of columns is mostly low and the
                % performance is not worth coding effort
                
                % Set the separator
                if richTable.sepVer(i)
                    alignment = [alignment '| ']; %#ok<AGROW>
                end
                
                % Set the alignment itself
                alignment = [ ...
                    alignment richTable.alignment{i} ' ']; %#ok<AGROW>
            end
            
            % Set the rightmost separator
            if richTable.sepVer(end)
                alignment = [alignment '| '];
            end
            
            alignment =  [alignment '}'];
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
                            pFun = @obj.EscapeLaTeXChars;
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
            %obj.WrtLn('\\renewcommand{\\arraystretch}{%.2f}', obj.conf.arrayStretch);
        end
        
        function ClearPage(obj)
            % Add a clear page command
            obj.WrtLn('\\clearpage');
        end
        
        function Compile(obj, varargin)
            % Compiles the LaTeX document
            %
            % Notice that this method should be run only at the end of the
            % document creation, since it closes and possibly even deletes
            % it
            %
            % Inputs:
            %   [varargin] : optional parameters as key-values. See below
            %                for available keys.
            %
            % Keys:
            %   num_comp_runs : number of compilation runs, 2 by default
            %   pdflatex_args : 'pdflatex' arguments, default argument:
            %                   '-interaction=batchmode'
            %   debug_mode    : debug mode on or off, use logical value.
            %                   In debug mode, the source code and all
            %                   auxiliary files are not deleted after
            %                   compilation
            %   echo_mode     : if activated (logical value), echoes the
            %                   command line output to the MATLAB command
            %                   window
            %
            % See also: AUX.LATEX.LATEXDOCUMENT.RUNPDFLATEX
            
            % Close the file before compiling it
            obj.Close;
            obj.RunPDFLaTeX(obj.path, varargin{:});
        end
    end
end