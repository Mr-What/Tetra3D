% function to compute MSE after a weighted rigid transform from
% a set of template points to the given simulated or measured points.
% Parameters other than the input points are defoned in
%    tetraPlateFitErrFactory.m
function J = tetraPlateFitErr(Mx, My, w, wAx, wAy, Saa)
    % Mx, My: n x K  (K candidate parameter sets at once; K=1 is fine)
    mx = w' * Mx;   my = w' * My;                       % 1 x K weighted centroids
    Sbb    = w' * (Mx.^2 + My.^2) - mx.^2 - my.^2;
    Sdot   = wAx' * Mx + wAy' * My;
    Scross = wAx' * My - wAy' * Mx;
    J = Sbb + Saa - 2*hypot(Sdot, Scross);          % 1 x K, weighted MSE (mm^2)
end
