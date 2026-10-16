% Given a set of measurements of the bed surface,
% and an optional set of calibration print measurements, guess
% a parameter set more likely to explain these distortions.
%
%    PP    -- Full parameters used for the probe, ammended with probe
%             and carriage position data, returned by getProbePositions()
%             and optionally a set of calibration print measurements,
%             and their expected values.
%             OR calPlate struct from loading calibration plate probes
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
function tp = tetraRefineRAZE(PP,IGP=[], ...
            initialStep = [3, 3,  2,  3,3,3], ...
            smallBox = [1,1,.1, 1,1,1]/1000)
    global tetra;
    tetra.callCount = 0;  % tetraFitErr() will count number of calls in SimplexMinimize
    tetra.callPeriod = 50;

    fprintf(1,'probe_offset=[%.3f,%.3f,%.3f]\n',PP.probe_offset);
    
    % ----- initial data plot
    figure(2); [c,ax,pFit] = plotInitialProbe(PP.probe);
    if isempty(IGP)
        gp = tetraGetParams(PP.p);
    else
        gp = tetraGetParams(IGP);
    end
    gp.verbose = 0;

    % reset global storage for return of error components
    tetra.bedRMS = 0;
    tetra.plateRMS = 0;
    tetra.measRMS = 0;
    
    initialGuess = [mean(gp.p.delta_radius), ...
                    mean(gp.p.arm_lengths), ...
                    mean(gp.p.tilt_radial), ...
                    gp.p.position_endstops];
    maxIterations=1000;

    randDir=((rand(1,6)<.5) -.5)*2;
    initialStep = initialStep .* randDir;
        
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,PP,gp,@setTetraRAZE),...
   	initialGuess, initialStep, smallBox, maxIterations);

    % return refined tetra (tilted) parameter set
    tp = setTetraRAZE(fit,gp);
    tp.err   = err;
    tp.nEval = nEval;

    % retrieve error components
    tp.RMS.bed   = tetra.bedRMS;
    tp.RMS.plate = tetra.plateRMS;
    tp.RMS.meas  = tetra.measRMS;
    
    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,@setTetraRAZE);
    pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(PP.probe,errZ); hold off;
end

% --- copy parameters from search vector over to kinetic param struct
function gp = setTetraRAZE(p,igp)
    gp = igp.p;
    gp.delta_radius = [0,0,0] + p(1);
    gp.arm_lengths = [0,0,0] + p(2);
    gp.tilt_radial = [0,0,0] + p(3);
    gp.position_endstops = p(4:6);
    gp = tetraGetParams(gp);  % re-build kinematic params
end
