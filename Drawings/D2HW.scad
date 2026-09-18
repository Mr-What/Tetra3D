// mockup of D2HW-A210D plunger microswitch (Omron)

D2HW();

D2HWwidth = 13.4; // from drawing:13.2;
D2HWdepth=5.2;
D2HWheight=7.3;

module D2HW() translate([0,0,0.75]) {  // trigger point at origin
    
    // let (0,0,0) be a guess at trigger point
    translate([0,0,-.5]) sphere(d=1.5,$fn=24);

    // plunger center seems to be 2.5mm in from edge
    // plunger tip 4mm below body, extended
    translate([D2HWwidth/2-2.5,0,D2HWheight/2-1.25+4])
        cube([D2HWwidth,D2HWdepth,D2HWheight],center=true);

    //%translate([0,0,.75]) cube([2,2,4],center=true);  // extended plunger 4mm below body
    
    translate([0,0,.25]) cylinder(d1=1.1, d2=5, h=2.5, $fn=24);
}

// trigger is about 0.5mm from extended tip
%translate([0,0,-.25])  cube([3,3,.5],center=true);