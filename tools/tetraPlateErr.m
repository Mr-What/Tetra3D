% at this time, we are looking only at X,Y error from plate probes.
% cheap, prototype calibration dimple plates may be warped.
%
% pk - parameters used for print
% pm - measurements of plate
% gk - guess at better parameters to use for print.
function [err, errXY, bad] = tetraPlateErr(pk, calPlate, gk)
% update tower positions for differences in stepper calibration, if any.
    global tetra;
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

    % do check when tetra.plotFlags is very verbose
    if bitand(tetra.plotFlags,4)
        [errCheck,errXY] = rigidTransformErr(gpos(:,1:2),idealVertices, calPlate.w);
        disp([err,errCheck]);
    end

    if nBad > 0
        fprintf(2,'adjusting plate error for %d bad points.\n',nBad);
        err = mean(err(bad == 0)) * (nBad+1); %MSE
    end
end

% temp diag
function [err,errXY] = rigidTransformErr(gpos,iv,w)
    global tetra
    % find best fit rotation and shift of mounted plate to these readings.
    %[rot,x0,y0] = estimateRotShift(idealVertices,gpos,999);
    [rot,x0,y0,q] = rigidTransform2D(gpos,iv,w);
    disp([rot,x0,y0]);
    %shiftedVertices = applyRotShift(rot,x0,y0,idealVertices);
    sv = applyRigidTransform2D(iv,rot,x0,y0);
    
    % toolhead position from guessed parameters, minus
    %    likely location after estimated plate mounting rot, shift
    errXY = gpos - sv;
    if bitand(tetra.plotFlags,4);
        plotXformErr(gpos,iv,sv);
        %keyboard
        pause(1);
    end
    err = errXY .* errXY;
    err = sum(err,2) .* w;  % squared err * weight
    err = sum(err);  % weights should be normalized, so this is weighted MSE
                     %err = mean(err); %  MSE X,Y offset from likely dimple vertices to measured
end

function plotXformErr(gp,iv,sv)
    figure 1
    hold off
    plot(gp(:,1),gp(:,2),'mo');
    grid on
    hold on
    xlabel X
    ylabel Y
    %plot(iv(:,1),iv(:,2),'bx');    
    plot(sv(:,1),sv(:,2),'bd');    
    plot([iv(:,1),sv(:,1)]',[iv(:,2),sv(:,2)]');
    axis([-50,50,-50,50]);
    hold off
    err = gp-sv;
    err = err .* err;
    err = sum(err,2);
    err = mean(err);
    legend('simulated location','fitted plate location');
end

