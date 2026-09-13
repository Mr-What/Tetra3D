% load probe, and optionally measured calibration print data
% into a structure, and return.
function [tp,cfg] = loadCalData(logFile, measFile=[], measFileIdeal=[])
    global tetra

    if ischar(logFile)
        % this should load parameters as echoed from printer.cfg,
        % and load bed-probe results from klippy.log
        [tp0,cfg] = loadProbeDataFromKlipperLog(logFile);
    else
        disp('logFile already loaded. using tetra data cache.');
        tp = logFile;
        cfg=[];
        return
    end
    
    %-- moved this stuff to loadProbeDataFromKlipperLog
    % copy over any other metadata needed from log
    %probe_offset = [cfg.probe.x_offset, ...
    %                cfg.probe.y_offset, ...
    %                cfg.probe.z_offset];
    %fprintf(2,'probe_offset=[%.3f,%.3f,%.3f]\n',probe_offset);
    %disp('Override probe_offset if necessary.  Otherwise, just dbcont :');
    %keyboard
    %tp.probe_offset = probe_offset;
    
    if isempty(measFile)
        disp('NOTE : No calibration print measurements available.');
        tp = tp0;
        return
    end

    % add XY measurement data
    mf0 = idealTetraMeasFile(measFileIdeal);

    xyMeas  = loadAsStruct(measFile);
    xyIdeal = loadAsStruct(mf0);
    tp = appendTowerPositions(tp0.p, tp0.probe, xyMeas, xyIdeal);
    tp.probe_offset = tp0.probe_offset;  % this is needed for calibrations
end
