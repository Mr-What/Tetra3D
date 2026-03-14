// lower flange to align with motor seems to be about 19mm from extrusion
// I think this will need about a 32mm M5 bolt

RES=30;

difference() { idlerMountEnvelope();
    cylinder(r=2.5,h=44,center=true,$fn=RES/2);
    
    pairX(13) { cylinder(r=1.5,h=44,center=true,$fn=RES/2);
        translate([0,0,5]) cylinder(r1=2.6,r2=4,h=10,$fn=RES);
    }
} 
    
module idlerMountEnvelope() union() {
    // M5 regular nut, 3.5mm thick, 
    //         add another 1mm for washers???
    translate([0,0,3]) cylinder(r2=3.5,r1=9,h=16-3.5-1,$fn=RES);

    hull() {
        translate([0,0,2]) pairX(16) pairY(8) sphere(2,$fn=RES);
        translate([0,0,12]) cylinder(r=4,h=.1,$fn=RES);
    }
}

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
