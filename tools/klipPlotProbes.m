% make a pretty contour plot from irregular sampled bed probe values
function p = klipPlotProbes(probe)

    p = mergePoints(probe);  % replace similar measurements with median
    xLo = 10 * floor(min(p(:,1))/10-1);
    xHi = 10 *  ceil(max(p(:,1))/10+1);
    yLo = 10 * floor(min(p(:,2))/10-1);
    yHi = 10 *  ceil(max(p(:,2))/10+1);

    xi = linspace(xLo, xHi, 512);
    yi = linspace(yLo, yHi, 512);
    [Xi, Yi] = meshgrid(xi, yi);
    z = griddata(p(:,1), p(:,2), p(:,3), Xi, Yi, 'v4'); %"linear");
    zo = griddata(p(:,1), p(:,2), p(:,3), Xi, Yi, 'linear');  % sets nan outside RoS
    %out = isnan(zo);
    %z(out) = griddata(p(:,1), p(:,2), p(:,3), Xi(out), Yi(out), 'nearest');  % sets outside to nearest neighbor
    z=round(z*1000);  % convert to microns
    zMax = max(abs(p(:,3))) * 1000
    z(isnan(zo)) = round(zMax/67.5);  % 0 displayed as color slightly below 0?!??

    centerWhite
    hold off
    [c0,h0]=contourf(Xi,Yi,z,65,'LineColor','none');
    %imagesc(z)
    axis equal % image;
    caxis([-zMax,zMax]);
    levels = roundLevels(zMax);
    grid on;
    hold on;
    [c,h] = contour(Xi,Yi,z,levels,'k');
    clabel(c,h,levels,'fontsize',12,'fontweight','bold');
    %           'backgroundcolor','w',...
    %       'edgecolor','none',
    %      'margin',2);
    colorbar
    xlabel('X(mm)');
    ylabel('Y(mm)');
    title('Bed probes (microns)');

    for k=1:rows(p)
        plot(p(k,1),p(k,2),'mo');
        text(p(k,1),p(k,2),sprintf('%d',round(p(k,3)*1000)),'color','m');
    end
    hold off;
end

function levels = roundLevels(zMax)
% range of reasonable steps to try for bed level data, typically 10 < |Z| <5000
    trySteps=[5,10,20,25,50,100,200,250,500,1000];
    for k = 1:length(trySteps)
        n = floor(zMax/trySteps(k));
        if n < 8, break; end
    end
    levels = [-n:n] * trySteps(k);
end
