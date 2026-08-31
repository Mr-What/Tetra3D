// mock up of mellow multuhead zero tool, which seems to be
// a well machined plunger activating a common microswitch. 
// It may be a very cost effective solution for calibration probing
// a plate with fiducials.  Constrained Z-only motion may give
// more reliable readings when contact is slightly off-center

// seems to trigger about .5mm up from resting position

mellowMultiheadZero();

module mellowMultiheadZero() {
    translate([0,0,9.9/2-.5]) sphere(d=9.9,$fn=32);
    translate([0,0,12]) {
        cylinder(d=10.9,h=15,$fn=24);
        difference() {
            translate([0,0,10+22/2]) cube([20,17.3,22],center=true);
            #translate([0,0,10+10]) rotate([-90,0,0]) pairX(13/2)
                cylinder(d=3.15,h=40,center=true,$fn=24);
            translate([0,-17.3/2-.1,10+10]) rotate([-90,0,0]) pairX(13/2)
                cylinder(d=5.7,h=3.9,$fn=24);
            #pairX(16/2) pairY(10.5/2) cylinder(d=3,h=5+10,$fn=16);
        }
    }
    translate([11.5,0,41.25-3.5]) cube([3,7.4,5.5],center=true);
    
}

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
