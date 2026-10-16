%  Load klipper parameters, and bed probe data
%  from a klipper.log
%
%  Use tail_plippy_log.py to extract last printer configuration
%  data and last bed probe from a long klippy.log before
%  using this.
function [tp,cfg] = loadProbeDataFromKlipperLog(logFile)
    global tetra
    cfg = klipLoadCfg(logFile);  % either printer.cfg or klippy.log
    probe_offset =  [cfg.probe.x_offset, cfg.probe.y_offset, cfg.probe.z_offset];
    p = tetraGetParams(cfg);
    if 0 % stop using Results reports that have probe offset in them
        %cmd = sprintf('grep "Result: at .*estimate" "%s" | sed "s/^Result: at//" | sed "s/estimate contact at z=/,/" > /tmp/probe.csv',logFile);
        cmd = sprintf('%s/klipExtractProbeResults.sh "%s" > /tmp/probe.csv',...
                      tetra.toolPath, logFile)
        system(cmd)
        probe =load('/tmp/probe.csv');

        % log contains probe offset.  Remove it.
        % we need to know actual servo locations.
        % we will compute error as difference from expected
        % probe trigger point (not z=0 but z=z_offset)
        fprintf(1,'probe_offset=[%.3f,%.3f,%.3f]\n',probe_offset);
        for k=1:3, probe(:,k) = probe(:,k) + probe_offset(k); end
    else
        probeCSV=[logFile(1:end-4),'.csv'];
        cmd = sprintf('%s/tetraExtractProbeResults.sh "%s" > "%s"',...
                      tetra.toolPath, logFile, probeCSV)
        system(cmd)
        try
            tprobe =load(probeCSV);
            probeTime = tprobe(:,1);
            probe = tprobe(:,2:4);
        catch err
            disp('No "PROBE_RESULTS" entries, not using tetra PROBEZ macro?  Try klipper probe results.');
            cmd = sprintf('%s/klipExtractProbeResults.sh "%s" > "%s"',...
                      tetra.toolPath, logFile, probeCSV)
            try
                probe =load(probeCSV);
            catch err
                disp('No probe results found.');
                tp=[];
            end
        end
    end

    % compute tower positions for all tests points, and store in tp struct
    tp = appendTowerPositions(p.p, probe);
    tp.probe_offset = probe_offset;
end
