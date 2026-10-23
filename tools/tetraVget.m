% Set user/config parameters from a calibration search vector
function p = tetraVget(cal,gp)
    global tetra

    nf = length(cal.fields);
    n=1;
    for k=1:nf
        nam = cal.fields{k};  % field name
        if sum(cal.scalar==k)
            p(n) = mean(gp.(nam));
            n=n+1;
        else
            m = length(gp.(nam));
            p(n:n+m-1) = gp.(nam);
            n=n+m;
        end
    end
end
