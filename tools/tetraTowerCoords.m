% Arm coords  X - tower up direction (k.dir)
%             Y - cross(Z,x) = tangential direction
%             Z - radial direction
function [tangential, radial] = tetraTowerCoords(dir)
    radial=zeros(3);
    tangential=zeros(3);
    for k=1:3
        up = dir(k,:);
        xy = up(1:2);
        xyn = norm(xy);
        xy = xy / xyn;
        dz = up(3);
        rHat = [xy * dz, -xyn];
        radial(k,:) = rHat;
        tHat = cross(rHat,up);
        tangential(k,:) = tHat;

        % check, should be all zeros
        disp([norm(up)-1,norm(tHat)-1,norm(rHat)-1,dot(up,tHat),dot(up,rHat),dot(rHat,tHat)]);
    end
end
