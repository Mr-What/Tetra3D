% load probe, and optionally measured calibration print data
% into a structure, and return.
function [tp,cfg] = loadCalData(logFile, measFile=[], measFileIdeal=[])
    if ischar(logFile)
        % load parameters as echoed from printer.cfg,
        % and load bed-probe results from klippy.log
        [tp0,cfg] = loadProbeDataFromKlipperLog(logFile);
    else
        disp('logFile already loaded. using tetra data cache.');
        tp = logFile;
        cfg=[];
        return
    end

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
