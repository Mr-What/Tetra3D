% this is done in evera tetraRefine*(), so let's make
% it a standard function
function tp = tetraAppendErrorMetrics(tp,err)
    global tetra

    tp.err   = err;

    % retrieve error components
    tp.RMS = tetra.RMS;

    % clear tetra cache, which was a hack to get internal data out
    % of tetraFitErr, which is several calls in the stack into
    % SimplexMinima
    tetra.RMS.bed = 0;
    tetra.RMS.plate = 0;
    tetra.RMS.meas = 0;
end

