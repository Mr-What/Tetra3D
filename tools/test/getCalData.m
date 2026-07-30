% retrieve bed probe data and reduce
% implement standard part of loading cal data
function tp = getBedProbe(n=0, measFile=[], measFileIdeal=[])
    logFile = sprintf('probe%03d.log',n)
    cmd=sprintf('ssh 192.168.2.66 ~pi/bin/tailLog.sh > %s',logFile)
    system(cmd)
    tp = loadCalData(logFile, measFile, measFileIdeal);
    cmd=sprintf('cp /tmp/probe.csv probe%03d.csv',n)
    system(cmd)  % save to a file for future convenience
    probeSamplesFile = sprintf('probeSamples%03d.csv',n)
    cmd=sprintf('../extractProbeSamples.pl < %s > %s',logFile,probeSamplesFile)
    system(cmd)
    tp.probeSamples = load(probeSamplesFile);
    z = tp.probe(:,3);
    tp.bedMedian = median(z);
    tp.bedMean   = mean(z);
    tp.bedStDev  = std(z);
    fprintf(1,'z stats: [median, mean, SD] = [ %.3f , %.3f , %.4f ]\n',...
            tp.bedMedian, tp.bedMean, tp.bedStDev);
end
    
