## -*- texinfo -*-
## @deftypefn  {} {@var{rw} =} randomWalk (@var{xy})
## @deftypefnx {} {@var{rw} =} randomWalk (@var{xy}, @var{numberRepeat})
##
## Re-order the rows of @var{xy} as a random walk, starting near the origin.
##
## @strong{Arguments}
## @table @var
## @item xy
##   m-by-d numeric matrix of points (one point per row).
## @item numberRepeat
##   Positive integer (default 1).  Each row of @var{xy} appears exactly
##   @var{numberRepeat} times in the output.
## @end table
##
## @strong{Algorithm}
## For pass 1: begin at the row of @var{xy} whose Euclidean distance to
## the origin is smallest.  At every subsequent step choose uniformly at
## random from the (up to 8) remaining rows that are closest in Euclidean
## distance to the last selected row.
##
## For passes 2 … numberRepeat: begin at the row of @var{xy} that is
## closest to — but not equal to — the last row appended in the previous
## pass.  "Not equal" is tested by row index, so duplicate coordinate
## values in @var{xy} are handled safely.
##
## @strong{Output}
## @var{rw} is an (m*numberRepeat)-by-d matrix.
## @end deftypefn

function rw = randomWalk (xy, numberRepeat=1)

  if nargin < 2
    numberRepeat = 1;
  end

  [m, d] = size (xy);

  if m == 0
    rw = zeros (0, d);
    return
  end

  % Neighbourhood size: up to 8 nearest remaining points are candidates.
  K_NEIGHBORS = 8;

  % Pre-allocate output.
  rw = zeros (m * numberRepeat, d);

  % Index of the last row written into rw (used across passes).
  last_xy_idx = [];   % empty → force origin-closest start on pass 1

  % ── squared-distance helper ─────────────────────────────────────────
  % Returns a column vector of squared Euclidean distances from each row
  % of candidate_xy to reference_row.
  sq_dist = @(candidate_xy, reference_row) ...
      sum (bsxfun (@minus, candidate_xy, reference_row) .^ 2, 2);

  for rep = 1 : numberRepeat

    % Indices of xy rows still available in this pass.
    available = (1 : m).';          % column vector

    % ── Choose starting point ────────────────────────────────────────
    if rep == 1 || isempty (last_xy_idx)
      % Pass 1: closest row to the origin.
      origin = zeros (1, d);
      dists  = sq_dist (xy(available, :), origin);
      [~, pos] = min (dists);
      current_idx = available(pos);
    else
      % Passes 2+: closest row in xy to the last inserted row,
      % excluding that exact row index so we don't start on the same point.
      ref   = xy(last_xy_idx, :);
      dists = sq_dist (xy(available, :), ref);

      % Remove the previous-pass seed itself if it is still in available
      % (it always is, since each pass uses a fresh copy of available).
      self_pos = find (available == last_xy_idx);
      if ~isempty (self_pos)
        dists(self_pos) = Inf;
      end

      [~, pos] = min (dists);
      current_idx = available(pos);
    end

    % ── Walk through all m rows ──────────────────────────────────────
    out_start = (rep - 1) * m + 1;   % where this pass starts in rw

    for step = 1 : m
      % Record the chosen point.
      rw(out_start + step - 1, :) = xy(current_idx, :);

      % Remove current_idx from the available pool.
      available(available == current_idx) = [];

      if isempty (available)
        break   % last step of this pass
      end

      % Compute distances from remaining rows to current point.
      ref   = xy(current_idx, :);
      dists = sq_dist (xy(available, :), ref);

      % Select up to K_NEIGHBORS nearest as candidates.
      k      = min (K_NEIGHBORS, numel (available));
      [sorted_d, order] = sort (dists);

      % Find where the k-th distance ends (handle ties at the boundary).
      cutoff  = sorted_d(k);
      in_hood = dists <= cutoff;          % logical mask over available
      candidates = available(in_hood);    % global xy indices

      % Pick one candidate uniformly at random.
      pick       = randi (numel (candidates));
      current_idx = candidates(pick);
    end

    last_xy_idx = current_idx;   % seed for next pass
  end

end
