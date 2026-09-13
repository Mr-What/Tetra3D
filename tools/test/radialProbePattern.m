# returns XY[n,2] in an ordered probe pattern

function xy = radialProbePattern()
    xy = zeros(999,2);
    r = 20;
    n = 1;
    r = 20;
    for (a=[30:60:355])  % delta cardinal directions
        n=n+1;
        xy(n,:) = round(r*[cosd(a),sind(a)]);
    end
    r=40;
    for (a=[0:60:355])
        n=n+1;
        xy(n,:) = round(r*[cosd(a),sind(a)]);
    end
    r=60;
    for (a=[15:30:355])
        n=n+1;
        xy(n,:) = round(r*[cosd(a),sind(a)]);
    end
    r=80;  % don't want too much weight at outside.  12 samples again
    for (a=[0:30:355])
        n=n+1;
        xy(n,:) = round(r*[cosd(a),sind(a)]);
    end
    xy = int32(xy(1:n,:));
end
