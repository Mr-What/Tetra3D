% Given a set of measurements of the bed surface,
% and an optional set of calibration print measurements, guess
% a parameter set more likely to explain these distortions.
%
%    PP    -- Full parameters used for the probe, ammended with probe
%             data and [optional] measXY cal print measurement data and truth.
%
%    [IGP] -- Initial Guess Parameters. Configuation parameters for the initial guess.
%             Default is same as PP.
%             In some cases, several refinements may be attempted in series
%             from a single set of probe and measurement data.
%             We may wish to start the search from this refined guess.
%-
function tp = tetraRefineARPZTE(PP,IGP)
    global callCount;
    callCount = 0;  % tetraFitErr() will count number of calls in SimplexMinimize

    % ----- initial data plot
    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);

    % compute internal kinematic parameter representation
    if nargin < 2
        gp = getTetraParams(PP.p);
    else
        gp = getTetraParams(IGP);
    end
    gp.verbose = 0;

    initialGuess = tetraParamVectorARPZTE(gp.p);
    %             arm    radius     angle           rTilt       tTilt         endstop
    initialStep = [.3,  .5,.5,.5,  .5,.5,.5,       .5,.5,.5,  .3,.3,.3,      .3,.3,.3];
    smallBox = [.005, .05,.05,.05, .03,.03,.03,  .04,.04,.04, .03,.03,.03, .005,.005,.005];
    maxIterations=2000;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraARPZTE),...
   	initialGuess, initialStep, smallBox, maxIterations)

    % check results with random perturbation?
    %initialGuess = fit + 0.04 * (rand(1,4)-.5) .* (initialGuess - fit)
    %callCount=0;  % tetraFitErr will count number of calls in SimplexMinimize
    %[fit,nEval,status,err] = SimplexMinimize(...
    %    @(p) tetraFitErr(p,PP,gp,@setTetraRadiusEndstop),...
    %	initialGuess, initialStep*.1, smallBox*.1, maxIterations)
    
    % return refined tetra (tilted) parameter set
    tp = setTetraARPZTE(fit,gp);

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setTetraARPZTE);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setTetraARPZTE(p,igp)
    gp = igp.p;
    gp.arm_lengths = [0,0,0] + p(1);
    gp.delta_radius      = p( 2: 4);
    gp.delta_angles      = p( 5: 7);
    gp.tilt_radial       = p( 8:10);
    gp.tilt_tangential   = p(11:13);
    gp.position_endstops = p(14:16);
    gp = getTetraParams(gp);  % re-build kinematic params
end

function pv = tetraParamVectorARPZTE(p)
    pv = [mean(p.arm_lengths), ...
          p.delta_radius, ...
          p.delta_angles, ...
          p.tilt_radial, ...
          p.tilt_tangential, ...
          p.position_endstops];
    return
end
