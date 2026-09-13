%  optimize delta_radius and endstops given ben probe data
function gp = calRE(logFile, gp0=[], measFile=[], measFileIdeal=[])
    %tp = loadProbeDataFromKlipperLog(logFile);
    tp = loadCalData(logFile, measFile, measFileIdeal);

    gp = tetraRefineRE(tp,gp0);
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    gp = tetraRefineRE(tp,gp.p,[1,1,1,1],[1,1,1,1]*.004);

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    write_tilted_delta_update_cfg(up,'updateRE.cfg');
    system('cat updateRE.cfg');
end
