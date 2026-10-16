% apply rigid transform (from rigidTransform2D()) to a set of (n,2) points
function P = applyRigidTransform2D(N,rot,x0,y0)
    c = cosd(rot);
    s = sind(rot);
    R = [c -s; s c];
    t = [x0; y0];
    P = (R*N' + t)';                  % transformed positions    
    if (nargout < 4)
        return
    end
    res = M - P;
%rms = sqrt(mean(sum(res.^2,2)));
%printf("theta = %.4f deg, t = [%.3f %.3f], rms = %.4f mm\n", theta*180/pi, t, rms);
    
end


