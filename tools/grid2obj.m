## Copyright (C) 2026
##
## grid2obj: write a regular (rows x cols) surface grid as a Wavefront OBJ file.
##
## usage:
##   grid2obj (fname, X, Y, Z)
##   grid2obj (fname, X, Y, Z, "wrap", true, "caps", true, "quads", false)
##
## X, Y, Z are equal-sized 2-D matrices holding the grid point coordinates.
## The intended use is a distorted tube around the z axis sampled on a
## regular (theta, z) grid:
##   rows    = angular samples, theta increasing (e.g. 0 .. < 2*pi)
##   columns = axial samples,   z increasing
##
## For radius data R (rows x cols) with theta a column vector and z a row:
##   [X, Y, Z] = deal (R .* cos (theta), R .* sin (theta), ones (rows(R), 1) * z);
##
## Options (name/value pairs):
##   "wrap"  true | false | "auto" (default "auto")
##     true  : the last row connects back to the first row (periodic tube).
##             Do NOT include a duplicated theta = 2*pi sample in this case.
##     false : no connection between last and first row (open angular
##             boundary -- the tube keeps a slit at the seam even with caps).
##     auto  : wrap the seam.  If the first and last rows already coincide
##             (duplicated theta = 2*pi sample), the redundant last row is
##             dropped first, since keeping it would leave coincident but
##             unshared edges (a topological slit that breaks watertightness
##             checks in slicers).
##   "caps"  logical, default false.  Add a triangle-fan disk closing each end
##           (j = 1 and j = cols).  The fan is built around the end ring's
##           centroid, so it is only valid if each end polygon is planar and
##           star-shaped about that centroid (true for typical r(theta,z)
##           tubes).  Caps close the ends only; they do not give the tube
##           wall thickness.
##   "quads" logical, default false.  true writes 4-vertex faces instead of
##           two triangles per cell.  Triangles are safer for non-planar
##           cells (some importers render quads badly).
##
## Face winding follows the right-hand rule so normals point outward
## (away from the z axis) for a tube with rows = theta increasing and
## columns = z increasing.  OBJ vertex indices are 1-based.
##
## See also: isosurface, patch

function grid2obj (fname, X, Y, Z, varargin)

  if (nargin < 4 || rem (nargin - 4, 2) != 0)
    print_usage ();
  endif

  if (! (isreal (X) && isreal (Y) && isreal (Z) ...
         && ismatrix (X) && ismatrix (Y) && ismatrix (Z) ...
         && ndims (X) == 2 && isequal (size (X), size (Y), size (Z))))
    error ("grid2obj: X, Y, Z must be equal-sized real 2-D matrices");
  endif

  [n, m] = size (X);    # n rows (theta), m columns (z)
  if (n < 3 || m < 2)
    error ("grid2obj: need at least 3 rows and 2 columns");
  endif

  ## --- parse options -------------------------------------------------
  wrap = "auto";
  caps = false;
  quads = false;
  for k = 1:2:numel (varargin)
    opt = lower (varargin{k});
    val = varargin{k+1};
    switch (opt)
      case "wrap",   wrap = val;
      case "caps",   caps = val;
      case "quads",  quads = val;
      otherwise
        error ("grid2obj: unknown option '%s'", varargin{k});
    endswitch
  endfor

  ## --- decide seam handling -------------------------------------------
  if (ischar (wrap) && strcmpi (wrap, "auto"))
    ## Compare all three coordinates, with a tolerance tied to the grid's
    ## own row spacing (so a tube translated far along z is not misjudged).
    d = max ([max(abs(X(1,:) - X(2,:))), max(abs(Y(1,:) - Y(2,:))), ...
              max(abs(Z(1,:) - Z(2,:)))]);
    seam = max ([max(abs(X(1,:) - X(end,:))), max(abs(Y(1,:) - Y(end,:))), ...
                 max(abs(Z(1,:) - Z(end,:)))]);
    if (n > 3 && seam <= 1e-6 * max (d, 1))
      ## duplicated theta = 2*pi sample: drop the redundant last row and
      ## wrap.  Keeping it leaves coincident but unshared edges (a slit).
      X = X(1:end-1,:);  Y = Y(1:end-1,:);  Z = Z(1:end-1,:);
      n -= 1;
      printf ("grid2obj: duplicated seam row detected - dropped last row and wrapped\n");
    endif
    wrap = true;
  endif
  wrap = logical (wrap);
  caps = logical (caps);
  quads = logical (quads);

  fid = fopen (fname, "w");
  if (fid < 0)
    error ("grid2obj: cannot open '%s' for writing", fname);
  endif
  unwind_protect
    fprintf (fid, "# exported by grid2obj (Octave)\n");
    fprintf (fid, "# %d rows (theta) x %d columns (z), wrap=%d, caps=%d\n", ...
             n, m, wrap, caps);

    ## --- vertices (column-major: index(i,j) = i + (j-1)*n) -------------
    for j = 1:m
      for i = 1:n
        fprintf (fid, "v %.10g %.10g %.10g\n", X(i,j), Y(i,j), Z(i,j));
      endfor
    endfor
    nv = n * m;

    ## --- side faces ---------------------------------------------------
    for j = 1:m-1
      for i = 1:n
        if (i == n)
          if (wrap)
            i2 = 1;
          else
            continue;   # open surface: no face between last and first row
          endif
        else
          i2 = i + 1;
        endif
        a = i  + (j-1) * n;   # (i  , j  )
        b = i2 + (j-1) * n;   # (i+1, j  )
        c = i2 +  j    * n;   # (i+1, j+1)
        d = i  +  j    * n;   # (i  , j+1)
        if (quads)
          fprintf (fid, "f %d %d %d %d\n", a, b, c, d);
        else
          fprintf (fid, "f %d %d %d\n", a, b, c);
          fprintf (fid, "f %d %d %d\n", a, c, d);
        endif
      endfor
    endfor

    ## --- optional end caps (triangle fans around a centroid) -----------
    if (caps)
      for j = [1, m]
        ctr = [mean(X(:,j)), mean(Y(:,j)), mean(Z(:,j))];
        nv += 1;
        fprintf (fid, "v %.10g %.10g %.10g\n", ctr(1), ctr(2), ctr(3));
        cidx = nv;
        for i = 1:n
          if (i == n)
            if (wrap)
              i2 = 1;
            else
              continue;  # open surface: skip seam fan triangle
            endif
          else
            i2 = i + 1;
          endif
          p = i  + (j-1) * n;
          q = i2 + (j-1) * n;
          if (j == m)          # top: fan (ctr, p, q) -> normal +z
            fprintf (fid, "f %d %d %d\n", cidx, p, q);
          else                 # bottom: reversed -> normal -z
            fprintf (fid, "f %d %d %d\n", cidx, q, p);
          endif
        endfor
      endfor
    endif
  unwind_protect_cleanup
    fclose (fid);
  end_unwind_protect

  printf ("grid2obj: wrote %s (%d vertices, %d rows, %d cols, wrap=%d, caps=%d)\n", ...
          fname, nv, n, m, wrap, caps);

endfunction
