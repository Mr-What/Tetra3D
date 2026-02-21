%
%
function tet = cart2tetra(tp,xyz)
  rodLen = tp.arm;
  [dA,eA] = towerDistance(tp.A0,tp.Ahat,rodLen(1),xyz);
  [dB,eB] = towerDistance(tp.B0,tp.Bhat,rodLen(2),xyz);
  [dC,eC] = towerDistance(tp.C0,tp.Chat,rodLen(3),xyz);
  tet = [dA,dB,dC];
  if (eA*eB*eC <= 0)
    qq = tetra2cart(tp,tet);    
    fprintf(2,'ERROR: Outside print envelope [%.2f,%.2f,%.2f]\n\t\t     limit at [%.2f,%.2f,%.2f]\n',xyz,qq);
    if (qq(3) < 0)
      qq(3)=0;
      fprintf(2,'\tbed crash.  limiting to [%.2f,%.2f,%d]\n',qq);
      tet = cart2tetra(tp,qq);
    end
  end
end

function [d,disc] = towerDistance(p0,vHat,r,q)
  %x0=p0(1);  % p0 is starting point, where d==0
  %y0=p0(2);
  %z0=p0(3); % should be 0
  %dx=vHat(1); % vHat is direction of motion, position = p0 + d * vHat
  %dy=vHat(2);
  %dz=vHat(3);
  
  % Tower position, distance d from p0 is
  %poly:(x0+d*xh-xq)^2+(y0+d*yh-yq)^2+(z0+d*zh-zq)^2;
  %expand(poly);
  %zq^2-2*d*zh*zq-2*z0*zq+d^2*zh^2+2*d*z0*zh+z0^2+yq^2-2*d*yh*yq-2*y0*yq+d^2*yh^2+2*d*y0*yh+y0^2+xq^2-2*d*xh*xq-2*x0*xq+d^2*xh^2+2*d*x0*xh+x0^2
  %collectterms(expand(poly),d);
  %zq^2+d*(2*x0*xh-2*xh*xq+2*y0*yh-2*yh*yq+2*z0*zh-2*zh*zq)-2*z0*zq+d^2*(xh^2+yh^2+zh^2)+z0^2+yq^2-2*y0*yq+y0^2+xq^2-2*x0*xq+x0^2
  %
  %d^2*(xh^2+yh^2+zh^2) +
  %d*(2*x0*xh-2*xh*xq+2*y0*yh-2*yh*yq+2*z0*zh-2*zh*zq) +
  %zq^2-2*z0*zq+z0^2+yq^2-2*y0*yq+y0^2+xq^2-2*x0*xq+x0^2
  %
  %d term: zh*(2*z0-2*zq)+yh*(2*y0-2*yq)+xh*(2*x0-2*xq)
  % == 2 * dot(vHat,po-pq)

  % for quadratic, a*d^2 + b*d + c = 0, a==1,
  b = 2 * dot(vHat,p0-q);
  % c = zq^2-2*z0*zq+z0^2+yq^2-2*y0*yq+y0^2+xq^2-2*x0*xq+x0^2-r^2
  % c = (zq-z0)^2 + (yq-y0)^2 + (xq-x0)^2 - r^2
  dq = q - p0;
  c = dq * dq' - r*r;

  disc = b*b - 4*c;
  if (disc < 0)
    disc=0;
  end
  d = (-b + sqrt(disc))/2;
  %d = (-b - sqrt(disc))/2;

end
