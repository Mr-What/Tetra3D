% initialize tetra tool path and default values for tetra global
global tetra
tetra.home = '~/Tetrahedral3Dprinter/Tetra3D';
tetra.toolPath = [tetra.home, 'tools'];
%addpath(tetra.toolPath);  % done in .octaverc to find this file!
addpath([tetra.toolPath, 'test']); % test scripts

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

% ============
tn=fieldnames(tetra);
for k=1:length(tn), fprintf(1,'tetra.%s=',tn{k}); disp(tetra.(tn{k})); end
clear k tn
