%  optimize delta_radius(3), arm-length, and endstops given ben probe data
% AND xy-measurements.
%  You may get scale problems refining R and A at the same time
%  without XY measurements
function gp = calRAE(logFile, gpp=[], measFile, measFileIdeal=[])
    tp = loadCalData(logFile, measFile, measFileIdeal);

    gp = tetraRefineRAE(tp,gpp)
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    up.arm_lengths = gp.p.arm_lengths;
    write_tilted_delta_update_cfg(up,'updateRAE.cfg');
    system('cat updateRAE.cfg');
end
