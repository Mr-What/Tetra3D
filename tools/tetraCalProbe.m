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
function pd = tetraCalProbe(probe, plateScale=1, pattern=3)
    cluster = dbscan(probe,8,11);
    pd.probe = probe;
    pd.clusterId=cluster;
    i = find(cluster < 0);
    pd.noCluster=probe(i,:);
    n = max(cluster);
    fprintf(1,'%d clusters, %d not-clustered\n',n,length(i));
    pd.cluster = cell(n,1);
    pd.dimple=zeros(n,3);
    m = tand(15);  % default nipple wall slope
    for k=1:n
        i = find(cluster==k);
        clusterSize = length(i);
        pk = probe(i,:);
        pd.cluster(k) = pk;
        if bitand(pattern,1)
            % depricated.  initial probes are filtered out before writing probeNNNplate.csv
            % omit points used for initial vertex estimate, they could over-weight cardinal direction fit
            %disp('omitting initial rough search probes')
            %disp(pk(1:4,:));
            %pk = pk([5:clusterSize],:);
            if bitand(pattern,2)
                pMin = estimateConeFitFixed(pk,m);
            else
                [pMin,m] = estimateConeFit(pk,m);
            end
        else
            disp('searching probes yet to be refactored');
            %pMin = estimateConeFitSearch(pk);
            %pMin = estimateConeFitSimple(pk);
        end
        %disp(round(1000*(pMin-pMin1)));
        pd.dimple(k,:) = pMin;
        tit = sprintf('cluster %d, %d probes, minima [%.3f, %.3f, %.3f]',k,clusterSize,pMin);
        disp(tit);
    end

    % ideal locations, for plates so far, will be every 20mm.
    % We can guess ideal locations from probes adequately.
    d0 = 20 * round(pd.dimple(:,1:2)/20);
    d0 = plateScale * d0;  % initial printed plates had some shrinkage, plateScale ~< 1
    [rot,x1,y1] = estimateRotShift(d0,pd.dimple);
    pd.plateScale=plateScale;
    pd.plateRot=rot;
    pd.plateShift = [x1,y1];
    pd.dimpleIdeal = d0;
    pd.dimpleShifted = applyRotShift(rot,x1,y1,d0);
end

% ---------------------------- fit to ideal cone of known wall slope (m)
%    150 deg v groove cutter, or emulated by 3D print, 15 deg slope
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

% ------------------------------------ find cal plate rotation and shift

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
