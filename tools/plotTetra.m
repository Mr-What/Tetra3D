% line-plot of tetrahedral-delta 3d printer model,
% with effector at given cartesian point
function tet=plotTetra(tp,q)
  hold off;
  pk = tp.k;  % kinematic model params  
  baseX = [pk.base(:,1)', pk.base(1,1)];
  baseY = [pk.base(:,2)', pk.base(1,2)];
  plot3(baseX,baseY,[0 0 0 0],'linewidth',3);  % base triangle
  hold on;
  v = pk.base + tp.apex * pk.dir;
  for k=1:3
    x = [baseX(k),v(k,1)];
    y = [baseY(k),v(k,2)];
    z = [0,tp.apex];
    plot3(x,y,z,'r','LineWidth',3);
  end
  grid on;axis equal;
  plot3(q(1),q(2),q(3),'.m','MarkerSize',5);
  tet = cart2tetra(pk,q);
  A1 = pk.base(1,:) + tet(1) * pk.dir(1,:);
  B1 = pk.base(2,:) + tet(2) * pk.dir(2,:);
  C1 = pk.base(3,:) + tet(3) * pk.dir(3,:);
  p = [A1;B1;C1];
  for k=1:3
    x = [q(1),p(k,1)];
    y = [q(2),p(k,2)];
    z = [q(3),p(k,3)];
    plot3(x,y,z);
  end
  xlabel('X');ylabel('Y');zlabel('Z');
  s = {'A0','B0','C0'};  xOff = [-25,30,0]; yOff=[-15,-20,80];
  for m=1:3
      text(pk.base(m,1) + xOff(m), pk.base(m,2) + yOff(m), pk.base(m,3), s{m});
  end
  a = sum(pk.base(2:3,:))/2
  b = sum(pk.base([1,3],:))/2;
  c = sum(pk.base(1:2,:))/2;
  text(a(1)+30,a(2)+20,a(3),'a');
  text(b(1)-30,b(2)  ,b(3),'b');
  text(c(1)  ,c(2)-40,c(3),'c');
  title('Tetrahedral 3D printer kinematic model')
  %axis([-25 25 -20 20 0 95]);

  axis([pk.base(1,1),pk.base(2,1),pk.base(1,2),pk.base(3,2),0,tp.apex] .* ...
       [  1.2,    1.2,     1.4,    1.2     ,1,1.05]);
  view(340,16);
end

