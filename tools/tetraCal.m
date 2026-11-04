% function gp = tetraCal(id, td, gp0=[], maxTry=2, randomRefine=true)
%
% General tetra calibration.    Configuration  is in tetra.cal
%
% Code for calibration type ID follows this convention:
%     R - delta radii
%     *** P - [DEPRICATED  Keep delta_angles with designed values]
%     A - delta arm length
%     Z - zenith tilt (tilt_radial)
%     T - tangential_tilt
%     *** E - [DEPRICATED]  ALWAYS refine endstop postions
%
% typical call sequence:
%
%      % load data from a calibration plate dimple probe
%      cp = tetraLoadPlateProbe('probe138.log'); % Cal plate Parameters
%
%      % load data from a bed probe, and attach associated calibration plate probe
%      td = tetraLoadCalData('probe136.log',cp);  % (full) Tetra cal Data
%
%      gp = tetraCal('RAZT', td, gp0=[], maxTry=5);  % guess parameters
%
% If you don't have plate probes, skip cp, or let cp=[];
% WARNING: if you do not have plate probes, do not try
%         to calibrate delta_radius (R) and arm_lengths (A) simultaneously.
%
%   id     -- id string, choose from fieldnames(tetra.cal)
%   td     -- Tetra calibnration Data
%   gp0    -- initial guess at tetra parameters, td.p is default
%   maxTry -- repeat optimizing from random offsets near current bset,
%             until we have had maxTry unsuccesful attempts at improvement
%   randomRefine -- false to include best parameters so far in the initial simplex.
function gp = tetraCal(id, td, gp0=[], maxTry=2, randomRefine=true)

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
        igp = gpv(iMin);  % initial guess for next refinement attempt
        if randomRefine
            % initial guess for annealing checks, with random offset
            igp = tetraVoffset(cal,igp);
        end
        gpn = tetraRefine(cal,td,igp);

        n=n+1
        gpv(end+1) = reduceParams(gpn);
        fprintf(1,'err=%.6f ; bedRMS=%.3f;  plateRMS=%.6f;  measRMS=%.3f;\n',...
                gpn.err, gpn.RMS.bed, gpn.RMS.plate, gpn.RMS.meas);
        relErr = (gpn.err - gpv(iMin).err) / gpn.err
        if relErr < 0
            gp=gpv(n);
            iMin=n;
            if relErr < -0.0001
                % this is a better reduction that likely from round-off,
                % so reset the try counter for exit condition from here
                nTry=0;
            else
                % negligible reduction, count it as "no improvement"
                nTry = nTry + 1;
            end
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
    
    gp = gpv(iMin);
    gp.gpv = gpv;  % pass back everything, just in case
    gp.gpvMin=iMin;
    gp.calData = td;
    printMinimaTable(gp,cal);

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up = tetraUpdateParams(cal,gp);
    tetraWriteUpdateCfg(up,gp,td,cal.id);
end

function printMinimaTable(gp, cal)
    for k=1:length(gp.gpv)
        if k==gp.gpvMin
            iterMsg = ' * ';
        else
            iterMsg = sprintf('%3d',k);
        end
        fprintf(1,'%s %8.6f ',iterMsg, gp.gpv(k).err)
        p = tetraVget(cal,gp.gpv(k));
        fprintf(1,' %7.3f',p);
        fprintf(1,'\n');
    end
end

% select the params we need to search on, and metadata
function gp = reduceParams(p)
    gp = tetraExtractCfgParams(p.p);
    gp.err = p.err;
    gp.RMS = p.RMS;
end

function cal_id_usage(id)
    global tetra
    disp(['Calibration type "',id,'" not yet supported.']);
    fn = fieldnames(tetra.cal)
    n = length(fn)
    for k=1:n
        nam=fn{k};
        printCalInfo(tetra.cal.(nam),2);
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
