% compute a random offset from given tetra parameters
function gp = tetraVoffset(cal,igp)
    global tetra

    p = tetraVget(cal,igp);
    r = 2*rand(1,length(p)) - 1;  % uniform [-1,1]
    dp = cal.initialStep;
    p = p + r .* dp;
    gp = tetraVset(cal,p,igp);
end
