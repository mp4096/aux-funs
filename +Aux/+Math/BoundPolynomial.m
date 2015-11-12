classdef BoundPolynomial < handle
    
    properties (GetAccess = protected, SetAccess = protected)
        stateValue;
        derivOrder;
        boundValue;
        
        numBounds;
    end
    
    properties (GetAccess = public, SetAccess = immutable)
        n;
    end
    
    properties (GetAccess = protected, SetAccess = immutable)
        diffCoeffs;
    end
    
    
    % Constructor
    methods
        function obj = BoundPolynomial(polynomialDegree)
            obj.n = polynomialDegree;
            
            % Some really funky stuff
            obj.diffCoeffs = abs(bsxfun(@times, ...
                pascal(obj.n + 1, 2), ...
                arrayfun(@factorial, 0 : 1 : obj.n)'));
            
            obj.stateValue = [];
            obj.derivOrder = [];
            obj.boundValue = [];
            
            obj.numBounds = 0;
        end
    end
    
    methods
        function AddConstraint(obj, derivVal, stateVal, boundVal)
            % Add a check for the derivative order
            
            obj.derivOrder = [obj.derivOrder; derivVal];
            obj.stateValue = [obj.stateValue; stateVal];
            obj.boundValue = [obj.boundValue; boundVal];
            
            obj.numBounds = obj.numBounds + 1;
        end
        
        function [coeffVec, solverMsg] = GetNumCoeff(obj)
            A = zeros(obj.numBounds, obj.n + 1);
            
            for i = 1 : 1 : obj.numBounds
                A(i, :) = CalcOneRow(obj.derivOrder(i), obj.stateValue(i));
            end
            
            b = obj.boundValue;
            
            rankA = rank(A);
            rankAb = rank([A, b]);
            
            if (rankA == rankAb) && (rankA == obj.n + 1)
                solverMsg = sprintf('Unique solution found!');
                
                coeffVec = linsolve(A, obj.boundValue);
            else
                solverMsg = ['Polynomial seems to be over- or ', ...
                    'underconstrained, or the constaints are ', ...
                    'inconsistent. Solution estimated using ', ...
                    'a pseudoinverse.'];
                
                coeffVec = pinv(A)*b;
            end
            
            coeffVec = reshape(coeffVec, 1, []);
            
            function row = CalcOneRow(d, x)
                row = bsxfun(@power, x, (obj.n - d) : -1 : 0);
                row = [row, zeros(1, d)];
                row = row.*obj.diffCoeffs(d + 1, :);
            end
        end
    end
    
    % Disp function
    methods
        function disp(obj)
            fprintf('\n''BoundPolynomial'' object:\n');
            fprintf('\tPolynomial degree: %i\n', obj.n);
            
            printFun = @(k, x, b) sprintf('D_%i p(%.4f) = %.4f', k, x, b);
            
            if obj.numBounds == 0
                fprintf('\tNo constraints specified.\n');
            else
                fprintf('\n\tSpecified constraints:\n');
                for i = 1 : 1 : obj.numBounds
                    fprintf('\t%i: %s\n', i, printFun( ...
                        obj.derivOrder(i), ...
                        obj.stateValue(i), ...
                        obj.boundValue(i)));
                end
                
                [coeffs, solverMsg] = obj.GetNumCoeff;
                fprintf('\n\t%s\n', solverMsg);
                
                fprintf('\n\tCurrent coefficients estimate:\n');
                disp(coeffs);
            end
            
            fprintf('\n');
        end
    end
end