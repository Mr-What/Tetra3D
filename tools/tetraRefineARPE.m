% Given a set of measurements of the bed surface,
% and an optional set of calibration print measurements, guess
% a parameter set more likely to explain these distortions.
%
%    PP    -- Full parameters used for the probe, ammended with probe
%             and carriage position data, returned by getProbePositions()
%             and optionally a set of calibration print measurements,
%             and their expected values.
%             We usually store this data as .m code that
%             defines all the measurements, which can be
%             loaded by loadAsStruct(fileName.m)
%
%    [IGP] -- Configuation parameters, for the initial guess.
%             Default is same as PP, but in some cases, where
%             partial optimizations are performed in sequence from
%             a single set of probe data, some of the parameters
%             used in this optimization may not be the same as ones
%             used for the original probe(s).
%-
function tp = tetraRefineARPE(PP,IGP, ...
                              initialStep=[1,1,1,         1,1,1,       1,1,1,          .3,.3,.3], ...
                              smallBox=[.02,.02,.02,   .02,.02,.02,   .04,.04,.04,   .004,.004,.004])
%                                       armLength      towerRadius    towerAngle       endstops
    global callCount;
    callCount = 0;  % tetraFitErr() will count number of calls in SimplexMinimize

    % ----- initial data plot
    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);

    if nargin < 2
        gp = getTetraParams(PP.p);
    else
        gp = getTetraParams(IGP);
    end
    gp.verbose = 0;

    % try to refine full ARPE parameter set 
    callCount=0;  % tetraFitErr will count number of calls in SimplexMinimize
    initialGuess = [gp.p.arm_lengths, gp.p.delta_radius, ...
                    gp.p.delta_angles, gp.p.position_endstops];
    maxIterations=2222;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraARPE),...
   	initialGuess, initialStep*.1, smallBox*.1, maxIterations)
    
    % return refined tetra (tilted) parameter set
    tp = setTetraARPE(fit,gp);

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setTetraARPE);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setTetraARPE(p,igp)
    gp = igp.p;
    gp.arm_lengths       = p(1:3);
    gp.delta_radius      = p(4:6);
    gp.delta_angles      = p(7:9);
    gp.position_endstops = p(10:12);
    gp = getTetraParams(gp);  % re-build kinematic params
end
