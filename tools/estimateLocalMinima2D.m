% estimate a local minima from samples of a 2D function
%
%   p0  -- array (n,3) of points, previously classified as members of a cluster
% %%   x0, y0 -- look for minima near 
function pMin = estimateLocalMinima2D(p0)
    global tetra

    % moved to assert data is pre-clustered.  don't need this:
    %[zMin,iMin] = min(p0(:,3));
    %d = p0(:,1:2) - [x0,y0];
    %d = norm(d,2,'rows');
    %idxClose = find(d < 5);
    %p=p0(idxClose,:);
    %[coef, fit] = fitPoly2D(p);
    %if bitand(tetra.plotFlags,2), plot2DpolyFit(p0,p,coef); end
    %
    %idxCloseFit = close2(p(:,3),fit);
    %pClose = p(idxCloseFit,:);
    [coef, fit] = fitPoly2D(p0);
    pMin = poly2Dinflection(coef);
    if bitand(tetra.plotFlags,4)
        % plot2DpolyFit(p,pClose,coef); end
        xx = linspace(floor(min(p0(:,1))),ceil(max(p0(:,1))),20);
        yy = linspace(floor(min(p0(:,2))),ceil(max(p0(:,2))),20);
        [xg,yg] = meshgrid(xx,yy);
        zz = evalPoly2D(xg,yg,coef);
        figure 1
        hold off
        plot3(p0(:,1),p0(:,2),p0(:,3),'mo');
        grid on
        hold on
        mesh(xg,yg,zz);
        tit = sprintf('%d probes, minima [%.3f, %.3f, %.3f]',length(fit),pMin);
        title(tit);
        hold off

        disp('any key to continue...');kbhit();
    end
end


function plot2DpolyFit(p,pClose,coef)
        xx = linspace(floor(min(pClose(:,1))),ceil(max(pClose(:,1))),20);
        yy = linspace(floor(min(pClose(:,2))),ceil(max(pClose(:,2))),20);
        [xg,yg] = meshgrid(xx,yy);
        zz = evalPoly2D(xg,yg,coef);
        figure 1
        hold off
        plot3(p(:,1),p(:,2),p(:,3),'mo');
        grid on
        hold on
        plot3(pClose(:,1),pClose(:,2),pClose(:,3),'rx');
        mesh(xg,yg,zz);
        legend('all points','nearby','nearby fit')
        title({'close points','hit a key on the console to continue...'});
        hold off
        disp('Press any key to continue...');
        kbhit();
end

function [coef, fit] = fitPoly2D(p)
    x = p(:,1);
    y = p(:,2);
    z = p(:,3);
    n = length(x);
    A= [ones(n,1), x, y, x .* y, x .* x, y .* y];
    B = inv(A' * A) * A';
    coef = B * z;
    fit = evalPoly2D(x,y,coef);
end

function p = poly2Dinflection(c)
    D = 4*c(5)*c(6) - c(4)^2;
    x = (c(3)*c(4) - 2*c(2)*c(6)) / D;
    y = (c(2)*c(4) - 2*c(3)*c(5)) / D;
    z = evalPoly2D(x,y,c);
    p=[x,y,z];
end

function idx = close2(p,fit)
    d = p - fit;
    d = d .* d;
    dm = mean(d);
    ds = std(d);
    idx = find(d < dm + 1.5*ds);
end

function z = evalPoly2D(xx,yy,c)
    z = c(1) + c(2)*xx + c(3)*yy + c(4)*(xx .* yy) + ...
        c(5)*(xx .* xx) + c(6)*(yy .* yy);
end
    
