% density based clustering
%
%  eps    -- estimated likely radius of a cluster?
%  minpts -- minimum cluster size 
function labels = dbscan(P, eps=5, minpts=8)
  n = rows(P);
  labels = zeros(n, 1);       % 0 = unvisited
  visited = false(n, 1);
  cid = 0;
  D = sqrt((P(:,1)-P(:,1)').^2 + (P(:,2)-P(:,2)').^2);  % pairwise XY distance
  for i = 1:n
    if visited(i), continue; end
    visited(i) = true;
    nbrs = find(D(i,:) <= eps);
    if numel(nbrs) < minpts
      labels(i) = -1;          % noise
      continue;
    end
    cid += 1;
    labels(i) = cid;
    seeds = nbrs;
    k = 1;
    while k <= numel(seeds)
      j = seeds(k);
      if !visited(j)
        visited(j) = true;
        jn = find(D(j,:) <= eps);
        if numel(jn) >= minpts
          seeds = unique([seeds, jn]);
        end
      end
      if labels(j) <= 0
        labels(j) = cid;
      end
      k += 1;
    end
  end
end
