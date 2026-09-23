%  optimize delta_radius(3), arm-length, and endstops given bed probe data
%     AND xy-measurements.
%  You may get scale problems refining R and A at the same time
%  without XY measurements
%     tc  -- tetra calibration data, from tetraLoadCalData(33,measFile='calMeas033.m')
%     gp0 -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalRAE(logFile, gpp=[], measFile, measFileIdeal=[])
    gp = tetraRefineRAE(tc,gpp);
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    up.arm_lengths = gp.p.arm_lengths;
    tetraWriteUpdateCfg(up,'updateRAE.cfg');
    system('cat updateRAE.cfg');
    gp.calData=tc;  % copy over to make sure you know what data was used
end
