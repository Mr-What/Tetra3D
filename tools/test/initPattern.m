% print out gcode for a good nozzle purge starting pattern for a delta printer.

rMax = 90
arcLen = 100
arcE = 7  % mm of filament for each arc
arcF = 1200; % mm/min
arcAng = 360 * arcLen / (pi * 2 * rMax)
dArc = arcAng/2;
zMove = 5;
zExt = 0.25;
retract = 5;
fd = 1;  % 1==stdout.

dir = 1;
for ta=[210, 330, 90]
    a0 = ta + dir*dArc;  % start angle
    a1 = ta - dir*dArc;  % stop angle
    xy0 = rMax*[cosd(a0), sind(a0)];
    fprintf(fd,'G0 X%.1f Y%.1f Z%d F6000\nG1 E%d F600\nG0 Z%.2f\n',xy0,zMove,retract+1,zExt);
    xy1 = (rMax-1)*[cosd(a1), sind(a1)];
    dirCode = round(2.5 - dir/2);
    fprintf(fd,'G%d X%.1f Y%.1f I%.1f J%.1f E%d F%d\n', ...
            dirCode, xy1, -xy0, arcE, arcF);
    a0 = ta + 0.8 * dir * dArc;  % stop a little short of where we started
    xy2 = (rMax-2)*[cosd(a0), sind(a0)];
    dirCode = round(2.5 + dir/2);
    fprintf(fd,'G%d X%.1f Y%.1f I%.1f J%.1f E%d\nG1 Z%d E%d\n', ...
            dirCode, xy2, -xy1, arcE,zMove,-retract);
    dir = -dir;
end
if (fd > 1), fclose(fd); end
            
