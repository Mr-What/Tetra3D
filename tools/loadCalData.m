% load probe, and optionally measured calibration print data
% into a structure, and return.
function tp = loadCalData(logFile, measFile=[], measFileIdeal=[])
    global tetra

    % this should load parameters as echoed from printer.cfg,
    % and load bed-probe results from klippy.log
    tp = loadProbeDataFromKlipperLog(logFile);
    
    if isempty(measFile)
        return
    end

    % add XY measurement data
    if isempty(measFileIdeal)
        if isempty(tetra) || !isfield(tetra, 'measFileIdeal')
            % set tetra.measXYideal elsewhere if you don't want this default!
            tetra.measFileIdeal = "idealDeltaCalMeas10_60.m";
        end
        measFileIdeal = tetra.measFileIdeal;
    else
        tetra.measFileIdeal = measFileIdeal;  % remember for rest of session
    end
    
    xyMeas  = loadAsStruct(measFile);
    xyIdeal = loadAsStruct(measFileIdeal);
    tp = appendTowerPositions(tp.p, tp.probe, xyMeas, xyIdeal);
end
    
