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
%         ... set mode==1 for input of tower leg lengths, as above
%
% Alternate, (easier ... now default) definition...
%  Do not define A,B,C, but let user define Apex point
function tp=getTetraCoords(baseLen,towerDef,mode)
  if (nargin < 3)
    mode = 0;  % tower defined by Apex point
  end

  cc = baseLen(3);  % cc to not be confused with C, tower length
  a2 = baseLen(1) * baseLen(1);
  b2 = baseLen(2) * baseLen(2);

  xB = (a2-b2)/(2*cc) + cc/2;  % note : B0 at (xB,-h/3,0)

  % Distance from C0 to c bar
  h = sqrt(a2/2 - ((a2-b2)^2)/(4*cc*cc) + b2/2 - (cc*cc)/4);

  tp.baseLen = baseLen;
  tp.A0 = [xB-cc,-h/3,0];
  tp.B0 = [xB   ,-h/3,0];
  tp.C0 = [  0 ,2*h/3,0];

  if (mode == 1)
    % second parameter is length of tower lines
    towerLen = towerDef;

    A=towerLen(1);
    B=towerLen(2);
    C=towerLen(3);
  
    % let A1 be (x1,y1,z1)
    x1 = xB - cc/2 + (A*A-B*B)/(2*cc);
    cmxB = cc - xB; % should be ~= xB
    y1 = (A*A-C*C - 2*cmxB*x1 - cmxB*cmxB) / (2*h) + h/6;
    z1 = sqrt(C*C - x1*x1 - (y1 - 2*h/3)^2);

    tp.h=h;
    tp.Apex = [x1,y1,z1];
    tp.towerLen = towerLen;
    
    % check results, should be all zero
    err = [baseLen(3)-norm(tp.B0-tp.A0),...
           baseLen(2)-norm(tp.C0-tp.A0),...
           baseLen(1)-norm(tp.B0-tp.C0),...
           towerLen(1)-norm(tp.A1-tp.A0),...
           towerLen(2)-norm(tp.A1-tp.B0),...
           towerLen(3)-norm(tp.A1-tp.C0)]
    tp.MAE = mean(abs(err));
  else
    tp.Apex = towerDef;
    tp.towerLen = [norm(tp.Apex-tp.A0),...
                   norm(tp.Apex-tp.B0),...
                   norm(tp.Apex-tp.C0)];
  end

  tp.Ahat = (tp.Apex-tp.A0) / tp.towerLen(1);
  tp.Bhat = (tp.Apex-tp.B0) / tp.towerLen(2);
  tp.Chat = (tp.Apex-tp.C0) / tp.towerLen(3);
end
