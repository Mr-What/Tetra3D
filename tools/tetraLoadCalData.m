% retrieve bed probe data and reduce
% implement standard procedure to load cal data
function tp = tetraLoadCalData(n=0, measFile=[], measFileIdeal=[], plateProbeLog=[], plateScale=1)
    global tetra
    logFile = sprintf(tetra.logFileFmt,n)
    if exist(logFile, 'file') != 2
        %cmd=sprintf('ssh 192.168.2.66 ~pi/bin/tailLog.sh > %s',logFile)
        cmd=sprintf('ssh %s %s/tailLog.sh > %s',tetra.host, ...
                    tetra.hostUtilPath,logFile)
        system(cmd)
    end
    [tp,cfg] = loadCalData(logFile, measFile, measFileIdeal);
    tp.logFileName=logFile;
    tp.measFile = measFile;
    tp.measFileIdeal = measFileIdeal;
    probeFile = sprintf('probe%03d.csv')
    if exist(probeFile, 'file') != 2
        cmd=sprintf('cp /tmp/probe.csv probe%03d.csv',n)
        system(cmd)  % save to a file for future convenience
    end
    probeSamplesFile = sprintf('probeSamples%03d.csv',n)
    if exist(probeSamplesFile, 'file') != 2
        cmd=sprintf('%s/extractProbeSamples.pl < %s > %s',tetra.toolPath,...
                    logFile,probeSamplesFile)
        system(cmd)
    end
    tp.probeSamples = load(probeSamplesFile);

    z0 = cfg.probe.z_offset;
    tp.probe_offset = [cfg.probe.x_offset, cfg.probe.y_offset, z0];
    z = tp.probe(:,3) - z0;
    tp.bedMedian = median(z);
    tp.bedMean   = mean(z);
    tp.bedStDev  = std(z);
    fprintf(1,'probe_offset=[%g,%g,%.3f]\n', tp.probe_offset);
    fprintf(1,'bed z stats: [median, mean, SD] = [ %.3f , %.3f , %.4f ]\n',...
            tp.bedMedian, tp.bedMean, tp.bedStDev);

    if !isempty(plateProbeLog)
        
        ppCSV = [plateProbeLog(1:end-4), 'plate.csv'];
        %[ppp, ppCfg] = loadCalData(plateProbeLog);
        [ppp,ppCfg] = loadProbeDataFromKlipperLog(plateProbeLog);
        if exist(ppCSV,'file') != 2
            cmd = sprintf('%s/tetraExtractDimpleProbes.sh %s > %s',tetra.toolPath,plateProbeLog,ppCSV)
            system(cmd)
        end
        plateProbe = load(ppCSV);  % dimple probe sets
        timeAndIndex = plateProbe(:,1:2);
        plateProbe=plateProbe(:,3:5);
        %scl = 119.3/200;  % 1==ideal (machined), change for different scale from actual plate to ideal drawing
        tp.calPlate = tetraCalProbe(plateProbe,plateScale);  % compute stats of cal plate probe
        tp.calPlate.logFileName = plateProbeLog;
        tp.calPlate.probeFileName=ppCSV;
        tp.calPlate.p = ppp.p;
        pd = appendTowerPositions(tp.calPlate.p, tp.calPlate.dimple);
        tp.calPlate.pos = pd.pos;
        tp.calPlate.probe_offset = ppp.probe_offset;
    end
    
    if bitand(tetra.plotFlags,1)
        figure 1; hold off;
        p=tp.probe;ps=tp.probeSamples;z0=tp.probe_offset(3);
        plot3(p(:,1),p(:,2),p(:,3)-z0,'o-');
        xlabel X;ylabel Y;grid on; hold on;
        plot3(ps(:,1),ps(:,2),ps(:,3),'rd-');
        legend('estimate','samples');
        zlabel(sprintf('offset=%.3f',z0));
        title(sprintf('probe%03d',n));
        hold off;
        if isfield(tp,'calPlate')
            p = tp.calPlate.probe;  % raw probes of calibration plate
            d = tp.calPlate.dimple; % estimated dimple bottoms
            figure 2; hold off;
            plot3(p(:,1),p(:,2),p(:,3),'o');
            grid on;hold on;xlabel X;ylabel Y;
            plot3(d(:,1),d(:,2),d(:,3),'rx');
            legend('plate probes','dimple vertex');
            title(['Cal Plate probes ',ppCSV]);
            hold off
            figure 1
        end
    end
end
    
