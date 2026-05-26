% octave script to save an animation of tetra plotter
function animTetra(p,xyz)
    p.apex=750;  % near apex for tetrahedron
    %graphics_toolkit("gnuplot")
    for i=1:length(xyz)
        tet = plotTetra(p,xyz(i,1:3));
        print("-dpng",sprintf("tet%03d.png",i));
        pause(.1)
    end
    system('convert -delay 10 -loop 0 -layers Optimize tet???.png tetA.gif')
end
