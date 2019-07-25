% derive some useful coordinate parameters for Tetrahedron 3D printer
% kinematic model from input parameters
%
% Vertex A0 to lower left, negative X, negitive Y, z=0.
% h is height of base, perpendicular to bar c, ending at vertex C0
% Assert base bar "c" is along y=-h/3 line, A0 is vertex at -x side of c.
% Vertex B0 is at +x end of bar c
% Vertex C0 is at (0, 2*h/3, 0)
% We define xB s.t. B0 is at (xB,-h/3,0),
%   and A0 is at (xB-c,-h/3,0)
% Note that base side c is opposite of tower C, base a opposite tower rail A,
% and base b opposite tower rail B
% A, B, and C are lengths of tower rails of the same name.
% Hence, we assert that the bottom plate is always "correct", with
% vertices at A0, B0, C0 ... 3 vertices defining the base plane.
% A0,B0,C0 are at the base of their respective tower rails,
% and base bar lengths a,b,c which are opposite of vertices A0,B0,C0.
% we seek to calibrate/characterize build imperfections of the rest of the assembly,
% assuming that the bottom plate is a "correct" flat reference.
% Let A1 be the location of the "apex" where A,B,C rail lines meet

function tp=getTetraCoords(baseLen,towerLen)

  cc = baseLen(3);  % cc to not be confused with C, tower length
  a2 = baseLen(1) * baseLen(1);
  b2 = baseLen(2) * baseLen(2);
  A=towerLen(1);
  B=towerLen(2);
  C=towerLen(3);
  
  xB = (a2-b2)/(2*cc) + cc/2;  % note : B0 at (xB,-h/3,0)

  % Distance from C0 to c bar
  h = sqrt(a2/2 - ((a2-b2)^2)/(4*cc*cc) + b2/2 - (cc*cc)/4);

  % let A1 be (x1,y1,z1)
  x1 = xB - cc/2 + (A*A-B*B)/(2*cc);
  cmxB = cc - xB; % should be ~= xB
  y1 = (A*A-C*C - 2*cmxB*x1 - cmxB*cmxB) / (2*h) + h/6;
  z1 = sqrt(C*C - x1*x1 - (y1 - 2*h/3)^2);

  tp.A0 = [xB-cc,-h/3,0];
  tp.B0 = [xB   ,-h/3,0];
  tp.C0 = [  0 ,2*h/3,0];
  tp.h=h;
  tp.A1 = [x1,y1,z1];
  tp.baseLen = baseLen;
  tp.towerLen = towerLen;
  
  % check results, should be all zero
  err = [baseLen(3)-norm(tp.B0-tp.A0),...
         baseLen(2)-norm(tp.C0-tp.A0),...
         baseLen(1)-norm(tp.B0-tp.C0),...
         towerLen(1)-norm(tp.A1-tp.A0),...
         towerLen(2)-norm(tp.A1-tp.B0),...
         towerLen(3)-norm(tp.A1-tp.C0)]
  tp.MAE = mean(abs(err));
end



