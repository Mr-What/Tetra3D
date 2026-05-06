%  Load klipper parameters, and bed probe data
%  from a klipper.log
%
%  Use tail_plippy_log.py to extract last printer configuration
%  data and last bed probe from a long klippy.log before
%  using this.
function tp = loadProbeDataFromKlipperLog(logFile)
    p = loadKlipperCfg(logFile);  % either printer.cfg or klippy.log
    p = getTetraParams(p);
    cmd = sprintf('grep "Result: at .*estimate" "%s" | sed "s/^Result: at//" | sed "s/estimate contact at z=/,/" > /tmp/probe.csv',logFile)
    system(cmd)
    probe =load('/tmp/probe.csv');

    % compute tower positions for all tests points, and store in tp struct
    tp = appendTowerPositions(p.p, probe);
    return
end
