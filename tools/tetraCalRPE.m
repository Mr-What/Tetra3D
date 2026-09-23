%  optimize tower position and endstops
%      given bed probe (and print measurement) data
%           R - delta_radius
%           P - delta_angle
%           E - endstops
%  tc  -- tetra calibration data, from tetraLoadCalData(33,...)
%  gp0 -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalRPE(tc, gpp=[])
    gp = tetraRefineRPE(tp,gpp);
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    up.delta_angles = gp.p.delta_angles;
    tetraWriteUpdateCfg(up,'updateRPE.cfg');
    system(sprintf('echo "# err=%.6f" >> updateRPE.cfg',gp.err));
    system('cat updateRPE.cfg');
    gp.calData=tc;
end
