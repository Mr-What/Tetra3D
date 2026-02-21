% line-plot of tetrahedral-delta 3d printer model,
% with effector at given cartesian point
function tet=plotTetra(tp,q)
  hold off;
  pk = tp.k;  % kinematic model params  
  baseX = [pk.A0(1), pk.B0(1), pk.C0(1), pk.A0(1)];
  baseY = [pk.A0(2), pk.B0(2), pk.C0(2), pk.A0(2)];
  plot3(baseX,baseY,[0 0 0 0],'linewidth',3);  % base triangle
  hold on;
  for k=1:3
    x = [baseX(k),tp.p.Zxy(k,1)];
    y = [baseY(k),tp.p.Zxy(k,2)];
    z = [0,tp.p.Z];
    plot3(x,y,z,'r','LineWidth',3);
  end
  grid on;axis equal;
  plot3(q(1),q(2),q(3),'.m','MarkerSize',5);
  tet = cart2tetra(pk,q);
  A1 = pk.A0 + tet(1) * pk.Ahat;
  B1 = pk.B0 + tet(2) * pk.Bhat;
  C1 = pk.C0 + tet(3) * pk.Chat;
  p = [A1;B1;C1];
  for k=1:3
    x = [q(1),p(k,1)];
    y = [q(2),p(k,2)];
    z = [q(3),p(k,3)];
    plot3(x,y,z);
  end
  xlabel('X');ylabel('Y');zlabel('Z');
  text(pk.A0(1)-5,pk.A0(2)-3,pk.A0(3),'A0')
  text(pk.B0(1)+2,pk.B0(2)-3,pk.B0(3),'B0')
  text(pk.C0(1)+4,pk.C0(2)+2,pk.C0(3),'C0')
  %text(tp.Apex(1),tp.Apex(2),tp.Apex(3)+3,'Apex')
  a = (pk.B0 + pk.C0)/2;
  b = (pk.A0 + pk.C0)/2;
  c = (pk.B0 + pk.A0)/2;
  text(a(1)-4,a(2)  ,a(3),'a');
  text(b(1)+3,b(2)  ,b(3),'b');
  text(c(1)  ,c(2)-3,c(3),'c');
  title('Tetrahedral 3D printer kinematic model')
  %axis([-25 25 -20 20 0 95]);

  axis([pk.A0(1),pk.B0(1),pk.A0(2),pk.C0(2),0,tp.p.Z] .* ...
       [  1.2,    1.2,     1.4,    1.2     ,1,1.05]);
  view(340,16);
end

