% initialize tetra tool path and default values for tetra global
global tetra
tetra.home = '~/Tetrahedral3Dprinter/Tetra3D/';
%addpath('~/Tetrahedral3Dprinter/Tetra3D/tools');  % need this to find this file!
addpath([tetra.home, 'tools/test']); % test scripts
tetra.callCount=0;  % for SimplexMinimize diagnostic print
tetra.callPeriod=50;  % print out SimplexMinimize diag every this many counts
tetra.echoMeas=false;  % true will print diag ONCE until reset
tetra.plotFlags=3;  % flags to enable some plots
tetra.measFileIdeal='idealDeltaCalMeas10_60.m';

tn=fieldnames(tetra);
for k=1:length(tn), fprintf(1,'tetra.%s=',tn{k}); disp(tetra.(tn{k})); end
clear k tn
