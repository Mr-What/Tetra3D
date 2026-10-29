% search for envelope
%
% Arm coords  X - tower direction (k.dir)
%             Y - tangential direction
%             Z - cross(X,Y), radial direction
%
%   pp   - config (.p) parameters
%   aa   - delta angle output axis
%   za   - effector height above bed output axis
%
%   zLim - acosd(dot(Z,armDirection))
%          radial angle from tower.  Most "standard" limit.
%          angle (degrees) from tower tangential plane.
%               cosd(dot(Z,armCoordDirectionVector))
%                     0 == arm touching tower when on delta angle line
%                     90 == arm perp to tower
%   yLim - acosd(dot(Y,armDirection))
%          "sideways" from carriage limit
%
%  physical limit, location is beyond arm length limit
%  practical limit : an arm is at too severe an angle
function [practical, physical, code, pk] = tetraEnvelope(pp,aa=[0:5:359],za=[0:5:200])
    na = length(aa);
    nz = length(za);
    physical = zeros(na,nz);
    practical = physical;
    code = int16(physical);
    p = tetraGetParams(pp);
    pk = p.k;
    r = mean(pp.delta_radius)/2;
    r1=r;
    disp('#r     angle    tower    reason');
    for zi=1:nz
        z = za(zi);
        for ai=1:na
            a = aa(ai);
            %fprintf(1,'delta_angle=%d, %dmm above bed\n',a,z);
            r = physLimit(pk,z,a,r);
            physical(ai,zi) = r;
            [r1,q] = practicalLimit(pk,z,a,min([r1,r]));
            practical(ai,zi) = r1;
            code(ai,zi)=q;
            [codeName,twr] = tetraEnvelopeCode(q);
            fprintf(1,'%d %d %s %s\n',round(r1),round(a),twr,codeName);
        end
    end
end

function [nam,twr] = tetraEnvelopeCode(q)
    twrName = {'N/A','A','B','C'};
    twr = twrName{bitand(q,3)+1};
    nam = 'undef';
    if bitand(q, 4), nam='non-phys'; end % physically unreachable
    if bitand(q, 8), nam='perp'; end % too nearly perpendicular to tower
    if bitand(q,16), nam='tangent'; end % too close to tower
    if bitand(q,32), nam='sideways'; end % too far to the side of the tower
end

function r = physLimit(pk,z,a,rPrev)
    ca = cosd(a);
    sa = sind(a);
    r = rPrev;
    do
        r = r-1;
        tet = cart2tetra(pk,[r*ca,r*sa,z]);
    until(isreal(tet))
    rLo = r;
    r = rPrev;
    do
        r = r+1;
        tet = cart2tetra(pk,[r*ca,r*sa,z]);
    until(!isreal(tet))
    rHi = r;

    while (rHi-rLo) > .03
        r = 0.5*(rHi + rLo);
        tet = cart2tetra(pk,[r*ca,r*sa,z]);
        if isreal(tet)
            rLo = r;
        else
            rHi = r;
        end
    end
end

function [r,code] = practicalLimit(pk,z,a,r)
    %fprintf(2,'Practical Limit z=%d delta_angle=%d\n',z,a);
    ca = cosd(a);
    sa = sind(a);
    xy=[ca,sa];
    rLo = 1;
    rHi = pk.base(3,2);  % nominal +Y(C) tower Y coordinate
    
    % search for transition bounds
    if tetraOutsideEnvelope(pk,[r*xy,z])
        rHi = r;
        rLo = r * 0.7;
        while tetraOutsideEnvelope(pk,[rLo*xy,z])
            rHi = rLo;
            rLo = rLo * 0.7;
        end
    else
        rLo=r;
        rHi= r * 1.3;
        while !tetraOutsideEnvelope(pk,[rHi*xy,z])
            rLo=rHi;
            rHi = rHi * 1.3;
        end
    end
    code = 4;
    
    % refine bounds
    while (rHi-rLo) > .1
        r = 0.5*(rHi + rLo);
        q = tetraOutsideEnvelope(pk,[r*xy,z]);
        if q == 0
           rLo = r;
        else
            rHi = r;
            code = q;
        end
    end
    r = 0.5*(rHi + rLo);
end
