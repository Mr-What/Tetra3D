% load data from a calibration plate probe,
% and compute primary statistics
function pd = tetraCalProbe(probe, plateScale=1)

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
        %pk = nearMinima(pk);
        %pMin = estimateLocalMinima2D(pk); % found to be err prone
        %pMin = median(pk); pMin(3) = min(pk(:,3)); % less accurate, but more robust
        [pMin,m] = estimateConeFit(pk);
        if (m < 0.01) % not very cone-shaped
            fprintf(1,'cluster %d not very cone-shaped, using median.\n',k);
            pMin = median(pk);
            pMin(3) = min(pk(:,3)); % less accurate, but more robust
            disp(pMin);
        end
        %disp(round(1000*(pMin-pMin1)));
        pd.dimple(k,:) = pMin;
        tit = sprintf('cluster %d, %d probes, minima [%.3f, %.3f, %.3f]',k,clusterSize,pMin);
        disp(tit);
    end

    % ideal locations, for plates so far, will be every 20mm.
    % We can guess ideal locations from probes adequately.
    d0 = 20 * round(pd.dimple(:,1:2)/20);
    d0 = plateScale * d0;  % initial printed plates had some shrinkage
    [rot,x1,y1] = estimateRotShift(d0,pd.dimple);
    pd.plateScale=plateScale;
    pd.plateRot=rot;
    pd.plateShift = [x1,y1];
    pd.dimpleIdeal = d0;
    pd.dimpleShifted = applyRotShift(rot,x1,y1,d0);
end

% throw out some initial points.  they seem to bias poly fit
function pk = nearMinima(pk0)
    [lo,ilo] = min(pk0(:,3));
    lo=pk0(ilo(1),:);
    d = [pk0(:,1)-lo(1),pk0(:,2)-lo(2)];
    d = d .* d;
    d = sqrt(sum(d,2));
    i = find(d < .4);
    pk = pk0(i,:);
end

function [rot,x0,y0] = estimateRotShift(p0,p1)
    global tetra
    tetra.callCount=0;
    tetra.callPeriod=5;
    
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
    
    rot = p(1);
    x0 = p(2);
    y0 = p(3);
    p1 = applyRotShift(rot,x0,y0,dat.p0);
    err = dat.p1(:,1:2) - p1;
    err = err .* err;
    err = mean(err(:,1) + err(:,2));
    if (mod(tetra.callCount, tetra.callPeriod) == 0), ...
        fprintf(2,'%d %.3f  %.3f  %.3f %.3f\n',tetra.callCount,err, rot,x0,y0); end
    tetra.callCount = tetra.callCount + 1;
end

function p1 = applyRotShift(rot,x0,y0,p0)
    c = cosd(rot);
    s = sind(rot);
    p1=p0;
    p1(:,1) = p0(:,1) * c + p0(:,2) * s + x0;
    p1(:,2) = p0(:,2) * c - p0(:,1) * s + y0;
end


function [tip,m] = estimateConeFit(q)
    global tetra
    tetra.callCount=0;
    tetra.callPeriod=10;
    
    initialStep = [1,1,1,.04];
    smallBox = [initialStep(1:3)/2000, .0001];
    
    initialGuess = [median(q(:,1:2)),min(q(:,3)),.26];  % a little less than tan(15), for 150 deg tip tool
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) coneFitErr(p,q),...
   	initialGuess, initialStep, smallBox, maxIterations);
    tip=fit(1:3);
    m = fit(4);
    if bitand(tetra.plotFlags,4), plotConeFit(q,fit); end
end

function err = coneFitErr(p,dat)
    global tetra

    x0 = p(1);
    y0 = p(2);
    z0 = p(3);
    m  = p(4);
    dxy = [dat(:,1) - x0, dat(:,2) - y0];
    r = norm(dxy,2,'rows');
    z = m*r;
    err = dat(:,3) - z0 - z;
    err = mean(err .* err);
    if (m < 0.01)
        %disp('applying penalty for inverted cone');
        weight = (1-m-0.011)^4;
        err = err * weight;
    end
    if (mod(tetra.callCount, tetra.callPeriod) == 0) && bitand(tetra.plotFlags,4) , ...
        fprintf(2,'%d %.6f  %.2f %.2f %.2f  %.4f\n',tetra.callCount,err, p); end
    tetra.callCount = tetra.callCount + 1;
end

function plotConeFit(p,fit)
    %xx = linspace(floor(min(p0(:,1))),ceil(max(p0(:,1))),20);
%yy = linspace(floor(min(p0(:,2))),ceil(max(p0(:,2))),20);
%    [xg,yg] = meshgrid(xx,yy);
%    zz = evalPoly2D(xg,yg,coef);
    figure 1
    hold off
    plot3(p(:,1),p(:,2),p(:,3),'mo');
    grid on
    hold on
    for a=0:30:355
        plot3(fit(1)+[0,2*cosd(a)], fit(2)+[0,2*sind(a)], fit(3)+[0,fit(4)*2]);
    end
    %mesh(xg,yg,zz);
    tit = sprintf('%d probes, minima [%.3f, %.3f, %.3f]',size(p,1),fit(1:3));
    title(tit);
    hold off
    disp('any key to continue...');kbhit();
end
