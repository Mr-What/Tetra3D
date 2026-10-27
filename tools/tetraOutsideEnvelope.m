% Test if desired position is withing safe envelope
%
%  returns 0 for pose IS practical, or bitfield error code :
%      bitand(q, 3) - tower number that failed, A,B,C == 1,2,3
%      bitand(q, 4) - physically unreachable
%      bitand(q, 8) - too nearly perpendicular to tower
%      bitand(q,16) - too close to tower
%      bitand(q,32) - too far to the side of the tower
%
% acosd(.99) ~= 8
% acosd(.5) = 60  % that would be 90-60=30 from radial. Not much sideways freedom
function q = tetraOutsideEnvelope(pk,xyz)
    global tetra
    
    abc = cart2tetra(pk,xyz);
    q=0;
    if !isreal(abc)
        q=4;  % outisde PHYSICAL envelope
        return
    end
    fprintf(1,'[%d, %d, %d] at tower pos [%d, %d, %d]\n',round(xyz),round(abc));

    tooClose = tetra.envelope.tooClose;  % usually high, like 0.98
    tooSideways = tetra.envelope.tooSideways; % usually around .4 to .7, asin is degrees from radial
    for k=1:3
        xyzc = pk.base(k,:) + abc(k) * pk.dir(k,:); % carriage position
        de = xyz - xyzc; % from carriage to effector
        deLen = norm(de);
        if (abs(deLen - pk.arm(k)) > 0.001)
            % model definition asserts deLen == arm length
            fprintf(1,'ERROR: arm length %.4f but distance from carriage to effector is %.4f\n',pk.arm(k),deLen);
            keyboard
            q=64+k;
            return
        end
        deHat = de / deLen;

        % effector position relative to carriage, in tower coords
        drtBase = [-pk.dir(k,:);pk.radial(k,:);pk.tangential(k,:)];
        drt = drtBase * deHat';
            
        %disp(drt');
        if (abs(norm(drt)-1) > 0.00001)
            disp('ERROR: projecting unit effector direction into tower coords should be a unit vector');
            disp(de);
            disp(drtBase);
            disp(drt');
            q=128+k;
            keyboard
            return
        end

        % raidial direction, perp to tower, pointing toward centerline
        if drt(2) > tooClose
            fprintf(2,'[%d,%d,%d] nearly perpendicular to tower %d\n',round(xyz),k);
            q = 8+k;  % too close to perpendicular to tower
            return
        end
        if abs(drt(1)) > tooClose
            fprintf(2,'[%d,%d,%d] too close to tower %d\n',round(xyz),k);
            q = 16+k; % too close to tower
            return
        end
        if abs(drt(3)) > tooSideways
            fprintf(2,'[%d,%d,%d] too far sideways from tower %d\n',round(xyz),k);
            q= 32+k;
            return
        end
    end
end
