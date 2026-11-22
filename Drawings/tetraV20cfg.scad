// slightly larger tetrahedral delta, 1500mm legs
// Draw the extrusions for cut-outs
// Put drawings for parts like apex and vertex in other files,
// and use this STL for cut outs.

BaseExtLen = 450;
RailTilt = 10; // degrees
TowerExtLen = 1500;  // length of extrusion
TowerRadius = 310; // at z==0 to center of extrusion
BaseRailHeight = 60;
dBaseRail = 16;  // center of base rail this far outside the tower base triangle
zApex =1458; // apex height above table

module ext20(len,kerf=.08) linear_extrude(len) ext2020cutOutProfile(kerf);


M5diam = 4.92;//4.88/2;
M5head = 8.62;//8.5;  // 5mm head height, uses 4mm hex drive
M3head = 5.36;

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();
module mirrorX(d=0) { translate([d,0,0]) children();
      mirror([1,0,0]) translate([d,0,0]) children(); }
module mirrorZ(d=0) { translate([0,0,d]) children();
      mirror([0,0,1]) translate([0,0,d]) children(); }

//%translate([0,0,2]) import("V-Slot 20x20.dxf"); ext2020cutOutProfile(0);
module ext2020cutOutProfile(kerf=.13) {
    square(20+2*kerf,center=true);
    for(a=[45:90:355]) rotate(a) hull() {
        translate([13.8,0]) circle(r=.5+kerf,$fn=12);
        translate([12,0]) square([.1,3],center=true);
    }
}
