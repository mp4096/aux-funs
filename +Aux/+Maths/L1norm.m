function normVal = L1norm(sys)
% L1 norm of MIMO transfer function (Peak to peak)
% for the definition of the L1 norm, see nonlinear flight control lectures
% Mathematical preliminaries: page 66 

if ~isstable(tf(sys))
    error('System is not input/output stable, L1 norm does not exist');
end

% Find the slowest mode
if sys.Ts == 0 % is it a continuous time system?
    omegaMin = min(abs(eig(sys)));
    omegaMax = max(abs(eig(sys)));
else % ... seems it's discrete
    omegaMin = min(abs(log(eig(sys))/sys.Ts));
    omegaMax = max(abs(log(eig(sys))/sys.Ts));
end

% impulse response up to 100 * biggest time constant
dT = 1e-3 / omegaMax;
t = 0:dT:100/omegaMin; 
[y, t] = impulse(sys, t);

% integral of impulse responses absolute value
impInt = trapz(t, abs(y));

% sum
normVal = max(sum(impInt, 3));

end

