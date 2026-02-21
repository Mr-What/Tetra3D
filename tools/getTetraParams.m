% derive some useful coordinate parameters for Tetrahedron 3D printer
% kinematic model from input parameters
%
% Tower A is in the -x,-y quadrant with base at (A0x, A0y, 0)
% Tower B is in the  x,-y quadrant with base at (B0x, A0y, 0)
% Tower C is on the x=0 axis       with base at ( 0 , C0y, 0)
%
% The top of the towers is defined at the z=Z plane.
% Ideally this is (0,0,Z) for all towers, but for more detailed
% model the interception of each tower movement line is just near (0,0,Z)
% The A intercepts the z=Z plane at ZA (ZAx, ZAy, Z)
% The B intercepts the z=Z plane at ZB (ZBx, ZBy, Z)
% The C intercepts the z=Z plane at ZC (ZCx, ZCy, Z)
%
% gcode param definitions:
%   A  -- length of side OPPOSITE from tower A 
%   B  -- length of side OPPOSITE from tower B
%   C  -- length of side OPPOSITE from tower C
%   Z  -- (ideal) distance of base plane to shared Apex point
%   D  -- arm length for tower A
%   E  -- arm length for tower B
%   F  -- arm length for tower C
%   G  -- Tower A x intercept, ZAx,  on z=Z plane
%   H  -- Tower A y intercept, ZAy
%   I  -- Tower B x intercept, ZBx
%   J  -- Tower B y intercept, ZBy
%   K  -- Tower C x intercept, ZCx
%   L  -- Tower C y intercept, ZCy
%
%  gcode parameters for more ideal case, which overrides the above:
%
%   W  -- distance between adjacent tower bases
%   R  -- Tower arm length, all towers
%
%  General parameters, p, a more convenient arrangement of above
%   sideLen[3]  -- a,b,c base len, for opposites of towers A, B, C
%   Z           -- height of plane (near) Apex
%   armLen[3]   -- legth of effector arm, tower A,B,C
%   Zxy[3,2]    -- intercept of towers A,B,C at height Z
%
%  Kinematic parameters, k
%     base[3,3]  -- Location of base corners, assert base[:,3] == 0
%     hat[3,3]   -- direction for each tower, normalized vector rows
%     arm[3]     -- length of each effector arm, A,B,C
%
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
function tp=getTetraParams(p0)
    tp=struct();
    if isfield(p0,"A") || isfield(p0,"W")
        % parameters in gcode form
        p.Z = p0.Z;
        tp.gcode = p0;
        if isfield(p0,"W")
            p.sideLen = zeros(1,3) + p0.W;
        else
            p.sideLen = [p0.A, p0.B, p0.C];
        end
        if isfield(p0,"R")
            p.armLen = zeros(1,3) + p0.R;
        else
            p.armLen  = [p0.D, p0.E, p0.F];
        end
        p.Zxy = zeros(3,2);
        if isfield(p0,'G'), p.Zxy(1,1) = p0.G; end
        if isfield(p0,'H'), p.Zxy(1,2) = p0.H; end
        if isfield(p0,'I'), p.Zxy(2,1) = p0.I; end
        if isfield(p0,'J'), p.Zxy(2,2) = p0.J; end
        if isfield(p0,'K'), p.Zxy(3,1) = p0.K; end
        if isfield(p0,'L'), p.Zxy(3,2) = p0.L; end

        tp.p = p
    end
    if isfield(p0,"sideLen")
        tp.p = p0;  % parameters provided in general form
    end

    % assert that Cy == distance of B0 to origin
    a = tp.p.sideLen(1)
    b = tp.p.sideLen(2)
    c = tp.p.sideLen(3)
    Bx = (a*a + c*c - b*b) / (2 * c);
    Ax = Bx - c;
    h = sqrt(a*a - Bx*Bx)
    Cy = (a*a)/(2*h)
    Ay = Cy-h
    %k.base = [Ax, Ay, 0; Bx, Ay, 0; 0, Cy, 0];
    k.arm = tp.p.armLen;  % no change
    k.A0 = [Ax, Ay, 0];
    k.B0 = [Bx, Ay, 0];
    k.C0 = [ 0, Cy, 0];
    h = [tp.p.Zxy(1,:), tp.p.Z] - k.A0
    k.Ahat = h / norm(h);
    h = [tp.p.Zxy(2,:), tp.p.Z] - k.B0
    k.Bhat = h / norm(h);
    h = [tp.p.Zxy(3,:), tp.p.Z] - k.C0
    k.Chat = h / norm(h);
    tp.k = k;
end
