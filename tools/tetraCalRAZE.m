% Simplified full calibration.
% asserts a single value for delta radius, arm length, and radial tilt.
% Since both radius and arm-length are calibrated, needs
% a calipration print measurement and/or plate probe
%
% Intended to re-set sanity if you are converging on
% non-physical minima
%
% This calibration MUST have XY measurements
%
%      given bed probe (and print measurement) data
%           R - delta radius
%           A - delta arm length
%           Z - zenith tilt (tilt_radial)
%           E - endstops
%
%  tc  -- tetra calibration data, like from tetraLoadCalData(33,measFile='calMeas033.m')
%            or: tc = tetraLoadCalData(33,[],[],prbe032.log',119.3/120)
%             for bed probe in probe033.log, plate probe in probe032.log,
%                  where printed plate had shrinkage scale error of 119.3/120
%  gp0 -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalRAZE(tc, gpp=[])
    gp = tetraRefineRAZE(tc,gpp);

    if 1
        gp = tetraRefineRAZE(tc,gp.p);  % double check
    else
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
        gpn = tetraRefineRAZE(tc,igp);
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
    end
    
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius      = gp.p.delta_radius;
    up.arm_lengths       = gp.p.arm_lengths;
    up.tilt_radial       = gp.p.tilt_radial;
    tetraWriteUpdateCfg(up,'updateRAZE.cfg',gp.err,gp.RMS,...
                        [tc.bedMedian, tc.bedStDev, tc.probe_offset(2)]);
    system('cat updateRAZE.cfg');
    % pass back everything, just in case
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

