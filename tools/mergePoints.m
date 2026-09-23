% given a set of n points, p(n,3), collect all points within neigh of each other
% where p(k,1:2) are very close, and return the median of all collected points
%
%  for printer bed probes, 1mm is adequate
%    idx is the index of pm into which each point was merged
function [pm,idx] = mergePoints(p,neigh=1)
    idx = zeros(rows(p),1);
    qc=p(1,1:2);
    idx(1)=1;
    nc=1;
    for j=2:rows(p)
        pj = p(j,:);
        dq = [qc(:,1) - pj(1), qc(:,2) - pj(2)];
        dq = norm(dq,2,'rows');
        m = find(dq < neigh);
        if isempty(m)
            nc = nc + 1;  % start new cluster
            qc(nc,:) = pj(1:2);
            idx(j)=nc;
        else
            idx(j) = m;  % m should always have one element.  crash here means a bug
        end
    end

    % compute avg for location, and median for value of each cluster
    pm = zeros(nc,3);
    for j=1:nc
        m = find(idx==j);
        pm(j,:) = [mean(p(m,1:2),1), median(p(m,3))];
    end
end
