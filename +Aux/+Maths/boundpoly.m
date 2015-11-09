classdef boundpoly < handle
    properties
        nOrder;
        symCoeff;
        symPoly;
        symState;
        boundsLeft;
        boundsRight;
        numCoeff;
        boundEqn;
    end
    methods
        function obj = boundpoly(nOrder)
            obj.nOrder = nOrder;
            obj.symCoeff = sym('symCoeff', [1, nOrder + 1]);       
            obj.symPoly  = sym('symPoly', [1, nOrder + 1]);
            obj.symState = sym('symState', [1, 1]);
                        
            % Define polynom
            obj.symPoly(1) = obj.symCoeff(1);
            for i = 1 : obj.nOrder
                obj.symPoly(1) = obj.symPoly(1) + ...
                    obj.symCoeff(i + 1)*obj.symState.^(i);
            end
            % define derivatives
            for i = 2 : obj.nOrder + 1
                obj.symPoly(i) = diff(obj.symPoly(i - 1), obj.symState);
            end
        end
    
        function AddBound(obj, derivVal, stateVal, boundVal)
            obj.boundEqn = [obj.boundEqn, (subs(obj.symPoly(derivVal + 1), ...
                obj.symState, stateVal) == boundVal)];            
        end
        
        function coeffVec = GetNumCoeff(obj)
            symSol = solve(obj.boundEqn, obj.symCoeff);
            symSolFields = fieldnames(symSol);
            coeffVec = zeros(1, obj.nOrder + 1);
            for i = 1 : (obj.nOrder + 1)
                coeffVec(obj.nOrder + 2 - i) = vpa(symSol.(symSolFields{i}));
            end
        end
    end
end