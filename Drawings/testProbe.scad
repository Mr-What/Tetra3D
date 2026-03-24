// endstop for probe tests using effectorC from kossel drawings.
use <microswitch.scad>;

%rotate([180,0,30]) import("effectorC.stl");
%translate([-2.5,-0.5,12]) microswitch();

nutRad = 5.46/2/cos(30);

difference() { union() {
    translate([-2.5,5,9.5]) cube([20,5,18],center=true);
    cylinder(r1=19,r2=18,h=3,$fn=64);
    for(a=[60:60:355]) rotate(-a) translate([-12.5,0,2]) cylinder(r1=5.6, r2=4.8,h=3,$fn=32);
  }
  
  for(a=[60:60:355]) rotate(-a) {
      translate([-12.5,0,-11]) cylinder(r=1.55,h=21,$fn=32);
      translate([-12.5,0,2]) cylinder(r1=nutRad, r2=nutRad+.3,h=6,$fn=6);
  }
  for (d=[-1,1]) translate([d*4.75-2.5,0,12]) rotate([90,0,0])
      cylinder(r=1.05,h=20,center=true,$fn=16);
}
