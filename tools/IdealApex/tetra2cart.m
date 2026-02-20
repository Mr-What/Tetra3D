%
%
%
function q=tetra2cart(tp,tet)
  if(0)
    % for now, just brute-force search.  forward kinematics are hard to solve
    seed = [0,0,10];
    step = [1,1,1];
    small = [1,1,1] * 1e-3;  % units are cm.  this is 10um

  % servo-position parameters
  %sp.a = tp.A0 + tet(1)*tp.Ahat;
  %sp.b = tp.B0 + tet(2)*tp.Bhat;
  %sp.c = tp.C0 + tet(3)*tp.Chat;
  %sp.rodLen = tp.rodLen;
  % add target servo position to compute error
    tp1 = tp;
    tp1.posServo=tet;
    [q,nEval,status,err]=SimplexMinimize(@(v) tetra2cartErr(v,tp1),seed,step,small,1999,1e-8)
    return
  end

  % treat plane formed by the three servo positions as a new coordinate system.
  % where all servo positions are in the z==0 plane, and A0 abd B0 lie on the y==0 line.
  % C0 is at x0
  A0 = tp.A0 + tet(1)*tp.Ahat;
  B0 = tp.B0 + tet(2)*tp.Bhat;
  C0 = tp.C0 + tet(3)*tp.Chat;
  vAB = B0-A0;
  vAC = C0-A0;
  baseLen = [norm(B0-C0),...
             norm(vAC),...
             norm(vAB)];
  apex = getTetraCoords0(baseLen,tp.rodLen);
  % convert from effector coords back to tower
  xHat = vAB / baseLen(3);
  xA = dot(xHat,vAC);
  origin = A0 + xA*xHat;
  yC = C0-origin;
  yHat = yC/norm(yC);
  zHat = -cross(xHat,yHat);
  q = origin + apex(1)*xHat + apex(2)*yHat + apex(3)*zHat;
end

function err=tetra2cartErr(v,tp)
  tet = cart2tetra(tp,v);
  err = norm(tet-tp.posServo);
end

function apex=getTetraCoords0(baseLen,twrLen)
  aa = baseLen(1);
  bb = baseLen(2);
  cc = baseLen(3);
  a2 = aa*aa;
  b2 = bb*bb;
  c2 = cc*cc;
  rA=twrLen(1);
  rB=twrLen(2);
  rC=twrLen(3);
  rA2 = rA*rA;
  rB2 = rB*rB;
  rC2 = rC*rC;
  xB = (cc + (a2-b2)/cc)/2;
  xB2 = xB*xB;
  yC2 = a2 - xB*xB;
  yC = sqrt(yC2);
  x1 = (rA2-rB2)/(2*cc) + xB - (cc/2);
  y1 = (rB2-rC2+yC2+xB*(2*x1-xB))/(2*yC);
  z1 = sqrt(rC2 - x1*x1 - ((y1-yC)^2));
  apex = [x1,y1,z1];
  return
  
  % check.. all err should be zero
  A0=[xB-cc,0,0]
  B0=[xB   ,0,0]
  C0=[0,yC,0]
  err = [norm(A0-B0)-cc,norm(A0-C0)-bb,norm(B0-C0)-aa,...
         norm(apex-A0)-twrLen(1),...
         norm(apex-B0)-twrLen(2),...
         norm(apex-C0)-twrLen(3)]

end

