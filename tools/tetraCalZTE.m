%  optimize tower position and endstops
%      given bed probe (and print measurement) data
%           Z - zenith tilt (tilt_radial)
%           T - tangential_tilt
%           E - endstops
%  tc  -- tetra calibration data, like from tetraLoadCalData(33,...)
%  gp0 -- initial guess at tetra parameters, tc.p is default
function gp = tetraCalZTE(logFile, gpp=[])
    gp = tetraRefineZTE(tp,gpp);

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.tilt_radial       = gp.p.tilt_radial;
    up.tilt_tangential   = gp.p.tilt_tangential;
    tetraWriteUpdateCfg(up,'updateZTE.cfg');
    system(sprintf('echo "# err=%.6f" >> updateZTE.cfg',gp.err));
    system('cat updateZTE.cfg');
    gp.calData=tc;
end
