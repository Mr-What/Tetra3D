%  optimize tower position and endstops
%      given bed probe (and print measurement) data
%           R - delta_radius
%           P - delta_angle
%           E - endstops
function gp = calRPE(logFile, gpp=[], measFile=[], measFileIdeal=[])
    tp = loadCalData(logFile, measFile, measFileIdeal);
    gp = tetraRefineRPE(tp,gpp);
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    %gp = tetraRefineRPE(tp,gp.p,...
    %                    [1,1,1,.5,.5,.5],
    %                    [1,1,1,1,1,1]*.004)

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    up.delta_angles = gp.p.delta_angles;
    write_tilted_delta_update_cfg(up,'updateRPE.cfg');
    system(sprintf('echo "# err=%.6f" >> updateRPE.cfg',gp.err));
    system('cat updateRPE.cfg');
end
