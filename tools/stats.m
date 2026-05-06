% typical stats of a number
function s = stats(x)
    lo = min(x(:));
    hi = max(x(:));
    med = median(x(:));
    [sd,mu] = std(x(:));
    s = [lo,hi,med,sd,mu];
    if nargout == 0
        display('[  min  , median, max] mean stdDev');
        fprintf(1,'[%.3g , %.3g , %.3g] %.3g %.3g\n',lo,med,hi,mu,sd);
    end
end
