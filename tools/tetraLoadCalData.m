% function tp = tetraLoadCalData(logFile, plateProbe=[], measFile=[], measFileIdeal=[])
%
%    Load bed probe data from a klipper log file
%    process data into fields for calibration
%
% Pass plateProbe=tetraLoadPlateProbe(...) to include plate probe data.
%
%         Use of a measured print, measFile and measFileIdeal,
%         are depricated for calibration plate probe.
function tp = tetraLoadCalData(logFile, plateProbe=[], measFile=[], measFileIdeal=[])
    global tetra
    %logFile = sprintf(tetra.logFileFmt,n)
    tetraGetLogFile(logFile);
    [tp,cfg] = tetraLoadCal(logFile, measFile, measFileIdeal);
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
        figure 1;
        tetraPlotBedProbe(tp.probe, tp.probeSamples, tp.probe_offset(3), logFile);
        if isfield(tp,'calPlate')
            figure 2;
            tetraPlotPlateProbe(tp.calPlate.probe,  ... % all probes
                                tp.calPlate.dimple, ... % estimated dimple vertices
                                tp.calPlate.logFileName);
            figure 1
        end
    end
end

function tetraPlotBedProbe(probeResults, probeSamples, z0=0, tit='bed probes')
    hold off;
    %p=tp.probe;ps=tp.probeSamples;z0=tp.probe_offset(3);
    plot3(probeResults(:,1),probeResults(:,2),probeResults(:,3)-z0,'o-');
    view(0,90);
    xlabel X;ylabel Y;
    lim = max(abs(probeResults(:)));
    lim = 5 * ceil(lim/5);
    xlim([-lim,lim]);
    ylim([-lim,lim]);
    grid on;
    hold on;
    plot3(probeSamples(:,1),probeSamples(:,2),probeSamples(:,3),'rd-');
    legend('estimate','samples');
    zlabel(sprintf('offset=%.3f',z0));
    title(tit);
    hold off;
end

function tetraPlotPlateProbe(probes,  vertex, tit='')
    hold off;
    plot3(probes(:,1),probes(:,2),probes(:,3),'o');
    grid on;hold on;xlabel X;ylabel Y;
    view(0,90);
    plot3(vertex(:,1),vertex(:,2),vertex(:,3),'rx');
    legend('plate probes','dimple vertex');
    title(['Cal Plate probes ',tit]);
    hi = max(abs(probes(:)));
    hi = 5 * ceil(hi/5);
    xlim([-hi,hi]);
    ylim([-hi,hi]);
    hold off
end
