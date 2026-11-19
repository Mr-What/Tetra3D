% return indices of points within tol of each other
% assumes there is at most one match in the data
function [idxA,idxB] = matchedPoints(a,b,tol=4);
    n=0;
    na=rows(a);
    nb=rows(b);
    t2 = tol*tol;
    for k=1:na
        dx = b(:,1)-a(k,1);
        dy = b(:,2)-a(k,2);
        da = dx .* dx + dy .* dy;
        [d2, m] = min(da);
        if (d2 < t2)
            n=n+1;
            idxA(n) = k;
            idxB(n) = m;
            b(m,2) = -9e9;  % mark as already matched
        end
    end
end
