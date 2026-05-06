%  optimize delta_radius and endstops given ben probe data
function gp = calRE(logFile, gp0)
    tp = loadProbeDataFromKlipperLog(logFile);

    % add XY data if you got it
    %tp = appendTowerPositions(tp.p, probe, xyMeas, xyIdeal);
    
    if nargin > 1
        gp = tetraRefineRE(tp,gp0)
    else
        gp = tetraRefineRE(tp)
    end
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    gp = tetraRefineRE(tp,gp.p,[1,1,1,1],[1,1,1,1]*.004)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    write_tilted_delta_update_cfg(up,'updateRE.cfg');
    system('cat updateRE.cfg');
end
