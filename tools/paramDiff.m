% compute and display differing Tetra parameters between two
% klipper user parameter structs
function [nam, val] = paramDiff(a0,b0)
    a = checkEndstops(a0); 
    b = checkEndstops(b0);
    [nam, val] = checkDiff(a,b,'position_endstops',{},[]);
    [nam, val] = checkDiff(a,b,'delta_angles',nam,val);
    [nam, val] = checkDiff(a,b,'delta_radius',nam,val);
    [nam, val] = checkDiff(a,b,'arm_lengths',nam,val);
    [nam, val] = checkDiff(a,b,'tilt_radial',nam,val);
    [nam, val] = checkDiff(a,b,'tilt_tangential',nam,val);
    [nam, val] = checkDiff(a,b,'rotation_distances',nam,val);

    fprintf(1,'\tfield\t\tvalA\tvalB\tA-B\n');
    for k=1:length(nam)
        fprintf(1,'\t%s\t%.06g\t%.06g\t%.03g\n',nam{k},val(k,:));
    end
end

function [nam, val] = checkDiff(a,b,field,nam,val)
    d = a.(field) - b.(field);
    if sum(abs(d)) <= 0
        return
    end
    m = length(d);
    n = length(nam) + 1;
    if m==1
        nam{n} = field;
        val(n,:) = [a.(field), b.(field), d];
        return
    end
    for k=1:m
        if abs(d(k)) > 0
            nam{n} = sprintf('%s(%d)',field,k);
            val(n,:) = [a.(field)(k), b.(field)(k), d(k)];
            n=n+1;
        end
    end
end

function a = checkEndstops(a0)
    a = a0;
    if isfield(a0,'position_endstops')
        return
    end
    a.position_endstops = [a0.stepper_a.position_endstop, ...
                           a0.stepper_b.position_endstop, ...
                           a0.stepper_c.position_endstop];
end
