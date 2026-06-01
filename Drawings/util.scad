module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();

module mirrorX(d=0) { translate([d,0,0]) children();
    mirror([1,0,0])   translate([d,0,0]) children(); }
module mirrorY(d=0) { translate([0,d,0]) children();
    mirror([0,1,0])   translate([0,d,0]) children(); }
module mirrorZ(d=0) { translate([0,0,d]) children();
    mirror([0,0,1])   translate([0,0,d]) children(); }



		
module fan40() difference() {
    hull() pairX(16) pairY(16) cylinder(r=4, h=10,$fn=36);
    translate([0,0,-1]) {
       pairX(16) pairY(16) cylinder(r=1.5,h=12,$fn=24);
    //pairX(16) pairY(16) cylinder(d=3,h=11,center=true,$fn=24);
       cylinder(d=38,h=12,$fn=48);
    }
}
module fan30() difference() {  // labeled 3007, but 8mm thick!
    translate([0,0,4]) cube([30,30,8],center=true);
    translate([0,0,-1]) {
       pairX(12) pairY(12) cylinder(r=1.5,h=12,$fn=24);
    //pairX(16) pairY(16) cylinder(d=3,h=11,center=true,$fn=24);
       cylinder(d=28,h=12,$fn=48);
    }
}
module fan3010() difference() {  // labeled 3007, but 8mm thick!
    translate([0,0,5]) cube([30,30,10],center=true);
    translate([0,0,-1]) {
       pairX(12) pairY(12) cylinder(r=1.5,h=12,$fn=24);
    //pairX(16) pairY(16) cylinder(d=3,h=11,center=true,$fn=24);
       cylinder(d=28,h=12,$fn=48);
    }
}

module fan30holes(r=1.5,h=40) translate([0,0,-1]) {
    pairX(12) pairY(12) cylinder(r=r,h=h,$fn=24);
    cylinder(d=27,h=h,$fn=64);
    translate([0,0,-5]) cube([30,30,10],center=true);
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
