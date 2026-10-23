% retrieve bed probe data and reduce
% implement standard procedure to load cal data
function tp = tetraLoadCalData(logFile, plateProbe=[], measFile=[], measFileIdeal=[])
    global tetra
    %logFile = sprintf(tetra.logFileFmt,n)
    tetraGetLogFile(logFile);
    [tp,cfg] = loadCalData(logFile, measFile, measFileIdeal);
    tp.logFileName=logFile;
    tp.measFile = measFile;
    tp.measFileIdeal = measFileIdeal;
    probeFile = [logFile(1:end-4),'.csv']
    if exist(probeFile, 'file') != 2
        % this one gets PROBE RESULTS lines, which have offset removed
        cmd=sprintf('%s/tetraExtractProbeResults.sh "%s" > "%s"',...
                    tetra.toolPath, logFile, probeFile)
        system(cmd)
    end
    probe = load(probeFile);  % PROBE RESULTS logs are toolhead position, no probe offset
    probeTime=probe(:,1);
    tp.probe = probe(:,2:4);
    probeSamplesFile = [logFile(1:end-4),'samples.csv'];
    if exist(probeSamplesFile, 'file') != 2
        cmd=sprintf('%s/klipExtractProbeSamples.sh %s > %s',tetra.toolPath,...
                    logFile,probeSamplesFile)
        system(cmd)
    end
    tp.probeSamples = load(probeSamplesFile);

    z0 = cfg.probe.z_offset;
    tp.probe_offset = [cfg.probe.x_offset, cfg.probe.y_offset, z0];
    z = tp.probe(:,3);  % tetra PROBE RESULTS lines have no probe offset applied : z = tp.probe(:,3) - z0;
    tp.bedMedian = median(z);
    tp.bedMean   = mean(z);
    tp.bedStDev  = std(z);
    fprintf(1,'probe_offset=[%g,%g,%.3f]\n', tp.probe_offset);
    fprintf(1,'bed z stats: [median, mean, SD] = [ %.3f , %.3f , %.4f ]\n',...
            tp.bedMedian, tp.bedMean, tp.bedStDev);

    if !isempty(plateProbe)
        %   tetraGetLogFile(plateProbeLog);  % make sure plate probe log is available
        %    tp.calPlate = tetraLoadPlateProbeFromLog(plateProbeLog,plateScale);
        % plate probes might start getting more metadata.  load them elsewhere.
        tp.calPlate = plateProbe;
    end
    
    if bitand(tetra.plotFlags,1)
        figure 1; hold off;
        p=tp.probe;ps=tp.probeSamples;z0=tp.probe_offset(3);
        plot3(p(:,1),p(:,2),p(:,3)-z0,'o-');
        view(0,90);
        xlabel X;ylabel Y;grid on; hold on;
        plot3(ps(:,1),ps(:,2),ps(:,3),'rd-');
        legend('estimate','samples');
        zlabel(sprintf('offset=%.3f',z0));
        title(logFile);
        hold off;
        if isfield(tp,'calPlate')
            p = tp.calPlate.probe;  % raw probes of calibration plate
            d = tp.calPlate.dimple; % estimated dimple bottoms
            figure 2; hold off;
            plot3(p(:,1),p(:,2),p(:,3),'o');
            grid on;hold on;xlabel X;ylabel Y;
            view(0,90);
            plot3(d(:,1),d(:,2),d(:,3),'rx');
            legend('plate probes','dimple vertex');
            title(['Cal Plate probes ',tp.calPlate.plateProbeFile]);
            hold off
            figure 1
        end
    end
end
