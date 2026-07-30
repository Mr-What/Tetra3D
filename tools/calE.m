%  optimize endstops given ben probe data
function gp = calE(logFile, gp0=[], measFile=[], measFileIdeal=[])
    tp = loadCalData(logFile, measFile, measFileIdeal);
    gp = tetraRefineE(tp,gp0);

    up.position_endstops = gp.p.position_endstops;
    write_tilted_delta_update_cfg(up,'updateE.cfg');
    system('cat updateE.cfg');
end
