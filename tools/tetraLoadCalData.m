% retrieve bed probe data and reduce
% implement standard procedure to load cal data
function tp = getCalData(n=0, measFile=[], measFileIdeal=[])
    logFile = sprintf('probe%03d.log',n)
    if exist(logFile, 'file') != 2
        cmd=sprintf('ssh 192.168.2.66 ~pi/bin/tailLog.sh > %s',logFile)
        system(cmd)
    end
    [tp,cfg] = loadCalData(logFile, measFile, measFileIdeal);
    probeFile = sprintf('probe%03d.csv')
    if exist(probeFile, 'file') != 2
        cmd=sprintf('cp /tmp/probe.csv probe%03d.csv',n)
        system(cmd)  % save to a file for future convenience
    end
    probeSamplesFile = sprintf('probeSamples%03d.csv',n)
    if exist(probeSamplesFile, 'file') != 2
        cmd=sprintf('./extractProbeSamples.pl < %s > %s',logFile,probeSamplesFile)
        system(cmd)
    end
    tp.probeSamples = load(probeSamplesFile);
    tp.probe_offset = [cfg.probe.x_offset, cfg.probe.y_offset, cfg.probe.z_offset];
    z = tp.probe(:,3);
    tp.bedMedian = median(z);
    tp.bedMean   = mean(z);
    tp.bedStDev  = std(z);
    fprintf(1,'probe_offset=[%g,%g,%.3f]\n', tp.probe_offset);
    fprintf(1,'z stats: [median, mean, SD] = [ %.3f , %.3f , %.4f ]\n',...
            tp.bedMedian, tp.bedMean, tp.bedStDev);

    figure 1; hold off;
    p=tp.probe;ps=tp.probeSamples;z0=tp.probe_offset(3);
    plot3(p(:,1),p(:,2),p(:,3)-z0,'o-');
    xlabel X;ylabel Y;grid on; hold on;
    plot3(ps(:,1),ps(:,2),ps(:,3),'rd-');
    legend('estimate','samples');
    zlabel(sprintf('offset=%.3f',z0));
    title(sprintf('probe%03d',n));
    hold off;
end
    
