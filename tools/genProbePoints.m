% generate a grid of points within reasonable plot envelope
function pose=genProbePoints(maxXY=220,z0=0,dx=20,p0=0, fNam="probePoints.gcode")
    if !isstruct(p0)
        p0 = struct();
        p0.R=287;  % arm length
        p0.W=360;  % base side length
        p0.Z=900;  % Z at Vertex (or top)
    end
    pp=getTetraParams(p0)
    m=1;
    pose = zeros(999,6);
    fid = fopen(fNam,'w');
    if fid <= 2
        fid=1;
    end
    
    for y=[-maxXY:dx:maxXY]
        for x=[-maxXY:dx:maxXY]
            cart = [x,y,z0];
            tet = cart2tetra(pp.k,cart);
            if validTetraPose(pp, tet, cart)
                plotTetra(pp,cart);  print('-dpng',sprintf('probePoint%04d.png',m));
                pose(m,:)=[cart,tet]; m=m+1;
                fprintf(fid,'PROBE_XY X=%.1f Y=%.1f Z=%.3f\t; %.3f,%.3f,%.3f\n', cart+[0,0,10],tet);
                fprintf(1,'PROBE_XY X=%.1f Y=%.1f Z=%.3f\t; %.3f,%.3f,%.3f\n', cart+[0,0,10],tet);
            end
        end
    end
    pose = pose(1:m-1,:);
    fclose(fid);
end

function t=validTetraPose(p, tet, cart)
    if !isreal(tet)
        fprintf(1,'#IMPOSSIBLE %d,%.d,%.1f\n',cart);
        t=false;
        return
    end
    va = p.k.A0 + tet(1)*p.k.Ahat;
    vb = p.k.B0 + tet(2)*p.k.Bhat;
    vc = p.k.C0 + tet(3)*p.k.Chat;
    tp = [va;vb;vc]; % tower position in cartesian
    va = va - cart;  % vector from effector to tower carriage center
    vb = vb - cart;
    vc = vc - cart;
    % check arm length, to help validate kinematics
    if ( abs(norm(va)-p.k.arm(1)) + ...
         abs(norm(vb)-p.k.arm(2)) + ...
         abs(norm(vc)-p.k.arm(3)) ) > .001
        fprintf(1,'#Bad arm length %.1f,%.1f,%.1f\n',cart);
        t= false;
        return
    end
         
    %toTower = [va;vb;vc]  % not interesting.  look at normalized:
    vHat = [va / p.k.arm(1); ...
            vb / p.k.arm(2); ...
            vc / p.k.arm(3)];
    t = true;
    for k = 1:3
        % check if too close to linkage lock condition
        if vHat(k,3) < .25
            fprintf(1,'#ARM %d too flat     %d,%d,%.1f\n',k,vHat(k,:));
            t = false;
            return
%        elseif vHat(k,3) > .99
%            fprintf(1,'#ARM %d too vertical %.d,%d,%.1f\n',k,vHat(k,:));
%            t = false;
            return
        end
    end
end
