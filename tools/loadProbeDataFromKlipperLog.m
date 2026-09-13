%  Load klipper parameters, and bed probe data
%  from a klipper.log
%
%  Use tail_plippy_log.py to extract last printer configuration
%  data and last bed probe from a long klippy.log before
%  using this.
function [tp,cfg] = loadProbeDataFromKlipperLog(logFile)
    cfg = loadKlipperCfg(logFile);  % either printer.cfg or klippy.log
    p = getTetraParams(cfg);
    cmd = sprintf('grep "Result: at .*estimate" "%s" | sed "s/^Result: at//" | sed "s/estimate contact at z=/,/" > /tmp/probe.csv',logFile);
    disp(cmd)
    system(cmd)
    probe =load('/tmp/probe.csv');

    % log contains probe offset.  Remove it.
    % we need to know actual servo locations.
    % we will compute error as difference from expected
    % probe trigger point (not z=0 but z=z_offset)
    probe_offset =  [cfg.probe.x_offset, cfg.probe.y_offset, cfg.probe.z_offset]
    fprintf(1,'probe_offset=[%.3f,%.3f,%.3f]\n',probe_offset);
    %disp('enter probeOffset=[0,0,0] to disable probe offset, then dbcont');
    %keyboard
    for k=1:3, probe(:,k) = probe(:,k) + probe_offset(k); end
    
    % compute tower positions for all tests points, and store in tp struct
    tp = appendTowerPositions(p.p, probe);
    tp.probe_offset = probe_offset;
    return
end
