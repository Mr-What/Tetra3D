% load data from a calibration plate probe,
% and compute primary statistics
function pd = tetraCalProbe(probe)

%pp = tetraLoadCalData(n);
%    logFile=sprintf('probe%03d.log');
%    calFile = [logfile(1:end-4),'cal.log']);
%    cmd=sprintf('grep ^PROBE_FID "%s" | sed "s/PROBE_FID......//" > %s',...
%        logFile,calFile);
%    disp(cmd);
%    system(cmd)
% never mind.  I don't need those.  I can work from probe returns only

    cluster = dbscan(probe,8,6);
    pd.probe = probe;
    pd.clusterId=cluster;
    i = find(cluster < 0);
    pd.noCluster=probe(i,:);
    n = max(cluster);
    fprintf(1,'%d clusters, %d not-clustered\n',n,length(i));
    pd.cluster = cell(n,1);
    pd.dimple=zeros(n,3);
    for k=1:n
        i = find(cluster==k);
        clusterSize = length(i);
        pk = probe(i,:);
        pd.cluster(k) = pk;
        m = median(pk,1);
        pMin = estimateLocalMinima2D(pk);
        pd.dimple(k,:) = pMin;
        %q = round(pMin(1:2));
        %dq = pMin(1:2)-q;
        %fprintf(1,'%3d %4d %4d %4d\t%8.3f  %8.3f    %8.3f\n',k,clusterSize,q,dq,pMin(3));
        %fprintf(1,'%3d%4d\t%8.3f  %8.3f    %8.3f\n',k,clusterSize,pMin);
        tit = sprintf('cluster %d, %d probes, minima [%.3f, %.3f, %.3f]',k,clusterSize,pMin);
        ;title(tit);
        disp(tit);
    end

    % ideal locations, for plates so far, will be every 20mm.
    % We can guess ideal locations from probes adequately.
    d0 = 20 * round(pd.dimple(:,1:2)/20);
    [rot,x1,y1] = estimateRotShift(d0,pd.dimple);
    pd.plateRot=rot;
    pd.plateShift = [x1,y1];
    pd.dimpleIdeal = d0;
    pd.dimpleShifted = applyRotShift(rot,x1,y1,d0);
end


function [rot,x0,y0] = estimateRotShift(p0,p1)
    global tetra
    tetra.callCount=0;
    
    initialStep = [1,1,1];
    smallBox = initialStep/2000;
    initialGuess = [0,0,0];
    maxIterations=444;
    dat.p0 = p0;  % set up struct with all data
    dat.p1 = p1;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) rotShiftErr(p,dat),...
   	initialGuess, initialStep, smallBox, maxIterations);
    rot = fit(1);
    x0 = fit(2);
    y0 = fit(3);
end

function err = rotShiftErr(p,dat)
    global tetra
    tetra.callCount = tetra.callCount + 1;
    
    rot = p(1);
    x0 = p(2);
    y0 = p(3);
    p1 = applyRotShift(rot,x0,y0,dat.p0);
    err = dat.p1(:,1:2) - p1;
    err = err .* err;
    err = mean(err(:,1) + err(:,2));
    fprintf(2,'%d %.3f  %.3f  %.3f %.3f\n',tetra.callCount,err, rot,x0,y0);
end

function p1 = applyRotShift(rot,x0,y0,p0)
    c = cosd(rot);
    s = sind(rot);
    p1=p0;
    p1(:,1) = p0(:,1) * c + p0(:,2) * s + x0;
    p1(:,2) = p0(:,2) * c - p0(:,1) * s + y0;
end
