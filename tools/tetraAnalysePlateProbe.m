% load data from a calibration plate probe,
% and compute primary statistics
%
%    probe(n,3)   -- locations of probe triggers
%    plateScale   -- scale of plate from nominal, 20mm probe spacing [1]
%                    initial 3D printed plates tended to have some
%                    shrinkage, so multiply ideal locations by this number
%    pattern      --   flags :
%                      1 -- fixed pattern around rough center estimate
%                            0 --> probes were searching for center
%                      2 -- Assume dimple slope is tan(15)
%                            0 --> fit slope also
%
% ------- rim probe: 
% Estimate dimple vertices from a probe which makes a guess
% of dimple vertex from few probes, then takes several
% probes around the dimple.
%
% This might be more accurate than working from a search
% for the dimple center by probing, since probes
% near the bottom may be dominated by noise and slop,
% and hard to use.
function pd = tetraAnalysePlateProbe(probe, plateScale=1, pattern=3)
    cluster = dbscan(probe,8,11);

    % find estimated vertex and wall slope for all identified clusters
    pd = clusterConeFits(probe,cluster);

    % prune cluster lists in pd, containing only the "good" ones
    pd = appendGoodConeFits(pd);
    
    
    % re-compute with fixed dimple wall slope
    [dimple,q] = fixedConeFits(pd.cluster,pd.dimpleSlope);
    pd.dimple = dimple;
    pd.q = q;

    % ------------------------------ Store ideal dimple vertex locations
    % ideal locations, for plates so far, will be every 20mm.
    % We can guess ideal locations from probes adequately.
    d0 = 20 * round(pd.dimple(:,1:2)/20);
    d0 = plateScale * d0;  % initial printed plates had some shrinkage, plateScale ~< 1
    pd.plateScale = plateScale;
    pd.dimpleIdeal = d0;

    % ------------------------------------- weights for measured dimples
    [rot, x1, y1, w] = weightedRigidTransform2D(dimple, q, d0);
    pd.plateRot = rot;
    pd.plateShift = [x1,y1];
    pd.w = w;

    % set up a function which can rapidly compute MSE between best
    % fit rigid transform from dimpleIdeal to a given set
    % of measured or simulated points.
    pd.fitMSE = tetraPlateFitErrFactory(d0,w);
end

% ------------------- estimate vertex and slope for all measurement clusters
%   m0 -- designed dimple wall slope
function pd = clusterConeFits(probe, cluster, m0=tand(15))
    pd.probe = probe;
    pd.clusterId=cluster;
    i = find(cluster < 0);
    pd.noCluster=probe(i,:);
    n = max(cluster);
    fprintf(1,'%d clusters, %d not-clustered\n',n,length(i));

    pd.clusterAll = cell(n,1);
    pd.dimpleAll=zeros(n,3);
    mv=[];  % fit slope, all clusters
    qm={};  % fit quality, all clusters
    for k=1:n
        i = find(cluster==k);
        clusterSize = length(i);
        pk = probe(i,:);
        pd.clusterAll{k} = pk;

        % estimate dimple vertex and slope for all clusters
        [pMin,m,qk] = coneFitGN(pk, m0, .3);

        pd.dimpleAll(k,:) = pMin;
        mv(k) = m;
        qm{k} = qk;
        
        fprintf(1,'cluster %d, %d probes, vertex=[%.3f, %.3f, %.3f]; m=%.4f;',...
                k,clusterSize,pMin,m);
        fprintf(1,'  RMS=%.4f; diag_Cxy=[%.3g, %.3g];\n',...
                qk.rms, qk.C(2,2), qk.C(3,3));
    end
    pd.mAll=mv;
    pd.qAll=qm;
end

% --------------------- prune cluster lists in pd, containing only the "good" ones
function pd = appendGoodConeFits(pd)
    n = rows(pd.dimpleAll);
    %pd.ok = goodConeFits(pd);  % gate out bad fits here
    pd.ok = [1:n]; %pd.ok([3,5,9])=[]; % temp until we implement goodConeFits

    pd.cluster = pd.clusterAll(pd.ok);
    m = pd.mAll(pd.ok);
    pd.mFit = m;
    pd.dimpleSlope = median(m);
    fprintf(1,'Estimated slope=%.4f; expected=%.4f;\n',pd.dimpleSlope,tand(15));
end

% --------------------------------- compute fits given dimple wall slope
function [dimple,q] = fixedConeFits(cluster,m,rMin=.3)
    n = length(cluster);
    q=cell(n,1);
    dimple = zeros(n,3);
    for k=1:n
        pk = cluster{k};
        [pMin,qk] = coneFitFixedGN(pk, m, rMin);
        dimple(k,:) = pMin;
        %qk.sigxy = sqrt((qk.C(2,2) + qk.C(3,3))/2);
        q{k} = qk;
        
        fprintf(1,'cluster %d, %d probes, vertex=[%.3f, %.3f, %.3f];',k,rows(pk),pMin);
        fprintf(1,'  RMS=%.4f; diag_Cxy=[%.3g, %.3g];\n',...
                qk.rms, qk.C(2,2), qk.C(3,3));
    end
end

% ------------------------------------- weights for measured dimples
function [rot, x1, y1, w, s0sq] = weightedRigidTransform2D(vMeasured, q, v0)
%[rot,x1,y1] = estimateRotShift(d0,pd.dimple);
    n = rows(v0);
    %for k=1:n  % I'm not sure if I can extract vectors from fields cell arrays
    %    C = q{k}.C;
    %    rms = q{k}.rms;
    %    ms(k) = rms*rms;
    %    sigxy(k) = sqrt( (C(2,2) + C(3,3))/2 );
    %end
    sigxy = cellfun(@(s) sqrt((s.C(2,2) + s.C(3,3))/2), q);   % n x 1
    sigxy(!isfinite(sigxy)) = 1;          % bad fit -> ~zero weight
    s0min = 0.005^2;                      % keeps weights finite
    w = ones(n,1)/n;
    for it=1:9
        xyMeas = vMeasured(:,1:2);
        [rot,x1,y1] = rigidTransform2D(xyMeas, v0, w);
        res  = xyMeas - applyRigidTransform2D(v0, rot, x1, y1);
        v2   = sum(res(:).^2) / (2*n - 3);          % per-axis variance of plate residuals
        s0sq = max(s0min, v2 - mean(sigxy.^2));
        wPrev = w;
        w = 1 ./ (sigxy.^2 + s0sq);
        w = w / sum(w);
        
        d = w - wPrev;
        d = sum(d .* d);
        if (d < 1e-5)
            break
        end
    end
    [rot,x1,y1] = rigidTransform2D(xyMeas, v0, w);
end

% ---------------- best fit cone vertex, given assumed dimple wall slope
function v = estimateConeFitFixed(pk, m=tand(15))
    global tetra
    tetra.callCount=0;
    tetra.callPeriod=10;

    initialStep = [1,1,.5];
    smallBox = [.005, .005, .005];
    [zMin, iMin] = min(pk(:,3));
    initialGuess = pk(iMin,:);
    maxIterations=222;
    [v,nEval,status,err] = SimplexMinimize(...
        @(p) coneFitErrFixed(p,m,pk),...
   	initialGuess, initialStep, smallBox, maxIterations);
    
    if bitand(tetra.plotFlags,4)
        plotFitConeR(m,v,pk);
        disp('for 3D, enter :    plotFitCone(m,v,pk);');
        keyboard
        %plotFitCone(m,v,pk);
    end
end

% Gauss-Newton estimate for best fit cone, fixed slope
% Set rmin to something reasonable, like .2mm to omit
% probes near the estimated vertex in the solution
function [v, q] = coneFitFixedGN(pk, m, rmin=-1, maxIter=33)
    x = pk(:,1); y = pk(:,2); z = pk(:,3);
    [~,i0] = min(z);
    c = [x(i0), y(i0)];                     % same starting guess as before
    for k = 1:maxIter
        d = [x-c(1), y-c(2)];
        r = sqrt(sum(d.^2,2));
        if (rmin < 0)
            %keep = true(size(r));
            u = d ./ r;
            u(r<.0000001,:)=0;  % handle divide by zero err
            A = [ones(size(r,1),1), -m*u];
            b = z - m*r;
        else
            keep = r > rmin;                    % direction undefined at the apex
            u = d(keep,:) ./ r(keep);
            A = [ones(nnz(keep),1), -m*u];
            b = z(keep) - m*r(keep);
        end
        s = A \ b;                          % [z0, dx, dy]
        c = c + s(2:3)';
        if norm(s(2:3)) < 1e-6, break; end
    end
    z0  = s(1);
    v   = [c, z0];
    if nargout < 2, return; end
    q.d=d;
    q.b=b;
    q.A=A;
    res = b - A*s;
    q.res=res;
    q.rms = sqrt(mean(res .^ 2));
    q.C   = (res'*res/(numel(b)-3)) * inv(A'*A);   % 3x3 covariance of [z0 dx dy]
end

% similar for free m
function [v, m, q] = coneFitGN(pk, m0=tand(15), rmin=-1, rmax=12, maxIter=22)
    x = pk(:,1);
    y = pk(:,2);
    z = pk(:,3);
    [zMin,i0] = min(z);
    c = [x(i0), y(i0)];
    m = m0;
    for k = 1:maxIter
        d = [x-c(1), y-c(2)];
        r = sqrt(sum(d.^2,2));
        keep = (r > rmin) & (r < rmax);
        rk = r(keep);
        u  = d(keep,:) ./ max(rk, 1e-12);
        A  = [ones(nnz(keep),1), -m*u, rk];
        b  = z(keep) - m*rk;
        s  = A \ b;                          % [z0, dx, dy, dm]
        c  = c + s(2:3)';
        m  = m + s(4);
        if norm(s(2:3)) < 1e-5 && abs(s(4)) < 1e-6, break; end
    end
    v = [c, s(1)];
    q.res = b - A*s;
    q.rms = sqrt(mean((q.res .^ 2)));
    q.C   = (q.res' * q.res / (numel(b)-4)) * inv(A'*A);   % 4x4 covariance [z0 dx dy dm]
    cA = cond(A);
    if cA > 1e3
        warning('coneFitFreeGN: ill-conditioned (cond=%.0f), m poorly determined', cA);
    end
    q.sigxy = sqrt((q.C(2,2) + q.C(3,3))/2);
end
    
function [v,m] = estimateConeFit(pk, m0=tand(15))
    global tetra
    tetra.callCount=0;
    tetra.callPeriod=10;

    initialStep = [1,1,.2,.02];
    smallBox = [.005, .005, .005, .0001];
    [zMin, iMin] = min(pk(:,3));
    initialGuess = [pk(iMin,:),m0];
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) coneFitErr(p,m,pk),...
   	initialGuess, initialStep, smallBox, maxIterations);
    v=fit(1:3);
    m=fit(4);
    if bitand(tetra.plotFlags,4)
        plotFitConeR(m,v,pk);
        plotFitCone(m,v,pk);
    end
end

function err = coneFitErrFixed(p,m,pk)
    err = coneFitErr([p,m],pk);
end

function err = coneFitErr(p,pk)
    global tetra

    m = p(4);
    r = norm([pk(:,1)-p(1), pk(:,2)-p(2)],2,'rows');
    err = pk(:,3) - p(3) - m*r;
    err=mean(err .* err);

    if (mod(tetra.callCount, tetra.callPeriod) == 0) && bitand(tetra.plotFlags,4) , ...
            fprintf(2,'%d %.6f  %.3f %.3f %.3f\t%.3f\n',tetra.callCount,err, p); end
    tetra.callCount = tetra.callCount + 1;
end

% 3d cone err plot
function plotFitCone(m,v,p)
    figure 1
    hold off
    plot3(p(:,1)-v(1),p(:,2)-v(2),p(:,3)-v(3),'mo');
    grid on
    hold on
    zt = 1.4; % top of reference cone
    rt = zt/m;  % radius at top of reference cone
    for a=0:30:355
        plot3([0,rt*cosd(a)], [0,rt*sind(a)], [0,zt]);
    end
    a=[0:2:360];
    for z=.25:.25:zt
        r = z / m;
        x = r * cosd(a);
        y = r * sind(a);
        zc = zeros(1,length(a)) + z;
        plot3(x,y,zc);
    end
    xlim([-5,5]);
    ylim([-5,5]);
    zlim([-.5,1.5]);
    view(0,90);
    tit = sprintf('%d probes, vertex [%.3f, %.3f, %.3f]',size(p,1),v);
    title(tit);
    disp(tit);
    xlabel(sprintf('X(mm) slope=%.3f[0.268]',m));
    ylabel Y
    hold off
    %disp('any key to continue...');kbhit();
    %keyboard
end

% 2d cone err plot
function plotFitConeR(m,v,p)
    r = norm([p(:,1)-v(1),p(:,2)-v(2)],2,'rows');
    figure 1
    hold off
    plot(r,p(:,3)-v(3),'mo');
    grid on
    hold on
    zt = 1.4; % top of reference cone
    rt = zt/m;  % radius at top of reference cone
    plot([0,rt],[0,zt],'r');
    axis([0,5,-0.2,1.4]);
    tit = sprintf('%d probes, vertex [%.3f, %.3f, %.3f]',size(p,1),v);
    title(tit);
    disp(tit);
    xlabel(sprintf('r(mm) slope=%.3f[0.268]',m));
    ylabel Z
    hold off
    %disp('any key to continue...');kbhit();
    %keyboard
end

% --------------------------- parabolic fit to probes used in search

function err = parabFitErr(p,dat)
    global tetra

    x0 = p(1);
    y0 = p(2);
    z0 = p(3);
    c1 = p(4);
    c2 = p(5);
    dxy = [dat(:,1) - x0, dat(:,2) - y0];
    r = norm(dxy,2,'rows');
    z = z0 + c1*r + c2 * (r .* r);
    if 0
        % z-error
        err = dat(:,3) - z;
        %err = mean(abs(err));    % MAE z-error
        err = mean(err .* err);  % MSE z-error
    else
        % r-error
        disc = c1 * c1 - 4 * c2 *(z0-dat(:,3));
        disc(disc<0) = 999; % large err
        disc = sqrt(disc);
        ra=(-c1+disc) / (2*c2);
        %rb=(-c1-disc) / (2*c2);
        err = r - ra;
        %err = mean(abs(err)); %MAE
        err = mean(err .* err); % MSE
    end
        
    if (mod(tetra.callCount, tetra.callPeriod) == 0) && bitand(tetra.plotFlags,4) , ...
        fprintf(2,'%d %.6f  %.2f %.2f %.2f  %.4f\n',tetra.callCount,err, p); end
    tetra.callCount = tetra.callCount + 1;
end

function pMin = estimateConeFitSearch(pk)
        %pk = nearMinima(pk);
        %pMin = estimateLocalMinima2D(pk); % found to be err prone
        %pMin = median(pk); pMin(3) = min(pk(:,3)); % less accurate, but more robust
        if 0
            [pMin,m] = estimateConeFit(pk);
            if (m < 0.01) % not very cone-shaped
                fprintf(1,'cluster %d not very cone-shaped, using median.\n',k);
                pMin = median(pk);
                pMin(3) = min(pk(:,3)); % less accurate, but more robust
                disp(pMin);
            end
        else
            [pMin,c] = estimateParabFit(pk);
        end
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

function [tip,c] = estimateParabFit(q)
    global tetra
    tetra.callCount=0;
    tetra.callPeriod=10;
    
    initialStep = [1,1,1,.03,.1];
    smallBox = [initialStep(1:3)/2000, .00001, .000001];
    
    initialGuess = [median(q(:,1:2)),min(q(:,3)),.2,.2];  % a little less than tan(15), for 150 deg tip tool
    maxIterations=444;
    [fit,nEval,status,err] = SimplexMinimize(...
        @(p) parabFitErr(p,q),...
   	initialGuess, initialStep, smallBox, maxIterations);
    tip=fit(1:3);
    c = fit(4:5);
    if bitand(tetra.plotFlags,4), plotParabFit(q,fit); end
end

%function [tip,m] = estimateConeFit(q)
%    global tetra
%    tetra.callCount=0;
%    tetra.callPeriod=10;
%    
%    initialStep = [1,1,1,.04];
%    smallBox = [initialStep(1:3)/2000, .0001];
%    
%    initialGuess = [median(q(:,1:2)),min(q(:,3)),.268];  % ~tan(15), for 150 deg tip tool
%    maxIterations=444;
%    [fit,nEval,status,err] = SimplexMinimize(...
%        @(p) coneFitErr1(p,q),...
%   	initialGuess, initialStep, smallBox, maxIterations);
%    tip=fit(1:3);
%    m = fit(4);
%    if bitand(tetra.plotFlags,4), plotConeFit(q,fit); end
%end

% depricated for more general versions above
%function err = coneFitErr1(p,dat)
%    global tetra
%
%    x0 = p(1);
%    y0 = p(2);
%    z0 = p(3);
%    m  = p(4);
%    dxy = [dat(:,1) - x0, dat(:,2) - y0];
%    r = norm(dxy,2,'rows');
%    z = m*r;
%    err = dat(:,3) - z0 - z;
%    %err = mean(abs(err));    % MAE z-error
%    err = mean(err .* err);  % MSE z-error
%    if (m < 0.01)
%        %disp('applying penalty for inverted cone');
%        weight = (1-m-0.011)^4;
%        err = err * weight;
%    end
%    if (mod(tetra.callCount, tetra.callPeriod) == 0) && bitand(tetra.plotFlags,4) , ...
%        fprintf(2,'%d %.6f  %.2f %.2f %.2f  %.4f\n',tetra.callCount,err, p); end
%    tetra.callCount = tetra.callCount + 1;
%end

% re-wrote (better) above : 3d cone err plot
%function plotConeFit3D(p,fit)
%    %xx = linspace(floor(min(p0(:,1))),ceil(max(p0(:,1))),20);
% %yy = linspace(floor(min(p0(:,2))),ceil(max(p0(:,2))),20);
% %   [xg,yg] = meshgrid(xx,yy);
% %    zz = evalPoly2D(xg,yg,coef);
%    figure 1
%    hold off
%    plot3(p(:,1),p(:,2),p(:,3),'mo');
%    grid on
%    hold on
%    rt=3; % radius at top of line
%    zt = fit(4)*rt;
%    for a=0:30:355
%        plot3(fit(1)+[0,rt*cosd(a)], fit(2)+[0,rt*sind(a)], fit(3)+[0,zt]);
%    end
%    a=[0:2:360];
%    for z=.2:.2:zt
%        r = z / fit(4);
%        x = r * cosd(a) + fit(1);
%        y = r * sind(a) + fit(2);
%        zc = zeros(1,length(a)) + fit(3) + z;
%        plot3(x,y,zc);
%    end
%    %mesh(xg,yg,zz);
%    tit = sprintf('%d probes, minima [%.3f, %.3f, %.3f]',size(p,1),fit(1:3));
%    title(tit);
%    xlabel X
%    ylabel Y
%    hold off
%    %disp('any key to continue...');kbhit();
%    keyboard
%end

% re-wrote, use above version
% if we are asserting radial symmetry, do plots in terms of r
%function plotConeFit(p,fit)
%    x0 = fit(1);
%    y0 = fit(2);
%    z0 = fit(3);
%    m  = fit(4);
%    dxy = [p(:,1) - x0, p(:,2) - y0];
%    r = norm(dxy,2,'rows');
%    figure 1
%    hold off
%    plot(r,p(:,3),'mo');
%    grid on
%    hold on
%    ra = [0,3];
%    plot(ra,m*ra+z0,'r');
%    xlabel(sprintf('vertex at [%.3f, %.3f, %.3f]mm',fit(1:3)));
%    ylabel('Z(mm)');
%    tit = sprintf('%d probes',size(p,1));
%    title(tit);
%    hold off
%    keyboard
%    %disp('any key to continue...');kbhit();
%end

% if we are asserting radial symmetry, do plots in terms of r
function plotParabFit(p,fit)
    x0 = fit(1);
    y0 = fit(2);
    z0 = fit(3);
    c1 = fit(4);
    c2 = fit(5);
    dxy = [p(:,1) - x0, p(:,2) - y0];
    r = norm(dxy,2,'rows');
    figure 1
    hold off
    plot(r,p(:,3),'mo');
    grid on
    hold on
    ra = [0:.1:3];
    z = z0 + c1*ra + c2 * (ra .* ra);
    plot(ra,z,'r');
    xlabel(sprintf('vertex at [%.3f, %.3f, %.3f]mm',fit(1:3)));
    ylabel('Z(mm)');
    tit = sprintf('%d probes',size(p,1));
    title(tit);
    hold off
    keyboard
    %disp('any key to continue...');kbhit();
end
