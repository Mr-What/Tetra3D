% derive some useful coordinate parameters for Tetrahedron 3D printer
% kinematic model from input parameters
%
% Tower A is in the -x,-y quadrant (front left)
% Tower B is in the  x,-y quadrant (front right)
% Tower C is near the x=0 axis     (rear)
%
% For interface, we define :
%          delta_radius  (mm)
%          delta_angles (usually [210,330,90])
%          arm_lengths
%          tilt_radial      (towards origin)
%          tilt_tangential  (towards left as tower facing origin)
%          position_endstops (distance from z=0 plane to location of arm axis at endstop)
%          rotation_distance (how many mm movement/rotation)
%
% for kinematics, we convert these to:
%    base[3,3] -- base locations, Z's should be 0
%    dir[3,3]  -- tower travel direction, [0,0,1] for perfect linear delta.
%    arm_lengths[3]    -- length of arm from carriage to effector, same as interface
%
% Since there are fewer parameters, we optimize on the "human" parameters,
% but compute forward and reverse kinematics with the kinematic params.
%
% pre 260314, we were working with less parameters, but I fear that
% they would be hard to optimize due to high correlations.
% There are 2 more parameters here, but they are more "orthogonal".
% Earlier work also was based around using M codes to set parameters,
% but for klipper, I think parameters will be in printer.cfg, so I use
% longer variable names, similar to thise for linear_delta,
% for definition in a [printer] section
%
function tp=getTetraParams(p0)
    if isfield(p0,"delta_radius")  % each tower, at base
        tp.p = p0;  % parameters in "interface" form
        tp.k = tetraKineticParams(p0);
    elseif isfield(p0,"printer")  % this must be from loadKlipperCfg.m
        tp = getTetraParams(cfg2tetraDef(p0));
    else
        tp.k = p0;
        tp.p = tetraDefinitionParams(p0);
    end
end

function kp = tetraKineticParams(p)
    kp.base = [ [-1,-1,0] ; [1,-1,0]; [0,0,1] ];
    kp.dir = [[0,0,1];[0,0,1];[0,0,1]];
    kp.arm = p.arm_lengths;
    kp.endstop = p.position_endstops;
    kp.mmPerRot = p.rotation_distances;
    for n=1:3
        a = p.delta_angles(n);
        r = p.delta_radius(n);
        q = r * [cosd(a), sind(a), 0];
        kp.base(n,:) = q;
        z = p.tilt_radial(n);
        t = p.tilt_tangential(n);
        %hat = [cosd(t) * sind(z), sind(t) * sind(z), cos(z)]
        %norm(hat)
        rHat = -q / norm(q);
        tHat = [-rHat(2), rHat(1), 0];
        sz = sind(z);
        st = sind(t);
        zh = sqrt(1 - sz*sz - st*st);
        kp.dir(n,:) = sind(z) * rHat + sind(t) * tHat + [0,0,zh];
    end
end

        
function p = tetraDefinitionParams(k)
    p.arm_lengths = k.arm;
    p.delta_radius = [150,150,150];
    p.delta_angles = [210,330,90];
    p.tilt_radial = [0,0,0];
    p.tilt_tangential = [0,0,0];
    p.position_endstops = [1,1,1] * 500;
    p.rotation_distances = [1,1,1] * 40;
    kp.base = [ [-1,-1,0] ; [1,-1,0]; [0,0,1] ];
    kp.dir = [[0,0,1],[0,0,1],[0,0,1]];

    for n=1:3
        q = k.base(n,:);
        r = norm(q);
        p.delta_radius(n) = r;
        p.delta_angles(n) = atan2d(q(2), q(1));
        rHat = -q / norm(q);
        tHat =  [-q(2), q(1), 0];
        d = k.dir(n,:);
        p.tilt_radial(n) = atan2d(dot(rHat,d), d(3) );
        p.tilt_tangential(n) = atan2d(dot(tHat,d), d(3));
    end
end

% extract tetra parameter set from loadKlipperCfg.m printer.cfg file
function p = cfg2tetraDef(cfg)
    p = cfg.printer;
    s = [ cfg.stepper_a.position_endstop,
          cfg.stepper_b.position_endstop,
          cfg.stepper_c.position_endstop];
    r = [ cfg.stepper_a.rotation_distance,
          cfg.stepper_b.rotation_distance,
          cfg.stepper_c.rotation_distance];
    p.position_endstops = s(:)';
    p.rotation_distances = r(:)';
end
