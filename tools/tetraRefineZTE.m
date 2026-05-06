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
%             Default is same as PP.p, but in some cases, where
%             partial optimizations are performed in sequence from
%             a single set of probe data, some of the parameters
%             used in this optimization may not be the same as ones
%             used for the original probe(s).
%-
function tp = tetraRefineZTE(PP,IGP, ...
            initialStep = [.4,.4,.4, .2,.2,.2, .5,.5,.5], ...
            smallBox = ones(1,9) * .0001)
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

    initialGuess = [gp.p.tilt_radial, ...
                    gp.p.tilt_tangential, ...
                    gp.p.position_endstops];
    maxIterations=666;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraZTE),...
   	initialGuess, initialStep, smallBox, maxIterations)

    % check (simulaed annealing)
    %fit1=fit;err1=err;
    %callCount=0;
    %ig = fit + (rand(1,9)-.5) * .1;
    %[fit,nEval,status,err] = SimplexMinimize(...
    %    @(p) tetraFitErr(p,PP,gp,@setTetraRPE),...
    % 	ig, initialStep, smallBox, maxIterations)
    %
    %disp([fit1;fit]);
    %disp([err1,err]);
    
    % return refined tetra (tilted) parameter set
    tp = setTetraZTE(fit,gp);

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setTetraZTE);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setTetraZTE(p,igp)
    gp = igp.p;
    gp.tilt_radial       = p(1:3);
    gp.tilt_tangential   = p(4:6);
    gp.position_endstops = p(7:9);
    gp = getTetraParams(gp);  % re-build kinematic params
end
