% Given a set of measurements on the bed surface, guess
% the tower endstop errors that are most
% likely to have caused this distortion.
%
% PP are full tilted delta probe parameters as returned by getTetraParams(),
%    which were being used when the included probe results were measured.
%    These (n,3) probe commands when probe was triggered are included
%    along with the parameters.
% [IGP] -- optional Initial Guess Parameters to seed the search.  Default == PP.
%            We may want to implement a piecewise approach to finding
%            parameters, so that the initial guess may not be the
%            parameters used when the probe was measured.
%
%    probe is (n,3) where columns are bed probe returns:
%       Commanded X, commanded Y, Z-probe 
function tp = tetraRefineE(PP,IGP=[], ...
                           initialStep=[.5,.5,.5], ...
                          smallBox = [.003, .003, .003])
    global tetra;
    tetra.callCount = 0;

      % ----- initial data plot
    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);

    if isempty(IGP)
        gp = getTetraParams(PP.p);
    else
        gp = getTetraParams(IGP);
    end
    gp.verbose = 0;

    initialGuess = gp.p.position_endstops;
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraE),...
        initialGuess, initialStep, smallBox, maxIterations)

    % return refined tetra (tilted) parameter set
    tp = setTetraE(fit,gp);

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ] = plotTetraFit(fit,PP,gp,@setTetraE);

    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end
% ---------- copy parameter vector into fields of parameter structure
function gp = setTetraE(p,igp)
    gp = igp.p;
    gp.position_endstops = p;
    gp = getTetraParams(gp);  % re-build kinematic parameters
end
