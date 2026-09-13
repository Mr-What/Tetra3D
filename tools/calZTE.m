%  optimize tower position and endstops
%      given bed probe (and print measurement) data
%           Z - zenith tilt (tilt_radial)
%           T - tangential_tilt
%           E - endstops
%  meas  -- cal print measurements
%  meas0 -- ideal measurements, variable definitions in MATLAB code format.
function gp = calZTE(logFile, gpp=[], meas=[], meas0=[])
    if ischar(logFile)
        tp = loadCalData(logFile, meas, meas0);
    else
        tp = logFile;  % it was already loaded
    end


    gp = tetraRefineZTE(tp,gpp)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endastops = gp.p.position_endstops;
    up.tilt_radial       = gp.p.tilt_radial;
    up.tilt_tangential   = gp.p.tilt_tangential;
    write_tilted_delta_update_cfg(up,'updateZTE.cfg');
    system('cat updateZTE.cfg');
end
