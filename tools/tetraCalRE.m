%  optimize delta_radius and endstops given ben probe data
%     tc       -- tetra calibration data, from tetraLoadCalData(n,...)
%     gp0      -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalRE(tc, gp0=[])
    tp = loadCalData(logFile, measFile, measFileIdeal);
    gp = tetraRefineRE(tp,gp0);
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    gp = tetraRefineRE(tp,gp.p,[1,1,1,1],[1,1,1,1]*.004);

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    tetraWriteUpdateCfg(up,'updateRE.cfg');
    system('cat updateRE.cfg');
end
