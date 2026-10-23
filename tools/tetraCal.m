% General calibration.
% Configuration  is in tetra.cal
%
% Code for calibration type ID follows this convention:
%           R - delta radii
%           P - delta angle
%           A - delta arm length
%           Z - zenith tilt (tilt_radial)
%           T - tangential_tilt
%           E - endstop postions
%
% typical call sequence:
%
%      % load data from a calibration plate dimple probe
%      cp = tetraLoadPlateProbeFromLog('probe138.log'); % Cal plate Parameters
%
%      % load data from a bed probe, and attach associated calibration plate probe
%      td = loadCalData('probe136.log',cp);  % (full) Tetra cal Data
%
%      gp = tetraCal('RPAZTE', td, gp0=[], maxTry=2);  % guess parameters
%
% If you don't have plate probes, skip cp, or let cp=[];
% WARNING: if you do not have plate probes, do not try
%         to calibrate delta_radius and arm_lengths simultaneously.
%
%            depricated --> tetraLoadCalData(33,measFile='calMeas033.m')
%  gp0 -- initial guess at tetra parameters, tc.p is default
%  maxTry -- check with random guesses near minima this many times before retaining best minima
% This calibration MUST have XY measurements
%   id  -- id string, from fieldnames(tetra.cal)
%   td  -- Tetra calibnration Data
%   gp0 -- configuration parameter initial guess (td.p type struct)
%   maxTry -- repeat optimizing from random offsets near current bset,
%             until we have had maxTry unsuccesful attempts at improvement
function gp = tetraCal(id, td, gp0=[], maxTry=2)
    global tetra

    figure(2);
    klipPlotProbes(td.probe,td.logFileName);

    if isfield(tetra.cal,id)
        cal = tetra.cal.(id);
    else
        gp=[];
        cal_id_usage(id);
        return
    end
    printCalInfo(cal);
    tetra.callPeriod = cal.callPeriod;
    gp = tetraRefine(cal,td,gp0);
    pause(1);  % allow plots to render, if any
    
    % do some simulated annealing
    gpv = reduceParams(gp);
    
    iMin = 1;  % index of best guess in vector
    n = 1;  % total number of optimizations attempted
    nTry = 0; % number of tries without improvement found
    while (nTry < maxTry)
        % initial guess for annealing checks, with random offset
        igp = tetraVoffset(cal,gpv(iMin));
        gpn = tetraRefine(cal,td,igp);

        n=n+1
        gpv(end+1) = reduceParams(gpn);
        fprintf(1,'err=%.6f ; bedRMS=%.3f;  plateRMS=%.6f;  measRMS=%.3f;\n',...
                gpn.err, gpn.RMS.bed, gpn.RMS.plate, gpn.RMS.meas);
        if (gpn.err < gpv(iMin).err)
            gp=gpv(n);
            iMin=n;
            nTry=0;
        else
            nTry = nTry + 1;
        end

        f = tetra.plotFlags;
        tetra.plotFlags = 7;
        [pe,peXY,peBad] = tetraPlateErr(td.k,td.calPlate,gpn.k);
        tetra.plotFlags=f;
        figure 2
        tit = [td.logFileName, '   plate:',td.calPlate.plateProbeFile]
        %klipPlotProbes(pp.probe,pp.logFileName);
        tetraPlotBedFitErr(td.probe, td.pos,td.p.position_endstops,gpn);
        xlabel(sprintf('%d) X(mm)',n));
        figure 1
    end
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    gp = gpv(iMin)
    up = tetraUpdateParams(cal,gp)
    tetraWriteUpdateCfg(up,gp,td,cal.id);
    gp.gpv = gpv;  % pass back everything, just in case
    gp.gpvMin=iMin;
    gp.calData = td;
end

% vector of random numbers, uniform from [-hi,hi]
%function v = randv(n, hi=1)
%    v = hi * 2 * (rand(1,n) - 0.5);
%end

% random offset for annealing search
%              deltaRad   delAng  armLen  tiltZ  tiltT  endStop
%             [10,10,10,  2,2,2,  3,3,3,  3,3,3, 1,1,1  4,4,4]/10;
%function p = randomOffset(p0,g=1)
%    p = p0;
%    p.delta_radius      = p.delta_radius      + g*randv(3,1);
%    %p.delta_angles      = p.delta_angles      + g*randv(3,.4);
%    p.arm_lengths       = p.arm_lengths(1)    + g*randv(1,.5) + [0,0,0];
%    p.tilt_radial       = p.tilt_radial       + g*randv(3,.5);
%    p.tilt_tangential   = p.tilt_tangential   + g*randv(3,.5);
%    p.position_endstops = p.position_endstops + g*randv(3,.5);
%end

%function p = extractTetraP(p0)
%    p = randomOffset(p0.p,0);  % copy over RPAZTE
%    p.err = p0.err;
%    p.nEval = p0.nEval;
%    p.RMS = p0.RMS;
%end

% select the params we need to search on, and metadata
function gp = reduceParams(p)
    gp = tetraExtractCfgParams(p.p);
    gp.err = p.err;
    gp.RMS = p.RMS;
end

%function gpv = applyOffset(id,p);
%    gpv = tetraVoffset(id,p.p);
%    gpv.err=p.err;
%    gpv.RMS = p.RMS;
%end

function cal_id_usage(id)
    global tetra
    disp(['Calibration type "',id,'" not yet supported.']);
    fn = fieldnames(tetra.cal);
    n = length(fn);
    for k=1:n
        printCalInfo(tetra.cal.(fn(k)),2);
    end
end

function printCalInfo(cal,fd=1)
    fprintf(fd,'\t%s optimize:\n',cal.id);
    n = length(cal.fields);
    for k=1:n
        s = '';
        fprintf(fd,'\t\t%s',cal.fields{k});
        if sum(cal.scalar==k)
            fprintf(fd,' (scalar)\n');
        else
            fprintf(fd,'\n');
        end
    end
end
