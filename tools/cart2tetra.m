%
%
function tet = cart2tetra(tp,xyz)
  rodLen = tp.arm;
  [dA,eA] = towerDistance(tp.base(1,:),tp.dir(1,:),tp.arm(1),xyz);
  [dB,eB] = towerDistance(tp.base(2,:),tp.dir(2,:),tp.arm(2),xyz);
  [dC,eC] = towerDistance(tp.base(3,:),tp.dir(3,:),tp.arm(3),xyz);
  tet = [dA,dB,dC];
  %if (eA*eB*eC <= 0)
  %  qq = tetra2cart(tp,tet);    
  %  %fprintf(2,'ERROR: Outside print envelope [%.2f,%.2f,%.2f]\n\t\t     limit at [%.2f,%.2f,%.2f]\n',xyz,qq);
  %  %if (qq(3) < 0)
  %  %  qq(3)=0;
  %  %  fprintf(2,'\tbed crash.  limiting to [%.2f,%.2f,%d]\n',qq);
  %  %  tet = cart2tetra(tp,qq);
  %  %end
  %  tet=complex(tet);  % indicate error
  %end
end

function [d,disc] = towerDistance(p0,vHat,r,q)

  % for quadratic, a*d^2 + b*d + c = 0, a==1,
  b = 2 * dot(vHat,p0-q);
  dq = q - p0;
  c = dq * dq' - r*r;

  disc = b*b - 4*c;
  %if (disc < 0), disc=0; end
  d = (-b + sqrt(disc))/2;
  %d = (-b - sqrt(disc))/2;

end
