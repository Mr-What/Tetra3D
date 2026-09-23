% make a pretty contour plot from a klipper bed mesh in printer.cfg
function mesh = klipperPlotBedMesh(printerCfgFile, meshName)
    mesh=loadBedMesh(printerCfgFile, meshName);
    mesh.fileName=printerCfgFile;
    mesh.name = meshName;
    siz = size(mesh.points);
    mesh.xAxis = [mesh.min_x:(mesh.max_x-mesh.min_x)/(siz(2)-1):mesh.max_x];
    mesh.yAxis = [mesh.min_y:(mesh.max_y-mesh.min_y)/(siz(1)-1):mesh.max_y];

    % interpolate to finer grid
    xi=linspace(mesh.min_x,mesh.max_x,512);
    yi=linspace(mesh.min_y,mesh.max_y,512);
    [gx,gy]=meshgrid(xi,xi);
    z=round(interp2(mesh.xAxis,mesh.yAxis,mesh.points*1000,gx,gy,'spline'));
    centerWhite
    hold off
    [c0,h0]=contourf(gx,gy,z,64,'LineColor','none');
    %imagesc(z)
    axis image;
    zMax = max(abs(mesh.points(:)))*1000;
    caxis([-zMax,zMax]);
    levels = roundLevels(zMax);
    hold on;
    [c,h] = contour(gx,gy,z,levels,'k');
    clabel(c,h,levels,'fontsize',12,'fontweight','bold');
    %           'backgroundcolor','w',...
    %       'edgecolor','none',
    %      'margin',2);
    colorbar
    xlabel('X(mm)');
    ylabel('Y(mm)');
    title(['Bed mesh ',printerCfgFile,'   ',meshName,' (microns)']);
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
