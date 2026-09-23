% Colormap with center white, turning red low, blue high.
% This is a good colormap for data symetric about 0
%
% centerWhite([centerLevel,[offWhite]])
%
%   centerLevel (1) :  1 = flat blue/red, 0=colors fade to pure green
%   offWhite    (1) :  1=pure white center, .8=off white, 0=attenuate cross color to 0
%
function centerWhite(centerLevel=1,offWhite=1,greenPeak=1)

m = (centerLevel-1)/127;
x=[-127:1:0];
r = m*x+centerLevel;
r = [r,zeros(1,128)];
b = r([256:-1:1]);
m = greenPeak/127;
g = m*x+greenPeak;
g = [g,g([128:-1:1])];
g(128:129)=greenPeak;
r(128)=1;b(129)=1;
r(129)=offWhite;
b(128)=offWhite;
colormap([flip(r);flip(g);flip(b)]');

% $Log$
% Revision 1.1  2007-03-01 22:09:04  aaron
% new common utilities

