// lower flange to align with motor seems to be about 19mm from extrusion
// I think this will need about a 32mm M5 bolt

RES=24;

BeltWidth=6;
BeltClearance = 20;
CenterHeight = BeltClearance + BeltWidth/2;

CR=2;  // corner radius

$t=0;  // 0..1 for animation
translate([45-10*$t,0,0]) {
%armProxy();
translate([0,0,23]) { %mirror([0,0,1]) idlerClamp();

idlerClamp();}}
screwBase();

use <util.scad>;

thickM5 = 4.5;  // for M5-10-12mm socket head
//thickM5 = 2.5;  // for M5-8mm socket head

module screwBase() difference () { screwBaseBody();
    translate([2,0,thickM5]) pairX(12) M5socketHeadHole();
    translate([-3,0,CenterHeight])  // M3 hole
        rotate([0,-90,0]) M3socketHeadHole();
    translate([17,0,CenterHeight]) idlerBrace(CR+.1);
    
    //translate([10,0,10+23]) cube(20,center=true);
}

module idlerClamp() difference() { idlerClampBody();
    cylinder(d=5+.1,h=55,center=true,$fn=RES);
    translate([-21,0,0]) rotate([0,90,0]) {
        cylinder(d=3,h=40,center=true,$fn=24);
        // nyloc diameter 6.0mm, total height 4
        rotate(30)
            //cylinder(d1=6.1,d2=6.4,h=5,$fn=6);  // captured
            cylinder(d1=6.1,d2=6.4,h=15.1,$fn=6);  // open
    }
    translate([-20-8+3,-4  ,0]) rotate([180,0,0]) key(0);
    translate([-20+4+3, 4.8,0]) rotate([180,0,0]) key(-.1,1,2);
    //translate([-40,0,-20]) cube(50);
}

module idlerClampBody() union() { //%idlerClampBodyFull();
    translate([0,0,-9]) idlerSide();
    translate([-17,0,0]) idlerBrace();
}
//module idlerClampBodyFull() union() {
//    mirrorZ(-8.5) idlerSideFull();
//    translate([-20,0,0]) idlerBrace();
//}
module idlerBrace(r=CR) union() {
    dTop = (r>CR) ? 8 : 0;  // make taller for cut-out
    hull() translate([-3,0,0]) pairX(8) pairY(4.5) {
        translate([0,0,-10.5]) corner(r);
        translate([0,0,dTop-1  ]) cylinder(r=r,h=1,$fn=RES/2);
    }
    if(r==CR) { // actual fork, not cut-out
        translate([-8, 4  ,0]) key(-.1);
        translate([ 4,-4.8,0]) key(0,1,2);
    }
}
module key(slop=.1,len=1.5,d=2.8) translate([0,0,-.05]) hull() pairX(len)
    cylinder(d1=d+slop,d2=1+slop,h=1+slop,$fn=RES/2);

module idlerSide() {
    translate([0,0,2.5]) cylinder(d1=11,d2=7,h=2,$fn=RES);
    hull() { baseTorus();
        translate([-12,0,0]) pairY(4.5) pairZ(1.5)
        rotate([0,90,0]) cylinder(r=CR,h=1,$fn=RES);
    }
}
//module idlerSideFull() {
//    translate([0,0,2]) cylinder(d1=9,d2=6.5,h=2,$fn=RES);
//    translate([-6,0,0]) hull()  pairX(6) baseTorus();
//}

module baseTorus() rotate_extrude($fn=2*RES)
    translate([4.5,0]) pairY(1.5) circle(CR,$fn=RES);

module screwBaseBody() translate([2,0,0]) hull() {
    translate([0,0,CR]) pairX(16) pairY(10-CR) corner();
    translate([-16,0,6]) pairY(5) corner();
    translate([6,0,CenterHeight+2]) pairX(10) pairY(10-CR) corner();
}



module armProxy() {
    translate([0,0,23]) difference () {
        cylinder(d=18,h=8.6+.2,$fn=36,center=true);
        cylinder(d=12,h=10,$fn=36,center=true); //diameter, to outside of teeth
    }
    translate([-30,0,-10]) cube([120,20,20],center=true);
    translate([40,0,3+20]) pairY(6) cube([80,2,6],center=true);
    //%translate([8,0,0]) cube(20);  // 20mm to bottom of belt
    //%cube(4);  // M5 nuts often 4mm thick
}

module corner(r=CR) sphere(r,$fn=RES);
