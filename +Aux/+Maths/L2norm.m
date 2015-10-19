function normVal = L2norm(t, sigData) 
% Function to return the L2 norm of the vector valued signal 'sigData'
%
% Inputs:
%   t       [1 x nSamples]      : timevector
%   sigData [nSamples x nSig]   : matrix, time in the first dimension,
%                                 signal elements in the second dimension 

sqSamples = sum(sigData.^2, 2);
normVal = sqrt(trapz(t, sqSamples));

end