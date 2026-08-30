function d = loadBedMesh(filename, meshName)
%LOADBEDMESH Parse a Klipper SAVE_CONFIG bed_mesh section into a struct.
%   d = loadBedMesh(filename, meshName)
%   Only lines beginning with '#*# ' are examined.
%   The target section begins with a line like:
%     #*# [bed_mesh myMeshName]
%   Parsing continues until a blank line, or the start of another section.

  if nargin < 2
    error('loadBedMesh requires filename and meshName');
  end

  if ~ischar(filename) && ~isstring(filename)
    error('filename must be a character array or string');
  end
  if ~ischar(meshName) && ~isstring(meshName)
    error('meshName must be a character array or string');
  end

  filename = char(filename);
  meshName = char(meshName);

  fid = fopen(filename, 'r');
  if fid < 0
    error('Could not open file: %s', filename);
  end
  cleaner = onCleanup(@() fclose(fid));

  targetHeader = sprintf('#*# [bed_mesh %s]', meshName);
  inSection = false;
  foundSection = false;
  d = struct();

  while true
    line = fgetl(fid);
    if ~ischar(line)
      break;
    end

    if ~inSection
      if strcmp(line, targetHeader)
        inSection = true;
        foundSection = true;
      end
      continue;
    end

    if isempty(strtrim(line))
      break;
    end

    if strncmp(line, '#*# ', 4)
      content = line(5:end);
    elseif strncmp(line, '#*#', 3) && isempty(strtrim(line(4:end)))
      break;
    else
      break;
    end

    if isempty(strtrim(content))
      break;
    end

    trimmed = strtrim(content);
    if startsWith(trimmed, '[') && endsWith(trimmed, ']')
      break;
    end

    eqpos = strfind(content, '=');
    if isempty(eqpos)
      continue;
    end

    key = strtrim(content(1:eqpos(1)-1));
    value = strtrim(content(eqpos(1)+1:end));
    field = matlab.lang.makeValidName(key);

    if strcmp(key, 'points')
      rows = {};
      while true
        pos = ftell(fid);
        nextline = fgetl(fid);
        if ~ischar(nextline)
          break;
        end

        if isempty(strtrim(nextline))
          break;
        end

        if strncmp(nextline, '#*# ', 4)
          nextcontent = nextline(5:end);
        elseif strncmp(nextline, '#*#', 3) && isempty(strtrim(nextline(4:end)))
          break;
        else
          fseek(fid, pos, 'bof');
          break;
        end

        nexttrim = strtrim(nextcontent);
        if isempty(nexttrim)
          break;
        end
        if startsWith(nexttrim, '[') && endsWith(nexttrim, ']')
          fseek(fid, pos, 'bof');
          break;
        end
        if ~isempty(strfind(nextcontent, '='))
          fseek(fid, pos, 'bof');
          break;
        end

        nums = sscanf(nexttrim, '%f,').';
        if isempty(nums)
          nums = sscanf(nexttrim, '%f').';
        end
        rows{end+1} = nums;
      end

      if isempty(rows)
        d.(field) = [];
      else
        ncols = numel(rows{1});
        points = zeros(numel(rows), ncols);
        for i = 1:numel(rows)
          if numel(rows{i}) ~= ncols
            error('Inconsistent number of columns in points data for mesh %s', meshName);
          end
          points(i, :) = rows{i};
        end
        d.(field) = points;
      end
      continue;
    end

    numval = str2double(value);
    if ~isnan(numval)
      d.(field) = numval;
    else
      d.(field) = value;
    end
  end

  if ~foundSection
    error('Bed mesh section not found: %s', meshName);
  end
end
