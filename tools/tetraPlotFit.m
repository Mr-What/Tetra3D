% second part of typical tetra fit plot
function [err,errZ,badZ,errXY,badXY] = plotTetraFit(fit,PP,gp,tetraSetFcn)
   [err,errZ,badZ,errXY,badXY] = tetraFitErr(fit,PP,gp,tetraSetFcn);
   pf = PP.probe;  pf(:,3) = pf(:,3) + errZ;
   plot3(pf(:,1),pf(:,2),pf(:,3),'ro');
   legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
   hold off
end
