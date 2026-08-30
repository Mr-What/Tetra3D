%  optimize endstops given ben probe data
function [gp,tp] = calE(logFile, gp0=[], measFile=[], measFileIdeal=[])
    if ischar(logFile)
        tp = loadCalData(logFile, measFile, measFileIdeal);
    else
        tp = logFile;  % it was already loaded
    end

    gp = tetraRefineE(tp,gp0);

    up.position_endstops = gp.p.position_endstops;
    write_tilted_delta_update_cfg(up,'updateE.cfg');
    system('cat updateE.cfg');
end
