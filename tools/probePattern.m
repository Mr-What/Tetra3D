gp.W=360;gp.Z=940;gp.R=287;  % approx my prototype frame
p=getTetraParams(gp)
%graphics_toolkit("gnuplot")
m=1;t=zeros(21*21,6);
for x=-100:10:100
    for y = -100:10:100
        q = [x,y,0];
        tet = cart2tetra(p.k,q);
        disp([q,tet]);
        if isreal(tet)
            t(m,:) = [q,tet];
            m=m+1;
        end
    end
end
t=t(1:m-1,:);
for k=1:length(t)
    fprintf(1,'%9.3f,%9.3f,%9.3f,\t%9.3f,%9.3f,%9.3f\n',t(k,:));
end
