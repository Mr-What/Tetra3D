# returns XY[n,2] in an ordered probe pattern

function xy = radialProbePattern(phase=[0,30,60], r=[15,30,45,60])
    xy = zeros(999,2);
    n = 1;
    for ang = phase
        for a=[ang:60:355+ang]
            n=n+1;
            xy(n,:) = round(r(1)*[cosd(a),sind(a)]);
        end
        for (a=[ang:60:355+ang])
            n=n+1;
            xy(n,:) = round(r(2)*[cosd(a),sind(a)]);
        end
        for (a=[ang+15:30:355+ang+15])
            n=n+1;
            xy(n,:) = round(r(3)*[cosd(a),sind(a)]);
        end
        for (a=[ang:30:355+ang])
            n=n+1;
            xy(n,:) = round(r(4)*[cosd(a),sind(a)]);
        end
    end
    xy = int32(xy(1:n,:));
end
