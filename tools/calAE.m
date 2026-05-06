%  since radius and arm length have some correlation,
%    they can balance each other's changes by changing scale,
%    I am reluctant op optimize them together.
%  calA updates arm length and endstops.
%  It seems like endstops move around quite a bit with
% parameter changes.
function gp = calAE(logFile, gp0)
    tp = loadProbeDataFromKlipperLog(logFile);

    % add XY data if you got it
    %tp = appendTowerPositions(tp.p, probe, xyMeas, xyIdeal);
    
    if nargin > 1
        gp = tetraRefineAE(tp,gp0)
    else
        gp = tetraRefineAE(tp)
    end
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    gp = tetraRefineAE(tp,gp.p,[1,1,1,1,1,1],[1,1,1,1,1,1]*.001)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.arm_lengths = gp.p.arm_lengths;
    write_tilted_delta_update_cfg(up,'armEndstopUpdate.cfg');
    system('cat armEndstopUpdate.cfg');
end
