% This is a (mostly) full calibration.
% Attempt this only when printer is already fairly well characterized
% This calibration MUST have XY measurements
%
%      given bed probe (and print measurement) data
%           R - delta radii
%           P - delta position angle
%           A - delta arm lengths
%           Z - zenith tilt (tilt_radial)
%           T - tangential_tilt
%           E - endstops
%
%  tc  -- tetra calibration data, like from tetraLoadCalData(33,measFile='calMeas033.m')
%            better: tc = tetraLoadCalData(33,[],[],prbe032.log',119.3/120)
%             for bed probe in probe033.log, plate probe in probt032.log,
%                  where printed plate had shrinkage scale error of 119.3/120
%  gp0 -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalRPAZTE(tc, gpp=[])
    gp = tetraRefineRPAZTE(tc,gpp);

    % do some simulated annealing
    gpv = extractTetraP(gp);
    iMin = 1;  % index of best guess in vector
    n = 1;  % total number of optimizations attempted
    nTry = 0; % number of tries without improvement found
    maxTry = 7; % exit after this many failed tries
    ec = struct('bed',gp.bedRMS,'print',gp.measRMS,'plate',gp.plateRMS); % keep err components for possible analysis
    while (nTry < maxTry)
        % initial guess for annealing checks, with random offset
        igp = randomOffset(gpv(iMin));
        gpn = tetraRefineRPAZTE(tc,igp);
        n=n+1;
        ec(end+1) = struct('bed',gpn.bedRMS,'print',gpn.measRMS,'plate',gpn.plateRMS);
        fprintf(1,'err=%.6f ; bedRMS=%.3f;  plateRMS=%.6f;  measRMS=%.3f;\n',...
                gpn.err, gpn.bedRMS, gpn.plateRMS, gpn.measRMS);
        gpv(end+1) = extractTetraP(gpn);
        if (gpn.err < gpv(iMin).err)
            gp=gpv(n);
            iMin=n;
            nTry=0;
        else
            nTry = nTry + 1;
        end
    end
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    gp = gpv(iMin);
    gp.RMS = ec(iMin);
    up.position_endstops = gp.position_endstops;
    up.delta_radius      = gp.delta_radius;
    up.delta_angles      = gp.delta_angles;
    up.arm_lengths       = gp.arm_lengths;
    up.tilt_radial       = gp.tilt_radial;
    up.tilt_tangential   = gp.tilt_tangential;
    tetraWriteUpdateCfg(up,'update.cfg');
    % using "PROBE RESULTS" (no probe offset) instead of kilpper "Result: at"
    % we no longer need:
    %          ..., tc.bedMedian-tc.probe_offset(3), ...

    remE = sprintf('# RMSE: bed=%.3f; plate=%.3f; meas=%.3f',...
                gp.RMS.bed,gp.RMS.plate,gp.RMS.print);

    rem=sprintf('err=%.6f;  bedMed=%.3f;  stDev=%.3f; z0=%.3f',...
                gp.err, tc.bedMedian, ...
                tc.bedStDev, tc.probe_offset(3));
    system(['echo "',remE,'" >> update.cfg']); 
    system(['echo "# ',rem,'" >> update.cfg']); 
    system('cat update.cfg');
    gp.gpv = gpv;  % pass back everything, just in case
    gp.gpcMin=iMin;
    gp.calData = tc;
end

% vector of random numbers, uniform from [-hi,hi]
function v = randv(n, hi=1)
    v = hi * 2 * (rand(1,n) - 0.5);
end

% random offset for annealing search
%              deltaRad   delAng  armLen  tiltZ  tiltT  endStop
%             [10,10,10,  2,2,2,  3,3,3,  3,3,3, 1,1,1  4,4,4]/10;
function p = randomOffset(p0,g=1)
    p = p0;
    p.delta_radius      = p.delta_radius      + g*randv(3,2);
    p.delta_angles      = p.delta_angles      + g*randv(3,1);
    p.arm_lengths       = p.arm_lengths       + g*randv(3,1);
    p.tilt_radial       = p.tilt_radial       + g*randv(3,1);
    p.tilt_tangential   = p.tilt_tangential   + g*randv(3,.5);
    p.position_endstops = p.position_endstops + g*randv(3,1);
end

function p = extractTetraP(p0)
    p = randomOffset(p0.p,0);  % copy over RPAZTE
    p.err = p0.err;
    p.nEval = p0.nEval;
    p.fitRMSE.bed = p0.bedRMS;
    p.fitRMSE.plate = p0.plateRMS;
    p.fitRMSE.printMeasurement = p0.measRMS;
end

