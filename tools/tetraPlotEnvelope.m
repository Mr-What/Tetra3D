function tetraPlotEnvelope(env,aa,za,psym='o-')
    na = length(aa);
    nz = length(za);
    a = aa(:);   a(end+1) = a(1);
    ca = cosd(a);
    sa = sind(a);
    for zk=1:nz
        z = za(zk) + zeros(na+1,1);
        r = env(:,zk);
        r(end+1) = r(1);
        x = r .* ca;
        y = r .* sa;
        plot3(x,y,z,psym);
        if zk==1, hold on; end
    end
    for k=1:na
        r = env(k,:);
        x = r * cosd(a(k));
        y = r * sind(a(k));
        plot3(x,y,za,psym);
    end
    axis equal
    grid on
    hold off
    xlabel X
    ylabel Y
end
