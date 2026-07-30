% Given a set of measurements of the bed surface,
% AND a set of calibration print measurements, guess
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
%             Default is same as PP.p, but in some cases, where
%             partial optimizations are performed in sequence from
%             a single set of probe data, some of the parameters
%             used in this optimization may not be the same as ones
%             used for the original probe(s).
%-
function tp = tetraRefineRAE(PP,IGP=[], ...
                            initialStep = ones(9,1)*.5, ...
                            smallBox = ones(9,1)*.002)
    global tetra;
    tetra.callCount = 0;  % tetraFitErr() will count number of calls in SimplexMinimize

    % ----- initial data plot
    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);

    if isempty(IGP)
        gp = getTetraParams(PP.p);
    else
        gp = getTetraParams(IGP);
    end
    gp.verbose = 0;

    initialGuess = [gp.p.delta_radius, gp.p.arm_lengths, gp.p.position_endstops]
    maxIterations=666;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setRAE),...
   	initialGuess, initialStep, smallBox, maxIterations)

    % return refined tetra (tilted) parameter set
    tp = setRAE(fit,gp);

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setRAE);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setRAE(p,igp)
    gp = igp.p;
    gp.delta_radius = p(1:3);
    gp.delta_arm_lengths = p(4:6);
    gp.position_endstops = p(7:9);
    gp = getTetraParams(gp);  % re-build kinematic params
end
