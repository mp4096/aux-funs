function normVal = L1norm(sys)
% L1 norm of MIMO transfer function

if ~isstable(sys)
    error('System is not stable, L1 norm does not exist');
end

% Find the slowest mode
if sys.Ts == 0 % is it a continuous time system?
    omegaMin = min(abs(eig(sys)));
else % ... seems it's discrete
    omegaMin = min(abs(log(eig(sys))/sys.Ts));
end

% impulse response up to 100 * biggest time constant
[y, t] = impulse(sys, 100/omegaMin);

% integral of impulse responses absolute value
impInt = trapz(t, abs(y));

% sum
normVal = max(sum(impInt, 3));

end

