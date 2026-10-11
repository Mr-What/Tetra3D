%  Load klipper parameters, and calibration plate probe data
%  from a klipper.log
%
%  Use tail_plippy_log.py to extract last printer configuration
%  data and last bed probe from a long klippy.log before
%  using this.
function pp = tetraLoadPlateProbeFromLog(logFile, plateScale=1)
    global tetra
    cfg = klipLoadCfg(logFile);  % either printer.cfg or klippy.log
    p = tetraGetParams(cfg);

    % log contains probe offset.  Remove it.
    % we need to know actual servo locations.
    % we will compute error as difference from expected
    % probe trigger point (not z=0 but z=z_offset)
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
    for k=1:3, plateProbe(:,k) = plateProbe(:,k) + probe_offset(k); end

    % compute dimple vertex locations, and arrange all relevant data in struct
    pp = tetraCalProbe(plateProbe, plateScale);
    pp.logFileName = logFile;
    pp.plateProbeFile = ppCSV;
    pp.p = p.p;
    pd = appendTowerPositions(pp.p, pp.dimple);
    pp.pos = pd.pos;
    pp.probe_offset = probe_offset;
end
