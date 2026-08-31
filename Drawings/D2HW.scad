// mockup of D2HW-A201D plunger microswitch (Omron)

D2HW();

D2HWwidth = 13.2;
D2HWdepth=5.2;
D2HWheight=7.3;

module D2HW() {
    
    // let (0,0,0) be a guess at trigger point
    translate([0,0,-.5]) sphere(d=1.5,$fn=32);

    // plunger center seems to be about 3mm in from edge
    translate([D2HWwidth/2-3,0,D2HWheight/2+2.75])
        cube([D2HWwidth,D2HWdepth,D2HWheight],center=true);

    //%translate([0,0,.75]) cube([2,2,4],center=true);  // extended plunger 4mm below body
    
    translate([0,0,.4]) cylinder(d1=1.5, d2=4.8, h=3, $fn=16);
}    