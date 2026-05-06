%  optimize delta_radius(3) and endstops given ben probe data
function gp = calR3E(logFile, gpp)
    tp = loadProbeDataFromKlipperLog(logFile);

    % add XY data if you got it
    %tp = appendTowerPositions(tp.p, probe, xyMeas, xyIdeal);

    if nargin > 1
        gp = tetraRefineR3E(tp,gpp)
    else
        gp = tetraRefineR3E(tp)
    end
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    gp = tetraRefineR3E(tp,gp.p,...
                        [1,1,1,.5,.5,.5],
                        [1,1,1,1,1,1]*.004)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    write_tilted_delta_update_cfg(up,'radiusEndstopUpdate.cfg');
    system('cat radiusEndstopUpdate.cfg');
end
