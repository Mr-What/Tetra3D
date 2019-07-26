% line-plot of tetrahedral-delta 3d printer model,
% with effector at given cartesian point
function plotTetraCart(tp,q)
  hold off;
  baseX = [tp.A0(1), tp.B0(1), tp.C0(1), tp.A0(1)];
  baseY = [tp.A0(2), tp.B0(2), tp.C0(2), tp.A0(2)];
  plot3(baseX,baseY,[0 0 0 0],'linewidth',3);
  hold on;
  for k=1:3
    x = [baseX(k),tp.Apex(1)];
    y = [baseY(k),tp.Apex(2)];
    z = [0,tp.Apex(3)];
    plot3(x,y,z,'r','LineWidth',3);
  end
  grid on;axis equal;
  plot3(q(1),q(2),q(3),'.m','MarkerSize',5);
  tet = cart2tetra(tp,q)
  A1 = tp.A0 + tet(1) * tp.Ahat;
  B1 = tp.B0 + tet(2) * tp.Bhat;
  C1 = tp.C0 + tet(3) * tp.Chat;
  p = [A1;B1;C1];
  for k=1:3
    x = [q(1),p(k,1)];
    y = [q(2),p(k,2)];
    z = [q(3),p(k,3)];
    plot3(x,y,z);
  end
  xlabel('X');ylabel('Y');zlabel('Z');
  text(tp.A0(1)-5,tp.A0(2)-3,tp.A0(3),'A0')
  text(tp.B0(1)+2,tp.B0(2)-3,tp.B0(3),'B0')
  text(tp.C0(1)+4,tp.C0(2)+2,tp.C0(3),'C0')
  text(tp.Apex(1),tp.Apex(2),tp.Apex(3)+3,'Apex')
  a = (tp.B0 + tp.C0)/2;
  b = (tp.A0 + tp.C0)/2;
  c = (tp.B0 + tp.A0)/2;
  text(a(1)-4,a(2)  ,a(3),'a');
  text(b(1)+3,b(2)  ,b(3),'b');
  text(c(1)  ,c(2)-3,c(3),'c');
  title('Tetrahedral 3D printer kinematic model definitions')
  axis([-25 25 -20 20 0 95]);
end

