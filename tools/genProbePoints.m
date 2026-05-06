% generate a grid of points within reasonable plot envelope
function [pose, pe]=genProbePoints(kp,maxXY=220,z0=0,dx=20)
    m=1;
    n=1;
    pose = zeros(999,6);
    pe = zeros(999,4);
    for y=[-maxXY:dx:maxXY]
        for x=[-maxXY:dx:maxXY]
            cart = [x,y,z0];
            [err, abc] = checkEnvelope(kp,cart);
            pe(n,:) = [cart,err]; n=n+1;
            if (checkEnvelope(kp,cart))
                continue
            end
            pose(m,:)=[x, y, z0, abc];
            m=m+1;
        end
    end
    pose = pose(1:m-1,:);
    pe = pe(1:n-1,:);
end
