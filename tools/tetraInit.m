% initialize tetra tool path and default values for tetra global
global tetra
tetra.home = '~/Tetrahedral3Dprinter/Tetra3D';
tetra.toolPath = [tetra.home, '/tools'];
%addpath(tetra.toolPath);  % done in .octaverc to find this file!
addpath([tetra.toolPath, '/test']); % test scripts

tetra.callCount=0;  % for SimplexMinimize diagnostic print
tetra.callPeriod=50;  % print out SimplexMinimize diag every this many counts
tetra.echoMeas=false;  % true will print diag ONCE until reset
tetra.plotFlags=3;  % flags to enable some plots
tetra.measFileIdeal='idealDeltaCalMeas10_60.m';

% C printf style format of log file, convert int probe ID number to string
%    This file contains tetra parameters echoed at start up,
%    and bed probe data
tetra.logFileFmt = 'probe%03d.log';

% name or IP of klipper host computer (usually an RPi)
tetra.host = 'tetrapi'; % 192.168.2.66

% path to tetra utilities on klipper host computer, with trailing /
tetra.hostUtilPath = '~pi/bin';

tetra.RMS = struct('bed',0,'plate',0,'meas',0);

% there are places where we don't want simplex diagnostics.
% set default to allow simplex diagnostics
global verboseFlags
verboseFlags.simplex=1;

% ============
%tn=fieldnames(tetra);
%for k=1:length(tn), fprintf(1,'tetra.%s=',tn{k}); disp(tetra.(tn{k})); end
%clear k tn


% ------------------------------- calibration settings
tetra.cfgFields = {'delta_radius','delta_angles','arm_lengths',...
                   'tilt_radial','tilt_tangential','position_endstops', ...
                   'rotation_distances'};

id.id = 'RPAZTE';  % full calibration
id.fields = tetra.cfgFields;
id.scalar=[];
id.initialStep = [3,3,3, 2,2,2, 3,3,3,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox = [2,2,2, 2,2,2, 2,2,2, 1,1,1, 1,1,1, 2,2,2]/1000;
id.callPeriod = 50;
tetra.cal.(id.id) = id;

id.id = 'R1E';
id.fields = tetra.cfgFields([1,6]);
id.scalar=[1]; % first field, delta_radius is scalar
id.initialStep = [1,1,1,1];
id.smallBox = [1,1,1,1] * 0.0003;
id.callPeriod = 10;
tetra.cal.(id.id) = id;

id.id = 'RE';
id.initialStep = [1,1,1,1,1,1];
id.smallBox = [1,1,1,1,1,1] * 0.0003;
id.scalar=[];
tetra.cal.(id.id) = id;

id.id = 'RA1ZTE';
id.fields = tetra.cfgFields([1,3:6]);
id.scalar=[2]; % second field, arm_lengths is scalar
id.initialStep = [4,4,4, 2,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox = ones(1,13)/2000;
id.callPeriod = 50;
tetra.cal.(id.id) = id;

id.id = 'RAZTE';
id.scalar=[];
id.initialStep = [4,4,4, 2,2,2,  2,2,2,  2,2,2, 2,2,2]/10;
id.smallBox = ones(1,15)/2000;
id.callPeriod = 100;
tetra.cal.(id.id) = id;




