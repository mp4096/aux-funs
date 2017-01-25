function spFunOut = fncut(spFun, pieceSpan)

% =========================================================================
% Checks
% =========================================================================
if ~strcmp(spFun.form, 'pp')
    error('fncut works only with splines in pp-form');
end
% =========================================================================


% =========================================================================
% Required indices
% =========================================================================
% Pieces indices
piecesIdx = pieceSpan(1):pieceSpan(2);
% Breaks to select
breaksLgx = false(size(spFun.breaks));
breaksLgx([piecesIdx, piecesIdx + 1]) = true;
% Coefs to select
piecesLgx = false([1, numel(spFun.breaks) - 1]);
piecesLgx(piecesIdx) = true;
coefsLgx = logical(kron(piecesLgx', true(spFun.dim, spFun.order)));
% =========================================================================


% =========================================================================
% Cut them out
% =========================================================================
spFunOut.form = 'pp';
spFunOut.breaks = spFun.breaks(breaksLgx);
spFunOut.coefs  = reshape(spFun.coefs(coefsLgx), numel(piecesIdx)*spFun.dim, []);
spFunOut.pieces = numel(piecesIdx);
spFunOut.order = spFun.order;
spFunOut.dim = spFun.dim;
% =========================================================================

end