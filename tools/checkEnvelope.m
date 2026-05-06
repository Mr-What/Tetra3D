%% -*- texinfo -*-
%% check if printspace location is within the print
%% envelope of a given tilted Delta printer
%%
%%     err = checkEnvelope(kinematicParameters, xyz)
%%
%%  returns 0 or error code
%%      1 -- actuator too close to endstop
%%      2 -- actuator too close to bed
%%      3 -- arm too close to vertical
%%      4 -- arm too close to horizontal
%%      5 -- non-physical. cannot be reached
%%
function [ok, abc] = checkEnvelope(kp, xyz)
    abc = cart2tetra(kp,xyz);
    if !isreal(abc)
        ok=5;
        return
    end
    disp(abc);
    twrPos = kp.base + abc .* kp.dir;
    baseHat = [kp.base(1,:)/norm(kp.base(1,:));...
               kp.base(2,:)/norm(kp.base(2,:));...
               kp.base(3,:)/norm(kp.base(3,:))];
    for k=1:3
        if (kp.endstop(k) - abc(k) < 2)
            ok=1  % too close to endstop
            return
        end
        if (abc(k) < 100)  % change this to tower min when/if it gets defined
            ok=2
            return
        end
        d = twrPos(k,:) - xyz;
        sa = d(3)/kp.arm(k);  % sin of arm angle
        if (sa < .1)
            ok=4
            return
        end
        %if (sa > .998)
        %    ok = 3;
        %    return
        %end
        dHat = d / norm(d);
        if dot(dHat,baseHat(k,:)) < 0.05
            ok=3
            return
        end
    end
    ok=0;
    return
end
