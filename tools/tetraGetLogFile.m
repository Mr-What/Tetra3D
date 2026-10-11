% if log file is not present, retrieve tail of log from klipper tetra host
function tetraGetLogFile(logFile)
    global tetra
    if exist(logFile, 'file') == 2
        disp(['Log file ',logFile,' already present.  remove to regenerate.']);
        return
    end
    cmd=sprintf('ssh %s %s/tailLog.sh > %s',tetra.host, ...
                    tetra.hostUtilPath,logFile)
    system(cmd)
end
