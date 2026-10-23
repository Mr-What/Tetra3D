% compute effector position for a vector of tower postions
function [gpos,bad,nBad] = tetra2cartV(tet,gk,endstops=[])
    if !isempty(endstops)
        % adjust tower positions for difference in endstops
        tet = commandedTowerPositions(endstops, tet, gk);
    end

    n = rows(tet);
    gpos = zeros(n,3);
    bad = zeros(n,1);
    for k=1:n
        p = tetra2cart(gk,tet(k,:));
        if !isreal(p)
            bad(k)=1;
            p = real(p);
        end
        gpos(k,:) = p;
    end
    nBad = sum(bad);
end
