classdef RichTable < Aux.KeyValueUtils.KeyValueMixin
    % A class for creating tables with rich functionality
    %
    % This class is intended to be used with the 'Aux.LaTeX.Document' class
    % to set larger, formatted tables with colors
    %
    % See also: AUX.LATEX.DOCUMENT
    
    
    properties (GetAccess = public, SetAccess = private)
        % table - Cell array containing the table contents
        table;
        % header - Header with columns' captions (also a cell array)
        header;
        % items - Header and table together
        items;
        
        caption;
        label;
        
        fontSize;
        
        % colorsBkgB - Background colors of the table, cell array
        % Size same to 'table'
        colorsBkgB;
        % colorsFrgB - Foreground colors of the table, cell array
        % Size same to 'table'
        colorsFrgB;
        % colorsBkgH - Background colors of the header, cell array
        % Size same to 'header'
        colorsBkgH;
        % colorsFrgH - Foreground colors of the header, cell array
        % Size same to 'header'
        colorsFrgH;
        
        
        % sepHor - Horizontal separators
        % Column vector with size(header, 1) + size(table, 1) + 1 elements
        % 'false' for no separators, 'true' for one line
        sepHor;
        % sepVer - Vertical separators
        % Row vector with numCols + 1 elements
        % 'false' for no separators, 'true' for one line
        sepVer;
        
        % alignment - Horizontal alingment of cell content
        % Row cell array with numCols elements
        alignment;
        
        numRows;
        numRowsB;
        numRowsH;
        numCols;
        
        modeH;
        modeB;
        
        arrayStretch;
    end
    
    
    methods
        function obj = RichTable(header, body)
            if size(header, 2) ~= size(body, 2)
                error('Header and table must be the same size!');
            end
            
            obj.header = header;
            obj.table = body;
            obj.items = vertcat(header, body);
            
            obj.caption = '';
            obj.label = '';
            
            obj.modeH = 'normal';
            obj.modeB = 'normal';
            
            obj.fontSize = 0;
            
            obj.numCols = size(obj.header, 2);
            
            obj.numRowsH = size(obj.header, 1);
            obj.numRowsB = size(obj.table, 1);
            obj.numRows = obj.numRowsH + obj.numRowsB;
            
            % Initialise the background to white
            obj.colorsBkgH = cell(size(obj.header));
            obj.colorsBkgH(:) = {[1, 1, 1]};
            % Initialise the foreground to black
            obj.colorsFrgH = cell(size(obj.header));
            obj.colorsFrgH(:) = {[0, 0, 0]};
            
            % Initialise the background to white
            obj.colorsBkgB = cell(size(obj.table));
            obj.colorsBkgB(:) = {[1, 1, 1]};
            % Initialise the foreground to black
            obj.colorsFrgB = cell(size(obj.table));
            obj.colorsFrgB(:) = {[0, 0, 0]};
            
            obj.sepHor = false(obj.numRows + 1, 1);
            obj.sepVer = false(1, obj.numCols + 1);
            obj.alignment = cell(1, obj.numCols);
            obj.alignment(:) = {'l'};
            
            obj.arrayStretch = 1;
        end
        
        function colors = GetColorsItems(obj, type)
            switch type
                case 'Frg'
                    colors = vertcat(obj.colorsFrgH, obj.colorsFrgB);
                case 'Bkg'
                    colors = vertcat(obj.colorsBkgH, obj.colorsBkgB);
                otherwise
                    error('Invalid type specification ''%s''!', type);
            end
        end
        
        function AssignHorizontalSeparators(obj, type, pos, spec)
            if nargin < 2
                error('Insufficient input arguments!');
            end
            
            if (nargin ~= 4) && strcmp(type, 'single')
                error(['Invalid input arguments for ' ...
                    'single separator specification!']);
            end
            
            switch type
                case 'all'
                    obj.sepHor(:) = true;
                case 'none'
                    obj.sepHor(:) = false;
                case 'standard'
                    obj.sepHor(:) = false;
                    obj.sepHor(1) = true;
                    obj.sepHor(obj.numRowsH + 1) = true;
                    obj.sepHor(end) = true;
                case 'single'
                    if (pos < 1) || (pos > (obj.numRows + 1))
                        error('Separator position out of bounds!');
                    end
                    obj.sepHor(pos) = logical(spec);
                otherwise
                    error('Invalid type specification ''%s''!', type);
            end
        end
        
        function AssignVerticalSeparators(obj, type, pos, spec)
            if nargin < 2
                error('Insufficient input arguments!');
            end
            
            if (nargin ~= 4) && strcmp(type, 'single')
                error(['Invalid input arguments for ' ...
                    'single separator specification!']);
            end
            
            switch type
                case 'all'
                    obj.sepVer(:) = true;
                case 'none'
                    obj.sepVer(:) = false;
                case 'first column'
                    obj.sepVer(:) = false;
                    obj.sepVer(2) = true;
                case 'single'
                    if (pos < 1) || (pos > (obj.numCols + 1))
                        error('Separator position out of bounds!');
                    end
                    obj.sepVer(pos) = logical(spec);
                otherwise
                    error('Invalid type specification ''%s''!', type);
            end
        end
        
        function AssignColorSingleCell(obj, type, row, column, color)
            % Check if the input array is a color specification
            if ~Aux.General.Colors.ValidColor(color)
                error('Invalid color specification!');
            end
            
            % Check if the indices are in range
            switch type(end)
                case 'H'
                    rowsLimit = obj.numRowsH;
                case 'B'
                    rowsLimit = obj.numRowsB;
                otherwise
                    error('Invalid type specification: ''%s''!', type);
            end
            
            if (row < 1) || (row > rowsLimit)
                error('Row index is out of range!');
            end
            
            if (column < 1) || (column > obj.numCols)
                error('Column index is out of range!');
            end
            
            % Assign this color to the cell
            switch type
                case 'BkgH'
                    obj.colorsBkgH{row, column} = color;
                case 'FrgH'
                    obj.colorsFrgH{row, column} = color;
                case 'BkgB'
                    obj.colorsBkgB{row, column} = color;
                case 'FrgB'
                    obj.colorsFrgB{row, column} = color;
                otherwise
                    error('Invalid type specification: ''%s''!', type);
            end
        end
        
        function AssignColorScheme(obj, type, colorScheme)
            % Check if the input array is a color specification
            if ~Aux.General.Colors.ValidColor(colorScheme)
                error('Invalid colormap specification!');
            end
            
            switch type(end)
                case 'H'
                    colormapRows = Aux.General.Colors.ReplicateCmap( ...
                        colorScheme, obj.numRowsH);
                case 'B'
                    colormapRows = Aux.General.Colors.ReplicateCmap( ...
                        colorScheme, obj.numRowsB);
                otherwise
                    error('Invalid type specification: ''%s''!', type);
            end
            
            % Save the color information to the background colors
            % array
            switch type
                case 'BkgH'
                    for i = 1 : 1 : obj.numRowsH
                        obj.colorsBkgH(i, :) = {colormapRows(i, :)};
                    end
                case 'FrgH'
                    for i = 1 : 1 : obj.numRowsH
                        obj.colorsFrgH(i, :) = {colormapRows(i, :)};
                    end
                case 'BkgB'
                    for i = 1 : 1 : obj.numRowsB
                        obj.colorsBkgB(i, :) = {colormapRows(i, :)};
                    end
                case 'FrgB'
                    for i = 1 : 1 : obj.numRowsB
                        obj.colorsFrgB(i, :) = {colormapRows(i, :)};
                    end
                otherwise
                    error('Invalid type specification: ''%s''!', type);
            end
        end
    end
    
    methods (Hidden)
        function Set.alignment(obj, val)
            if iscell(val) && ...
                    (size(val, 1) == 1) && (size(val, 2) == obj.numCols)
                obj.alignment = val;
            else
                error('Invalid alignment specification!');
            end
        end
        
        function Set.caption(obj, val)
            obj.caption = Aux.KeyValueUtils.FormString(val);
        end
        
        function Set.label(obj, val)
            obj.label = Aux.KeyValueUtils.FormString(val);
        end
        
        function Set.mode_body(obj, val)
            allowedKeys = {'escape', 'verbatim', 'normal'};
            Aux.KeyValueUtils.CheckInvalidKey(val, allowedKeys, ...
                'Error while specifying table body parsing mode:');
            obj.modeB = val;
        end
        
        function Set.mode_header(obj, val)
            allowedKeys = {'escape', 'verbatim', 'normal'};
            Aux.KeyValueUtils.CheckInvalidKey(val, allowedKeys, ...
                'Error while specifying table header parsing mode:');
            obj.modeH = val;
        end
        
        function Set.font_size(obj, val)
            if (val < -4) || (val > 5)
                error('Invalid size specification!');
            end
            obj.fontSize = val;
        end
        
        function Set.line_stretch(obj, val)
            obj.arrayStretch = val;
        end
    end
end