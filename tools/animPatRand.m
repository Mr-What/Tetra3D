% octave script to save an animation of tetra plotter
% walking through a given point set randomly.
function animPatRand(p,xyz)
    %graphics_toolkit("gnuplot")
    hold off
    v = [0,0,0];
    m=1;
    n = size(xyz,1);
    idx = [1:n];
    %d0 = sqrt(sum(xyz .* xyz,2));
    while n > 0
        d = xyz(idx,:) - repmat(v,n,1);
        d = sqrt(sum(d .* d,2));
        [dLo,lo] = min(d);
        v = xyz(idx(lo),:);
        plotTetra(p,v);
        title(sprintf('%5d [%d %d %d]',m,round(v)));
        print('-dpng',sprintf('tet%03d.png',m)); m=m+1;
        idx(lo)=[]; %d0(lo)=[];
        n=n-1;
    end
    system('convert -delay 10 -loop 0 -layers Optimize tet???.png tet.gif')
end
