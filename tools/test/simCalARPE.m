%  generate simulated bed probe and calibration print measurement
%    for a tilted_delta (tetra) printer, and refine
%
% A typical use case.  New printer, with only rough parameter estimates.
% Start by refining delta_radius and endstops.
% Then do a fine refinement of delta_radius[3], arm_length[3], delta_angle[3], and endstops.
% Hopefully, the initial refinement will get us close enough to the
% final answer so that the second search finds a reasonable minima.
%
%   A - Arm length, assert all arms match
%   R - [3] delta radius (mm)
%   P - [3] tower base position angles (deg)
%   Z - [3] radial tilt, toward central Z axis (deg)
%   T - [3] tangential (sideways) tilt.
%   E - [3] endstop locations, stepper mm along tower from bed
%
v = [-100:5:100];  % sample grid

% p0 is ideal parameters
p0=struct();  % clear any old values
p0.delta_radius = [160,160,160];
p0.delta_angles = [210,330,90];
p0.arm_lengths = [287,287,287];
p0.tilt_radial = [13,13,13];
p0.tilt_tangential = [0,0,0];
p0.position_endstops = [500,500,500];
p0.rotation_distances = [40,40,40];
p0 = getTetraParams(p0)

tp = p0.p;  % test discovery from purtutbed parameters
tp.position_endstops = p0.p.position_endstops + (rand(1,3)-.5) * 2; %E
tp.delta_radius = tp.delta_radius + 3 * (rand(1,3)-.5);             %R
tp.delta_angles = tp.delta_angles + 2 * (rand(1,3)-.5);             %P
tp.arm_lengths = tp.arm_lengths + 0.6 * (rand()-.5);                %A
tp = getTetraParams(tp)

n = length(v);
x = repmat(v,n,1);
y=x';
z = simulatedTetraProbe(x, y, 9, tp, p0, file='probeBadARPZTE.mat');
probe = [x(:), y(:), z(:)];  % store probe results with parameters uised

%xyIdeal = loadAsStruct('idealDeltaCalMeas10_60.m');
%xyMeas = simulateTetraXYmeas(tp,p0,xyIdeal); % simulate measured cal print data

% compute tower positions for all tests points, and store in tp struct
tp = appendTowerPositions(tp.p, probe);
%tp = appendTowerPositions(tp.p, probe, xyMeas, xyIdeal);

gp = tetraRefineRE(tp)
gp = tetraRefineARPE(tp,gp.k)

% write out updates for klipper printer.cfg
write_tilted_delta_update_cfg(gp.p,'updateARPE.cfg');
