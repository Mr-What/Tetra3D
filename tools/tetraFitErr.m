% Given a set of measurements on the bed surface,
%   [optional] test print measurements,
%   and associated probe parameters, pp,
% compute the error metric for guess parameters, gp
%
% Provide function fSetParams to set selected
% parameters in gp for the given parameter vector to evaluate
%
%   p          - search parameter vector
%   cal        - tetra.cal.(calibration_id)
%   td         - Tetra probe Data, with parameters used when making probe
%   igp        - Guess Parameters.  guess at better parameters
%   fSetParams - function to make a new parameter struct, from p
function [err,errZ,badZ,errXY,badXY] = tetraFitErr(p, cal, td, igp)
    global tetra;
    tetra.callCount = tetra.callCount+1;

    % probe_offset not in kinetic parameters.
    % copy it there for error computatuion
    td.k.probe_offset = td.probe_offset;

    gp = tetraVset(cal,p,igp); % convert p vector int standard .p parameter struct
    [err,errZ,badZ] = tetraProbeErr(td.k, td.pos, gp.k);
    tetra.RMS.bed = err;  % dirty hack to make available outside Simplex

    %fprintf(2,'probe_err=%.4g',err);

    if isfield(td,'calPlate')
        if (tetra.callCount <= 1)
            disp('Using calibration plate measurements.');
        end
        [mse,errXY,badXY] = tetraPlateErr(td.k, td.calPlate, gp.k);
        tetra.RMS.plate = sqrt(mse);  % dirty hack to make available outside Simplex
        %fprintf(2,'   meas_err=%4g',mse);
        err = err * mse;  % extra weight on plate probe, MSE, not RMS
    else
        errXY=1;
        badXY=0;
        tetra.RMS.plate=0;
    end


    if isfield(td,'measXY')
        if (tetra.callCount <= 1)
            disp('Using calibration print measurements.');
            if tetra.echoMeas
                for m = 1:length(pp.measXY.id)
                    fprintf(1,'   %s = %6.2f\n', td.measXY.id(m,:), td.measXY.dist(m));
                end
                tetra.echoMeas = false;
            end
        end
        [rms,errXY,badXY] = tetraPrintErr(td.k, td.measXY, gp.k);
        %fprintf(2,'   meas_err=%4g',mse);
        tetra.RMS.meas=rms;
        err = err * rms * rms;  % extra weight on print
    else
        errXY=1;
        badXY=0;
        tetra.RMS.meas=0;
    end

    err = err*1000;  % scale to be easier to read    
    if (mod(tetra.callCount,tetra.callPeriod) == 0)
        %fprintf(2,'\n');
        fprintf(1,'%4d %.6g  ',tetra.callCount, err);
        fprintf(1,' %.5g',p);
        fprintf(1,'\n');
    end
end

% pos is commanded tower location at bed probe trigger
function [err, errZ, bad] = tetraProbeErr(pk, pos, gk)
    err = 0;
    n = size(pos,1);

    % update tower positions for differences in stepper calibration, if any.
    tet = commandedTowerPositions(pk, pos, gk);

    [gpos,bad,nBad] = tetra2cartV(tet,gk);

    % we are now using PROBE OFFSET reports, which have probe offsets removed.
    % reported position is toolhead commanded position
    z0 = pk.probe_offset(3);  % probe trigger at z_offset, NOT 0
    errZ = gpos(:,3) - z0;
    
    if nBad > 0
        err = errZ(bad == 0);
        err = sqrt(mean(err .* err));
        err = err * (nBad+1);  % penalty of out of envelope probe
    else
        err = sqrt(mean(errZ .* errZ));  % RMSE bed level
    end
    %fprintf(2,'Bed Probe RMSE=%.6g',err);
end

% pk - parameters used for print
% pm - measurements of print
% gk - guess at better parameters to use for print.
function [err, errXY, bad] = tetraPrintErr(pk, pm, gk)
    % update tower positions for differences in stepper calibration, if any.
    twr1 = commandedTowerPositions(pk, pm.twr(:,1:3), gk);
    twr2 = commandedTowerPositions(pk, pm.twr(:,4:6), gk);
    
    err = 0;
    n = size(pm.twr,1);
    m = 1;
    errXY = zeros(n,1);
    bad = int32(zeros(n,1));
    for j=1:n
        xyz1 = tetra2cart(gk, twr1(j,:));  % guess at actual effector position
        xyz2 = tetra2cart(gk, twr2(j,:));  % guess at actual effector position
        if (isreal(xyz1) && isreal(xyz2))
            simulatedDistance = norm(xyz1(1:2) - xyz2(1:2));
            measuredDistance = pm.dist(j);
            errXY(j) = measuredDistance - simulatedDistance;
        else
            bad(j)=1;
        end
    end
    nBad = sum(bad);%keyboard
    if nBad > 0
        err = errXY(find(bad == 0));
        err = mean(err .* err) ^ (nBad+1);  % penalty for out of envelope probe
    else
        err = sqrt(mean(errXY .* errXY));  % RMSE distance measures
    end
    %fprintf(2,'\tXY measurement MSE=%.6g',err);
    %hold off; plot(errXY,'x'); grid on; ginput(1)
end
