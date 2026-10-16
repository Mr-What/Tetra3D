% Kabsch/Procrustes solution  to a 2D rigid transformation (rotation + shift)
% N: nominal plate positions (n x 2), M: measured vertices (n x 2), same row order
% find theta, x0, y0 s.t. M ~= ([c -s; s c] * N' + [x0,y0])'
function [theta,x0,y0,rms,fit] = rigidTransform2D(M,N,w=ones(rows(N),1))
    w = w(:)/sum(w);
    nb = w' * N;    %mean(N,1);
    mb = w' * M;    %mean(M,1);
    A = N - nb;
    B = M - mb;
    %Sdot   = sum(sum(A .* B));
    %Scross = sum(A(:,1).*B(:,2) - A(:,2).*B(:,1));
    Sdot   = sum(w .* (A(:,1) .* B(:,1) + A(:,2) .* B(:,2)));
    Scross = sum(w .* (A(:,1) .* B(:,2) - A(:,2) .* B(:,1)));
    theta  = atan2d(Scross, Sdot);

    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    t = mb' - R*nb';                    % machine = R*plate + t
    x0=t(1);
    y0=t(2);

    if (nargout < 4)
        return
    end
    q.fit = applyRigidTransform2D(N,theta,x0,y0);
    res = M - fit;
    q.rms = sqrt(sum(w .* sum(res.^2,2))); % sqrt(mean(sum(res.^2,2)));
end
%P   = (R*N' + t)';                  % predicted machine positions
