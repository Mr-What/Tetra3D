% Given a set of measurements on the bed surface,
%   [optional] test print measurements,
%   and associated probe parameters, pp,
% compute the error metric for guess parameters, gp
%
% Provide function fSetParams to set selected
% parameters in gp for the given parameter vector to evaluate
%
%   p          - search parameter vector
%   pp         - Probe Parameters, parameters used when making probe
%   igp        - Guess Parameters.  guess at better parameters
%   fSetParams - function to make a new parameter struct, from p
function [err,errZ,badZ,errXY,badXY] = tetraFitErr(p, pp, igp, fSetParams)
    global tetra;
    tetra.callCount = tetra.callCount+1;

    % probe_offset not in kinetic parameters.
    % copy it there for error computatuion
    pp.k.probe_offset = pp.probe_offset;

    gp = fSetParams(p,igp);  % copy parameter vector to standard param struct
    [err,errZ,badZ] = tetraProbeErr(pp.k, pp.pos, gp.k);
    tetra.bedRMS = err;  % dirty hack to make available outside Simplex

    %fprintf(2,'probe_err=%.4g',err);

    if isfield(pp,'calPlate')
        if (tetra.callCount <= 1)
            disp('Using calibration plate measurements.');
            %if tetra.echoMeas
            %    for m = 1:length(pp.measXY.id)
            %        fprintf(1,'   %s = %6.2f\n', pp.measXY.id(m,:), pp.measXY.dist(m));
            %    end
            %    tetra.echoMeas = false;
            %end
        end
        [mse,errXY,badXY] = tetraPlateErr(pp.k, pp.calPlate, gp.k);
        tetra.plateMSE = mse;  % dirty hack to make available outside Simplex
        %fprintf(2,'   meas_err=%4g',mse);
        err = err * mse;  % extra weight on plate probe, MSE, not RMS
    else
        errXY=1;
        badXY=0;
    end


    if isfield(pp,'measXY')
        if (tetra.callCount <= 1)
            disp('Using calibration print measurements.');
            if tetra.echoMeas
                for m = 1:length(pp.measXY.id)
                    fprintf(1,'   %s = %6.2f\n', pp.measXY.id(m,:), pp.measXY.dist(m));
                end
                tetra.echoMeas = false;
            end
        end
        [rms,errXY,badXY] = tetraPrintErr(pp.k, pp.measXY, gp.k);
        %fprintf(2,'   meas_err=%4g',mse);
        tetra.measRMS=rms;
        err = err * rms * rms;  % extra weight on print
    else
        errXY=1;
        badXY=0;
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

    z0 = pk.probe_offset(3);  % probe trigger at z_offset, NOT 0
    %bad = int32(errZ);
    %m = 1;
    %errZ = zeros(n,1);
    %for j=1:n
    %    dz = tetra2cart(gk, tet(j,:));  % guess at actual effector position
    %    if !isreal(dz)
    %        bad(j) = 1;
    %    end
    %    errZ(j) = real(dz(3)) - z0;
    %end
    %nBad = sum(bad);
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


% at this time, we are looking only at X,Y error from plate probes.
% cheap, prototype calibration dimple plates may be warped.
%
% pk - parameters used for print
% pm - measurements of plate
% gk - guess at better parameters to use for print.
function [err, errXY, bad] = tetraPlateErr(pk, calPlate, gk)
% update tower positions for differences in stepper calibration, if any.
    pos = calPlate.pos;
    idealVertices = calPlate.dimpleIdeal;
    twr = commandedTowerPositions(pk, pos, gk);
    [gpos,bad,nBad] = tetra2cartV(twr,gk);

    % sorry, not processing bad pos a this time...
    % hopefully we removed them in tetraAnalysePlateProbe culling
    if nBad > 0
        %fprintf(2,'removing %d non-physical vertices',nBad);
        fprintf(2,'%d non-physical vertices',nBad);
        %i = find(bad == 0);
        %gpos=gpos(i,:);
        %idealVertices = idealVertices(i,:);
    end

    % we can compute fit MSE, without actually finding fit, or measuring
    err = calPlate.fitMSE(gpos(:,1), gpos(:,2));
    errXY=[];
    return
    
    % find best fit rotation and shift of mounted plate to these readings.
    %[rot,x0,y0] = estimateRotShift(idealVertices,gpos,999);
    [rot,x0,y0,q] = rigidTransform2D(gpos(:,1:2),idealVertices, calPlate.w);
    %shiftedVertices = applyRotShift(rot,x0,y0,idealVertices);
    shiftedVertices = applyRigidTransform2D(idealVertices,rot,x0,y0);
    
    % toolhead position from guessed parameters, minus
    %    likely location after estimated plate mounting rot, shift
    errXY = gpos(:,1:2) - shiftedVertices(:,1:2);
    err = errXY .* errXY;
    err = sum(err,2);  %squared err
    err = mean(err); %  MSE X,Y offset from likely dimple vertices to measured
    if nBad > 0
        fprintf(2,'adjusting plate error for %d bad points.\n',nBad);
        err = mean(err(bad == 0)) * (nBad+1); %MSE
    end
end

function [gpos,bad,nBad] = tetra2cartV(tet,gk)
    n = rows(tet);
    gpos = zeros(n,3);
    bad = zeros(n,1);
    for k=1:n
        p = tetra2cart(gk,tet(k,:));
        if !isreal(p)
            bad(k)=1;
            p = real(p);
        end
        gpos(k,:) = p;
    end
    nBad = sum(bad);
end
