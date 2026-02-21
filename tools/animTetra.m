% octave script to save an animation of tetra plotter
gp.W=360;gp.Z=940;gp.R=287;  % approx my prototype frame
p=getTetraParams(gp)
m=1;
r=80;
%graphics_toolkit("gnuplot")
for i=0:2:100
    t = (i/50.0) * pi;
    q = [cos(t)*r, sin(t)*r,0];  % close to envelope limit
    tet = plotTetra(p,q);
    print("-dpng",sprintf("tet%03d.png",m)); m = m + 1;
end
for i=0:2:50  % spiral up 50 over a half turn
    t = (i/50.0) * pi;
    q = [cos(t)*r, sin(t)*r,i];
    tet = plotTetra(p,q);
    print("-dpng",sprintf("tet%03d.png",m)); m = m + 1;
end
for i=0:50  % spiral up 50 and reduce radius over a half turn
    t = (i/50.0) * pi + pi;
    q = [cos(t)*r, sin(t)*r,i+50];
    tet = plotTetra(p,q);
    print("-dpng",sprintf("tet%03d.png",m)); m = m + 1;
    r=r-1;
end
for i=0:5:100  % spiral up 
    t = i*pi/50.0;
    q = [cos(t)*r, sin(t)*r,i+100];
    tet = plotTetra(p,q);
    print("-dpng",sprintf("tet%03d.png",m)); m = m + 1;
    r=r*.95
end
for i=200:-5:0
    tet = plotTetra(p,[0,0,i]);
    print("-dpng",sprintf("tet%03d.png",m)); m = m + 1;
end
for i=0:3:80
    tet = plotTetra(p,[i,0,0]);
    print("-dpng",sprintf("tet%03d.png",m)); m = m + 1;
end
system('convert -delay 10 -loop 0 -layers Optimize tet???.png tetA.gif')
