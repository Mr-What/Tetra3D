function cfg = loadKlipperCfg(filename)
% LOADKLIPPERCFG  Parse a Klipper printer.cfg file into a struct of structs.
%
%   cfg = loadKlipperCfg('printer.cfg')
%
% Returns a struct where each field corresponds to a config section, e.g.:
%   cfg.printer.delta_radius        -> double scalar or row vector
%   cfg.printer.delta_angles        -> double row vector  [210, 330, 90]
%   cfg.stepper_a.position_endstop  -> double scalar
%   cfg.printer.kinematics          -> char string  'tilted_delta'
%
% Klipper accepts both '=' and ':' as key/value separators; both are handled.
% Numeric values (scalars and comma/space-separated lists) are automatically
% converted to double scalars or row vectors.  Non-numeric values are kept
% as strings.
%
% Multi-line values (continuation lines indented with whitespace) are
% concatenated with a single space separator before conversion.
%
% Comment lines (starting with # or ;) and blank lines are ignored.

  cfg = struct();
  current_section = '';
  current_key     = '';

  fid = fopen(filename, 'r');
  if fid < 0
    error('loadKlipperCfg: cannot open file: %s', filename);
  end

  while ~feof(fid)
    raw = fgetl(fid);
    if ~ischar(raw)
      break;
    end

    % Strip trailing whitespace
    line = strtrim(raw);

    % Skip blank lines and full-line comment lines
    if isempty(line) || line(1) == '#' || line(1) == ';'
      current_key = '';   % breaks continuation
      continue;
    end

    % --- Section header  [section name] ------------------------------------
    tok = regexp(line, '^\[([^\]]+)\]', 'tokens', 'once');
    if ~isempty(tok)
      current_section = sanitize_name(strtrim(tok{1}));
      current_key     = '';
      if ~isfield(cfg, current_section)
        cfg.(current_section) = struct();
      end
      continue;
    end

    % No section seen yet — skip
    if isempty(current_section)
      current_key = '';
      continue;
    end

    % --- Continuation line (raw line starts with whitespace) ---------------
    if ~isempty(raw) && (raw(1) == ' ' || raw(1) == char(9))
      if ~isempty(current_key)
        old = cfg.(current_section).(current_key);
        if isnumeric(old)
          old = num2str(old, '%.10g ');
        end
        combined = strtrim([old ' ' line]);
        cfg.(current_section).(current_key) = autoconvert(combined);
      end
      continue;
    end

    % --- Key = value  OR  Key: value ---------------------------------------
    % Split on the first '=' or ':', whichever comes first.
    sep = regexp(line, '[=:]', 'once');
    if ~isempty(sep)
      key = sanitize_name(strtrim(line(1:sep-1)));
      val = strtrim(line(sep+1:end));
      % Strip inline comments  (# or ;)
      val = regexprep(val, '\s*[#;].*$', '');
      val = strtrim(val);
      if isempty(key)
        current_key = '';
        continue;
      end
      current_key = key;
      cfg.(current_section).(current_key) = autoconvert(val);
      continue;
    end

    % Anything else resets continuation
    current_key = '';
  end

  fclose(fid);
end


function val = autoconvert(s)
% Try to interpret s as a numeric scalar or row vector.
% str2num handles space/comma-separated lists and scientific notation.
% Falls back to the raw string if the value is not purely numeric.
  num = str2num(s);   %#ok<ST2NM>
  if ~isempty(num)
    val = num;
  else
    val = s;
  end
end


function name = sanitize_name(s)
% Convert a section/key string into a valid Octave field name.
%   - Replace runs of non-alphanumeric characters with '_'
%   - Ensure it doesn't start with a digit
  name = regexprep(s, '[^A-Za-z0-9]+', '_');
  name = regexprep(name, '^_+', '');
  name = regexprep(name, '_+$', '');
  if isempty(name) || (name(1) >= '0' && name(1) <= '9')
    name = ['x_' name];
  end
end
