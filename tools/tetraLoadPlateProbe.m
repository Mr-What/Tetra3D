%function pp = tetraLoadPlateProbe(logFile, pattern=[], plateScale=1)
%
%  Load klipper parameters, and calibration plate probe data
%  from a klipper.log
%
%  Supply ideal calibration plate probe locations, pattern,
%  if the plate is not a regular square grid, 20mm spacing.
%  Most common is a hex grid, like:
%       %Define a hex grid, "radius" 3, 18mm apart on center:
%       pattern = 18*hexGrid(3);
%
%  Scale ideal probe pattern by plateScale.
%  Useful for things like printed calibration plates, which may have
%  some shrinkage.  My printed test plated were at scale 101.3/102,
%  from 17*hexGrid(3);  Slight shrinkage.
%
%  An attempt will be made to download last section of klipper.log
%  file using tailLog.sh.  Edit your copy of tailLog.sh to reflect
%  your network/klipper setup.
function pp = tetraLoadPlateProbe(logFile, pattern=[], plateScale=1)
    global tetra

    % if reduced calibration plate probe log file was not present,
    % assume they want most recent probe in klipper log,
    % and download it to given filename
    tetraGetLogFile(logFile);
    
    cfg = klipLoadCfg(logFile);  % either printer.cfg or klippy.log
    p = tetraGetParams(cfg);

    % current tetra macros remove probe_offset from probe report lines.
    % but make sure we retain it, in case we need it.
    probe_offset =  [cfg.probe.x_offset, cfg.probe.y_offset, cfg.probe.z_offset];
    fprintf(1,'probe_offset=[%f,%f,%.3f]\n',probe_offset);

    ppCSV=[logFile(1:end-4),'plate.csv']
    if exist(ppCSV,'file') != 2
        cmd = sprintf('%s/tetraExtractDimpleProbes.sh %s > %s',...
                      tetra.toolPath,logFile,ppCSV)
        system(cmd)
    end
    probe=load(ppCSV);
    timeAndIndex = probe(:,1:2);
    plateProbe = probe(:,3:5);  % strip time and cache index
    % Do NOT adjust for probe_offset.  No offset reported in DIMPLE lines
    %for k=1:3, plateProbe(:,k) = plateProbe(:,k) + probe_offset(k); end

    % compute dimple vertex locations, and arrange all relevant data in struct
    pp = tetraAnalysePlateProbe(plateProbe, pattern, plateScale);
    pp.logFileName = logFile;
    pp.cfg = cfg;
    pp.plateProbeFile = ppCSV;
    pp.p = p.p;
    pd = appendTowerPositions(pp.p, pp.dimple);
    pp.pos = pd.pos;
    pp.probe_offset = probe_offset;
end
