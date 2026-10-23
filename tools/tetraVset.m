% Set user/config parameters from a calibration search vector
function gp = tetraVset(cal,p,igp)
    gp = tetraExtractCfgParams(igp);
    nf = length(cal.fields);
    n=1;
    for k=1:nf
        nam = cal.fields{k};  % field name
        m = length(gp.(nam));
        if sum(cal.scalar==k)
            gp.(nam) = p(n) + zeros(1,m);
            n=n+1;
        else
            gp.(nam) = p(n:n+m-1);
            n=n+m;
        end
    end
    gp = tetraGetParams(gp);  % re-build kinematic params
end
