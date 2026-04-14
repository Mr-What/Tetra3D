% given (part of) a klipper tilted_delta configuration parameter struct,
% write a partial klipper printer.cfg type file, that contains all desired
% updated entries
function write_tilted_delta_update_cfg(update, fNam)
    fid = fopen(fNam,'w');
    if (fid <= 2)
        error('Could not open file "%s".',fNam);
        return
    end

    fn = fieldnames(update);
    has_rot_dist = isfield(update,'rotation_distances')
    has_endstops = isfield(update, 'position_endstops')
    has_stepper_update = has_rot_dist || has_endstops;
    if has_stepper_update
        for k=1:3
            section = ['stepper_' , char('a'+k-1)];
            fprintf(fid,'[%s]\n',section);
            if has_rot_dist
                fprintf(fid,'rotation_distance: %.5f\n', ...
                        update.rotation_distances(k));
            end
            if has_endstops
                fprintf(fid,'position_endstop: %.4f\n', ...
                        update.position_endstops(k));
            end
        end
    end

    hdr = false;  % have we written [printer] section header yet?
    hdr = writeValueUpdate(fid,update,'delta_radius'   ,hdr);
    hdr = writeValueUpdate(fid,update,'delta_angles'   ,hdr);
    hdr = writeValueUpdate(fid,update,'arm_lengths'    ,hdr);
    hdr = writeValueUpdate(fid,update,'tilt_radial'    ,hdr);
    hdr = writeValueUpdate(fid,update,'tilt_tangential',hdr);
    fclose(fid);
end

function hdr = writeValueUpdate(fid, update, nam, hdr)
    if !isfield(update,nam)
        return;
    end
    if !hdr
        fprintf(fid,'[printer]\n');
        hdr = true;
    end
    fprintf(fid,'%s: %.6f, %.6f, %.6f\n', nam, update.(nam));
end
