%  optimize endstops given ben probe data
function [gp,tp] = calE(logFile, gp0=[], measFile=[], measFileIdeal=[])
    tp = loadCalData(logFile, measFile, measFileIdeal);
    gp = tetraRefineE(tp,gp0);

    up.position_endstops = gp.p.position_endstops;
    write_tilted_delta_update_cfg(up,'updateE.cfg');
    rem=sprintf('err=%.6f;  bedMed=%.3f;  stDev=%.3f; z0=%.3f',...
                gp.err, tp.bedMedian-tp.probe_offset(3), ...
                tp.bedStDev, tp.probe_offset(3));
    system(['echo "# ',rem,'" >> updateE.cfg']); 
    system('cat updateE.cfg');
end
