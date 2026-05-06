% write out gcode for a bed probe
function writeBedProbe(xy,z0,fNam)
    fd = fopen(fNam,'w');
    if (fd <= 2)
        disp('unable to write to ' + fNam);
        return
    end
    fprintf(fd,'G28 (home)\nG90 (absolute positions)\nGET_POSITION\nQUERY_ENDSTOPS\n');
    fprintf(fd,'G1 X0 Y0 Z100 F2400\nQUERY_ENDSTOPS\nGET_POSITION\n');
    for k=1:length(xy)
        fprintf(fd,'G1 X%d Y%d Z%d\nPROBE\n',xy(k,1:2),z0);
    end
    fclose(fd);
end
