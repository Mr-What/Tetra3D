% generate vertices in hex sampling pattern, about a ring, unit radius r
function p = hexRing(r)
    dy = sqrt(3)/2;
    dx = 0.5;
    x=r;
    y=0;
    nTot=6*r;
    p = zeros(nTot,2);
    n=1;
    p(n,:) = [x,y];
    fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    for k=1:r
        x=x-dx;
        y=y+dy;
        n=n+1;
        p(n,:) = [x,y];
        fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    end
    for k=1:r
        x=x-1;
        n=n+1;
        p(n,:)=[x,y];
        fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    end
    for k=1:r
        x=x-dx;
        y=y-dy;
        n=n+1;
        p(n,:)=[x,y];
        fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    end
    for k=1:r
        x=x+dx;
        y=y-dy;
        n=n+1;
        p(n,:)=[x,y];
        fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    end
    for k=1:r
        x=x+1;
        n=n+1;
        p(n,:)=[x,y];
        fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    end
    for k=1:r-1
        x=x+dx;
        y=y+dy;
        n=n+1;
        p(n,:)=[x,y];
        fprintf(1,'[%.3f, %.3f],\n',p(n,:));
    end
end
