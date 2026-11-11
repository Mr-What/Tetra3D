% initialize tetra tool path and default values for tetra global
global tetra
tetra = struct('home','~/Tetrahedral3Dprinter/Tetra3D');
tetra.toolPath = [tetra.home, '/tools'];
%addpath(tetra.toolPath);  % done in .octaverc to find this file!
addpath([tetra.toolPath, '/test']); % test scripts

tetra.callCount=0;  % for SimplexMinimize diagnostic print
tetra.callPeriod=50;  % print out SimplexMinimize diag every this many counts
tetra.echoMeas=false;  % true will print diag ONCE until reset
tetra.plotFlags=3;  % flags to enable some plots
tetra.measFileIdeal='idealDeltaCalMeas10_60.m';

% name or IP of klipper host computer (usually an RPi)
tetra.host = 'tetrapi'; % 192.168.2.66

% path to tetra utilities on klipper host computer
tetra.hostUtilPath = '~pi/bin';

% hack to extract parts of error metric from SimplexMinimize
tetra.RMS = struct('bed',0,'plate',0,'meas',0);

% there are places where we don't want simplex diagnostics.
% set default to allow simplex diagnostics
global verboseFlags
verboseFlags.simplex=1;

% cosine of angle that is too close to the tower, or the perpendicular of the tower
% cosine of angle that is too close to the tangential direction for pivot hardware.
% current heim joints swing about 17.5 deg sideways at best, cos(90-17.5)=.3
tetra.envelope=struct('tooClose',.98,'tooSideways',.3);

suppress_verbose_help_message(true);  % turn off help help at the bottom of help messages

% ------------------------------- calibration settings
tetra.cfgFields = {'delta_radius','tower_angles','arm_lengths',...
                   'tilt_radial','tilt_tangential','position_endstops', ...
                   'rotation_distances'};
clear id

% always check endstops, so I'll remove E from IDs.  Redundant.

% this should only be used when DZT and AZT are not quite converging
% or oscillation.  Mostly for refinement without annealing,
%   e.g.    gp = tetraCal('DAZT',td,igp,3,false)
id.id = 'DAZT';  % full calibration (not recommended)
id.fields = tetra.cfgFields(1:6);
id.scalar=[];
id.initialStep = [3, 2,2,  3,3,3,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox =    [2, 2,2,  2,2,2,  1,1,1,  1,1,1, 2,2,2]/10000;
id.callPeriod = 50;
tetra.cal.(id.id) = id;

id.id = 'DA';
id.fields = tetra.cfgFields([1:3,6]);
id.initialStep = [2, 1,1, 1,1,1, 2,2,2];
id.smallBox = id.initialStep / 10000;
tetra.cal.(id.id) = id;

id.id = 'A';
id.fields = tetra.cfgFields([3,6]);
id.initialStep = [1,1,1, 2,2,2];
id.smallBox = id.initialStep / 10000;
tetra.cal.(id.id) = id;

id.id = 'DZT';  
id.fields = tetra.cfgFields([1,2,4:6]);
id.initialStep = [3,  2,2,  1,1,1, 1,1,1,  2,2,2]/10;
id.smallBox =    [2,  1,1,  1,1,1, 1,1,1,  2,2,2]/10000;
tetra.cal.(id.id) = id;

id.id = 'AZT';
id.fields = tetra.cfgFields(3:6);
id.initialStep = [3,3,3,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox =    [2,2,2,  1,1,1,  1,1,1, 2,2,2]/10000;
tetra.cal.(id.id) = id;

id.id = 'ZT';
id.fields = tetra.cfgFields(4:6);
id.initialStep = [2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox =    [1,1,1,  1,1,1, 2,2,2]/10000;
tetra.cal.(id.id) = id;

id.id = 'A1ZT';
id.scalar = 1;
id.initialStep = [3,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox =    [2,  1,1,1,  1,1,1, 2,2,2]/10000;
tetra.cal.(id.id) = id;

id.id = 'R';
id.fields = tetra.cfgFields([1,6]);
id.initialStep = [1, 1,1,1];
id.smallBox =    id.initialStep * 0.0003;
id.scalar=[];
id.callPeriod = 10;
tetra.cal.(id.id) = id;

id.id = 'D';
id.fields = tetra.cfgFields([1,2,6]);
id.initialStep = [1, 1,1, 1,1,1];
id.smallBox = id.initialStep * 0.0003;
id.scalar=[];
tetra.cal.(id.id) = id;

id.id = 'DA1ZT';
id.fields = tetra.cfgFields([1:6]);
id.scalar=[3]; % third field, arm_lengths is scalar
id.initialStep = [4, 2,2, 2,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox = ones(1,13)/2000;
id.callPeriod = 50;
tetra.cal.(id.id) = id;

id.id = 'E';
id.fields = tetra.cfgFields(6);
id.scalar=[];
id.initialStep = [4,4,4]/10;
id.smallBox = ones(1,3)/2000;
id.callPeriod = 20;
tetra.cal.(id.id) = id;

clear id
