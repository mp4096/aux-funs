% =====================================================================
% Setup
% =====================================================================
N = 3;
xScale = 1;
% Get a random downdate vector
x = xScale*(rand(N, 1) - 0.5).*(10.^((rand(N, 1) - 0.5)));
% Create a positive definite diagonal matrix
positiveEigs = 10.^sum(rand(N, 3)*diag([10, 1, 0.1]), 2);
Lambda = abs(diag(positiveEigs));
% =====================================================================


% =====================================================================
% Computations
% =====================================================================
% Get a random orthonormal matrix
[Q, ~] = qr(rand(N));
% Get a random s.p.d. matrix
P = Q'*Lambda*Q;
% Cholesky 
W = chol(P);
% =====================================================================