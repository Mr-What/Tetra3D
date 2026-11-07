% plot bed fit residual
% send commanded tower positions for probe, endstop settings for this probe,
% and parameter struct for estimated parameters
function [err,fitXYZ] = tetraPlotBedFitErr(xyz,tet,endstops,gp);
    if !isfield(gp,'delta_radius')
        gk = gp.kin;
    else
        % compute kinetic parameters
        gp = tetraGetParams(gp.cfg);
        gk=gp.kin;
    end
    fitXYZ = tetra2cartV(tet,gk,endstops);
    err = fitXYZ-xyz;
    p = [fitXYZ(:,1:2), err(:,3)];
    klipPlotProbes(p,'fit error');
end
