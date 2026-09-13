%  optimize delta_radius(3) and endstops given ben probe data
% My hypothesis is that with a tetrahedral delta, delta_radius
% is highly correlated to endstop (radius changes with tilt angle along tower).
% Hence, it is usually wise to optimize radius and endstops together. (ab)
function [gp,tp] = calR3E(logFile, gpp=[], measFile=[], measFileIdeal=[])
    tp = loadCalData(logFile, measFile, measFileIdeal);
    
    gp = tetraRefineR3E(tp,gpp);
    
    % had small error when using measXY, when bed-only converted.
    % check by simulated annealing?
    gp = tetraRefineR3E(tp,gp.p,...
                        [1,1,1,1,1,1]*.4,
                        [1,1,1,1,1,1]*.001);

    % write out updates for klipper printer.cfg
    % make a config parameter structure containing only stuff to be updated:
    up.position_endstops = gp.p.position_endstops;
    up.delta_radius = gp.p.delta_radius;
    write_tilted_delta_update_cfg(up,'updateR3E.cfg');
    system('cat updateR3E.cfg');
end
