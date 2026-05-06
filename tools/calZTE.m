%  optimize tower position and endstops
%      given bed probe (and print measurement) data
%           Z - zenith tilt (tilt_radial)
%           T - tangential_tilt
%           E - endstops
function gp = calZTE(logFile, gpp)
    tp = loadProbeDataFromKlipperLog(logFile)

    % if you have XY data, add it to tp:
    %tp = appendTowerPositions(tp.p, probe, xyMeas, xyIdeal);
    
    if nargin > 1
        gp = tetraRefineZTE(tp,gpp)
    else
        gp = tetraRefineZTE(tp)
    end
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    %gp = tetraRefineRPE(tp,gp.p,...
    %                    [1,1,1,.5,.5,.5],
    %                    [1,1,1,1,1,1]*.004)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.tilt_radial       = gp.p.tilt_radial;
    up.tilt_tangential   = gp.p.tilt_tangential;
    write_tilted_delta_update_cfg(up,'tiltEndstopUpdate.cfg');
    system('cat tiltEndstopUpdate.cfg');
end
