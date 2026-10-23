% Refine estimates of requested parameters
%
%    td    -- Full parameters used for the probe, ammended with probe
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
function tp = tetraRefine(cal,td,IGP=[])
    global tetra;
    tetra.callCount = 0;  % tetraFitErr() will count number of calls in SimplexMinimize
    tetra.callPeriod = cal.callPeriod;

    fprintf(1,'probe_offset=[%.3f,%.3f,%.3f]\n',td.probe_offset);
    
    % ----- initial data plot
    %figure(2); [c,ax,pFit] = plotInitialProbe(td.probe);
    if isempty(IGP)
        gp = tetraGetParams(PP.p);
    else
        gp = tetraGetParams(IGP);
    end
    gp.verbose = 0;
    gp.p.position_endstops
    
    % reset global storage for return of error components
    tetra.RMS.bed = 1;
    tetra.RMS.plate = 1;
    tetra.RMS.meas = 1;

    initialGuess = tetraVget(cal,gp.p);
    randDir=rand(1,length(initialGuess));
    randDir(randDir<.5) = -1;
    randDir(randDir>.4) = 1;
    initialStep = cal.initialStep .* randDir;
    smallBox = cal.smallBox;
    maxIterations=4000;

    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) tetraFitErr(p,cal,td,gp.p),...
   	initialGuess, initialStep, smallBox, maxIterations);
        %@(p) tetraFitErr(p,td,gp,@setTetraRPAZTE),...

    % return refined tetra (tilted) parameter set
    tp = tetraVset(cal,fit,gp.p);
    tp = tetraAppendErrorMetrics(tp,err);
    tp.nEval = nEval;

    % plot parameter fit, retrieve full parameter vector(s)
    [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,cal,td,gp.p);%,@setTetraRPAZTE);
    %pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
    %plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
    %legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
    %hold off

    %figure(3); hold off; c = plotParabolicFit(fm); grid on; xlabel('X');ylabel('Y'); title('Parabolic Fit to simulated points'); hold off
    figure(1); plotProbeFit(td.probe,errZ); hold off;
end
