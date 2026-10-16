% return a function which will compute the MSE between the weighted
% best fit from given points (and weights) to another
% set of points to be presented to the returned function
function f = tetraPlateFitErrFactory(dimpleIdeal, w)
    w   = w(:) / sum(w);  % make sure weights are normalized
    nb  = w' * dimpleIdeal;
    A   = dimpleIdeal - nb;
    wAx = w .* A(:,1);
    wAy = w .* A(:,2);
    Saa = w' * sum(A.^2, 2);
    f   = @(Mx, My) rigidCostXY(Mx, My, w, wAx, wAy, Saa);
end
