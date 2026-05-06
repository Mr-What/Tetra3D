%  optimize tower position and endstops
%      given bed probe (and print measurement) data
%           R - delta_radius
%           P - delta_angle
%           E - endstops
function gp = calRPE(logFile, gpp)
    tp = loadProbeDataFromKlipperLog(logFile)

    % if you have XY data, add it to tp:
    %tp = appendTowerPositions(tp.p, probe, xyMeas, xyIdeal);
    
    if nargin > 1
        gp = tetraRefineRPE(tp,gpp)
    else
        gp = tetraRefineRPE(tp)
    end
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    %gp = tetraRefineRPE(tp,gp.p,...
    %                    [1,1,1,.5,.5,.5],
    %                    [1,1,1,1,1,1]*.004)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    up.delta_angles = gp.p.delta_angles;
    write_tilted_delta_update_cfg(up,'radiusTowerPositionEndstopUpdate.cfg');
    system('cat radiusTowerPositionEndstopUpdate.cfg');
end
