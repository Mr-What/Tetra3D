%  since radius and arm length have some correlation,
%    they can balance each other's changes by changing scale,
%    I am reluctant op optimize them together.
%  calA updates arm length and endstops.
%  It seems like endstops move around quite a bit with
% parameter changes.
%     tc       -- tetra calibration data, from tetraLoadCalData(n,...)
%     gp0      -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalAE(tc, gp0=[], measFile=[], measFileIdeal=[])
    gp = tetraRefineAE(tc,gp0);
    
    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.arm_lengths = gp.p.arm_lengths;
    tetraWriteUpdateCfg(up,'updateAE.cfg');
    system('cat updateAE.cfg');
    gp.calData = tc;
end
