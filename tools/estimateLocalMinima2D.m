% estimate a local minima from samples of a 2D function
%
%   p0  -- array (n,3) of points, previously classified as members of a cluster near a local minima
function pMin = estimateLocalMinima2D(p0)
    global tetra

    [coef, fit] = fitPoly2D(p0);
    pMin = poly2Dinflection(coef);

    if bitand(tetra.plotFlags,4), plot2DpolyFit(p0,coef,pMin); end
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

function z = evalPoly2D(xx,yy,c)
    z = c(1) + c(2)*xx + c(3)*yy + c(4)*(xx .* yy) + ...
        c(5)*(xx .* xx) + c(6)*(yy .* yy);
end


function plot2DpolyFit(p0,coef,pMin)
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
    tit = sprintf('%d probes, minima [%.3f, %.3f, %.3f]',size(p0,1),pMin);
    title(tit);
    hold off
    disp('any key to continue...');kbhit();
end
