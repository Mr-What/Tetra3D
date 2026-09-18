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
%  meas  -- cal print measurements
%  meas0 -- ideal measurements, variable definitions in MATLAB code format.
function [gp,tp,gpv] = calRPAZTE(logFile, gpp=[], meas=[], meas0=[])
    tp = loadCalData(logFile, meas, meas0);

    gp = tetraRefineRPAZTE(tp,gpp);

    % do some simulated annealing
    gpv = extractTetraP(gp);
    iMin = 1;  % index of best guess in vector
    n = 1;  % total number of optimizations attempted
    nTry = 0; % number of tries without improvement found
    maxTry = 7; % exit after this many failed tries
    while (nTry < maxTry)
        % initial guess for annealing checks, with random offset
        igp = randomOffset(gpv(iMin));
        gpn = tetraRefineRPAZTE(tp,igp);
        n=n+1;
        gpv(n) = extractTetraP(gpn);
        if (gpn.err < gpv(iMin).err)
            gp=gpv(n)
            iMin=n
            nTry=0;
        else
            nTry = nTry + 1
        end
    end
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    iMin
    gp = gpv(iMin);
    up.position_endstops = gp.position_endstops;
    up.delta_radius      = gp.delta_radius;
    up.delta_angles      = gp.delta_angles;
    up.arm_lengths       = gp.arm_lengths;
    up.tilt_radial       = gp.tilt_radial;
    up.tilt_tangential   = gp.tilt_tangential;
    write_tilted_delta_update_cfg(up,'update.cfg');
    rem=sprintf('err=%.6f;  bedMed=%.3f;  stDev=%.3f; z0=%.3f',...
                gp.err, tp.bedMedian-tp.probe_offset(3), ...
                tp.bedStDev, tp.probe_offset(3));
    system(['echo "# ',rem,'" >> update.cfg']); 
    system('cat update.cfg');
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
end

