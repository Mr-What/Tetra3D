// test/prototype for a kinematic mount, to be used to
// carry a hot-end/nozzle probe combo
RES=30;   // make larger for production  render

use <util.scad>;

//module partFanDuctJoint() translate([0,-rBase-.3,10])
//    pairX(8) cylinder(d=10,h=1,$fn=RES/2);

module blowerMount30Base() union() {
    hull() {
        translate([-2,-4]) cube(2);
        translate([24,0]) cylinder(d=6,h=2,$fn=RES/2);
        translate([16,-10]) cube(2);
        translate([0,24]) cylinder(d=6,h=2,$fn=RES/2);
    }
    translate([24,0,-2]) hull() {
        cylinder(r1=2.5, r2=4,h=4, $fn=RES/2);
        translate([-10,-18,2]) cube(2);
        translate([-10, 7,2]) cube(2);
    }
    translate([0,24,-1]) {
        hull() {
            translate([-1,0,-1]) cylinder(r1=4, r2=5,h=4, $fn=RES/2);
            translate([  -4,-48,-3]) cylinder(r=2,h=6,$fn=6);
        }
        hull() {
            translate([-5.6,-44,3.5]) pairZ(3) sphere(2.5,$fn=RES/2);
            translate([-5.6,  2,4]) pairZ(2) sphere(2.5,$fn=RES/2);
        }
    }
}


module pfdJoint1() pairX(8) sphere(5.5,$fn=RES);
module pfdJoint() pairX(10) cylinder(d=12,h=1,$fn=RES);
module partFanDuct30() {    // part fan duct, 3010 blower
    hull() { pfdJoint();
        translate([-2,-1,6]) cube([34,12,1],center=true); }
    hull() { pfdJoint();
        translate([0,2.5,-15]) pairX(16) cylinder(r=4,h=4,$fn=RES/2); }
        
    // fan mount
        //%translate([0,-50,20]) cube([30,1,50],center=true);
    translate([-9.3-2.7,5,9.5]) rotate([90,0,0]) difference() {
        blowerMount30Base();
        
        // mount holes  fan hole diameter 1.8
        // make for force thread on M2
        translate([24,0]) cylinder(r=.95,h=12,$fn=RES/3,center=true);
        translate([0,24]) cylinder(r=.95,h=6, $fn=RES/3,center=true);
    }
    %translate([0,3,21.5]) rotate([90,0,0]) fan3010();
}

module partFanDuct1() {    // part fan duct 4020 blower
    hull() { pfdJoint();
        translate([0.5,-9-19,23.45-4])
            rotate([FanTilt4020,0,0])
                cube([20,30,1],center=true); }
    hull() { pfdJoint();
        translate([0,2.5,-15]) pairX(16) cylinder(r=4,h=4,$fn=RES/2); }
        
    // fan mount
        //%translate([0,-50,20]) cube([30,1,50],center=true);
    //translate([-9.3-2.7,5,9.5]) rotate([90,0,0]) difference() {
    //    blowerMount30Base();
    translate([10,-16-31,45-15]) rotate([FanTilt4020,0,0])
       blower4020mount();
        
    %translate([10-.3,-16-31,30]) rotate([FanTilt4020,0,0]) rotate([0,90,180]) blower4020();
}

module fanDuctMount(fuzz=0) pairX(10) cylinder(r1=6+fuzz,r2=4+fuzz,h=3,$fn=RES);

// tight holes to force-screw M3 into plastic
//translate([0,0,-50]) difference() { fan30screwMount(); #fan30holes();}
module fan30screwMount(h=20) { *%translate([0,0,-10]) fan3010();
    for(a=[45:90:355]) rotate(a) translate([12*sqrt(2),0,0]) hull() {
        cylinder(r1=4,r2=5,h=8,$fn=RES/2);
        translate([-4,0,2]) cube([1,12,4],center=true);
    }
    cylinder(r=15,h=h,$fn=RES*1.5);
}


module fan30mount(h=20) { %translate([0,0,-10]) fan3010();
    difference() {
        union() {
            for(a=[45:90:355]) rotate(a) translate([12*sqrt(2),0,0]) hull() {
                cylinder(r=4,h=4,$fn=RES/2);
                translate([-6,0,4]) cube([1,12,8],center=true);
            }
            cylinder(r=15,h=h,$fn=RES*1.5);
        }
        translate([0,0,3]) pairX(12) pairY(12) cylinder(d=5.5,h=6,$fn=RES/2);
        translate([0,0,-1]) {
            pairX(12) pairY(12) cylinder(r=1.6,h=12,$fn=RES/2);
            cylinder(d=27,h=h+2,$fn=RES*1.5);
        }
    } 
           
}
module fan40mount(h=20) { %translate([0,0,-10]) fan40();
    difference() {
        union() {
            for(a=[45:90:355]) rotate(a) translate([16*sqrt(2),0,0]) hull() {
                cylinder(r=4,h=4,$fn=RES/2);
                translate([-6,0,4]) cube([1,12,8],center=true);
            }
            cylinder(r=20,h=h,$fn=RES*1.5);
        }
        translate([0,0,3]) pairX(16) pairY(16) cylinder(d=5.5,h=6,$fn=RES/2);
        translate([0,0,-1]) {
            pairX(16) pairY(16) cylinder(r=1.6,h=12,$fn=RES/2);
            cylinder(d=37,h=h+2,$fn=RES*1.5);
        }
    } 
           
}  

/* $Id$
$Log$
*/
