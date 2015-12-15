classdef (Abstract) KeyValueMixin < handle
    % An abstract class implementing the key-value pairs Set method
    %
    % Example: Suppose you write a new class 'foo' which has some
    % properties that you would like to set using the key-value pair setter
    % method. In this case, you just inherit 'foo' from this mixin and add
    % key-specific hidden setter methods as follows:
    %
    % ```
    % classdef foo < Aux.KeyValueUtils.KeyValueMixin
    %    properties
    %       % some properties ...
    %    end
    %
    %
    %    methods
    %       % some methods ...
    %    end
    %
    %    methods (Hidden) % here come the key-specific setter methods
    %       function Set.example_key1(obj, val)
    %          % do something ...
    %       end
    %    end
    % end
    % ```
    %
    % The property 'allowedKeys' will automatically find this method and
    % thus you can simply use 'obj.Set('example_key1', <some value>)' to
    % call this function.
    %
    % See also: MATLAB.MIXIN.SETGET
    
    properties (Dependent, GetAccess = protected, SetAccess = immutable)
        allowedKeys; % allowed keys, dependent on the methods definition
    end
    
    properties (Constant = true, Access = protected)
        setMethodsPrefix = 'Set.'; % prefix for key-specific Set methods
    end
    
    
    methods
        function Set(obj, varargin)
            % A key-value pair-style setter method
            %
            % Inputs:
            %   obj        : handle to the current object
            %   [varargin] : optional arguments in the key-value pair
            %                format. Prints the list of available keys if
            %                called without arguments
            
            % Store the number of input arguments
            numArgs = length(varargin);
            
            % Print the allowed keys list if called without any arguments
            if numArgs == 0
                fprintf('Set method for the class ''%s''. ', class(obj));
                fprintf('Following keys are allowed:\n\t');
                fprintf(strjoin(obj.allowedKeys, '\n\t'));
                fprintf('\n\n');
                return
            end
            
            % If there are some input arguments, check whether there is an
            % even number of them, else throw an error
            if mod(numArgs, 2) ~= 0
                error( ...
                    'Invalid number of arguments: Missing keys or values');
            end
            
            % Check if each candidate key is within the set of allowed keys
            for i = 1 : 2 : numArgs
                Aux.KeyValueUtils.CheckInvalidKey( ...
                    varargin{i}, obj.allowedKeys, ...
                    sprintf('%s config:', class(obj)));
            end
            
            % Call the individual, key-specific setter methods
            for i = 1 : 2 : numArgs
                obj.([obj.setMethodsPrefix, varargin{i}])(varargin{i + 1});
            end
        end
        
        function val = get.allowedKeys(obj)
            % A dynamic get method for the allowed keys. These are defined
            % by the (child) class method; each one named 'Set.<some key>'
            % counts.
            %
            % Inputs:
            %   obj        : handle to the current object
            
            % Store the metaclass information
            mc = metaclass(obj);
            % Get the method names (also the hidden ones)
            methodNames = {mc.MethodList.Name};
            % Define a regexp that matches the method names which have the
            % set method prefix at the beginning ('Set.' by default).
            expr = ['(?<=^', obj.setMethodsPrefix, ')\w*'];
            % Match to the regexp. Returns a cell array of cell arrays
            val = regexp(methodNames, expr, 'match');
            % Delete elements that had no matches
            val(cellfun('isempty', val)) = [];
            % Expand the remaining nested cell arrays
            val = [val{:}];
            % Sort the resulting cell array of strings
            val = sort(val);
        end
    end
end
