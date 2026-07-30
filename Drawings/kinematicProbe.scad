// probe which can be swapped out for hot-end.  Adjustable
// to match nozzle position
//
//  Use 306/304/316 stainless balls instead of 440C or carbon steel
//  for less pre-load than to keep hot end in place for printing
RES=24;

//import("hotEnd.stl");

//%import("hotEndFrame.stl");
//import("kinEffector.stl");
use <kinematicMount.scad>;
//%hotEndFrame();
//%effector();

//use <hotEnd.scad>; %translate([0,0,10]) rotate(180) hotEnd();

kinematicProbe();

module kinematicProbe() difference() {
    kinematicProbeFrame();
    
    kinMountBalls(nf=RES);
    
    // make top flat
    translate([0,0,30.9]) cube([60,60,20],center=true);
        
    // show bolt for probe a little low, so there is room to grind a point
    #translate([0,0,-12+8]){
        
        // use extra long bolt, so we can adjust at top with nut
        // bore for M3 bolt as probe
        cylinder(d=3,h=40,$fn=16);     // show bolt for probe
        
        // *** use very long full-thread bolt so we can adjust depth
        // with nut at top
        //// deep cap hole so we can use common 25mm M3 socket head bolt
        //// actual head about 05.4
        //translate([0,0,25]) cylinder(d1=5.4,d2=6,h=9,$fn=RES/2);

        // actual M3 nuts tend to be about 5.9mm corner to corner
        translate([0,0,6]) cylinder(d2=5.8, d1=6,h=3,$fn=6);
        
    }
    
    //translate([0,25,0]) cube(50,center=true);
}

module kinematicProbeFrame() union() {
    ballMounts(nf=RES);
    
    for (a=[90,210,330]) rotate(a) hull() {
        translate([18,0,18]) sphere(5,$fn=RES);
        translate([4,0,21]) cube([.1,16,.1],center=true);
        #translate([6,0,2+4]) rotate([0,90,0]) cylinder(r=2,h=.1,$fn=RES/2);
    }
    
    // try to make bottom exactly level with effector bottom
    //%translate([0,0,-5]) cylinder(r1=8,r2=18,h=26,$fn=6);
    hull() {
        for(a=[90:120:355]) rotate(a) 
            translate([16,0,22.9]) cylinder(r=4,h=.1,$fn=RES);
        for(a=[0:60:355]) rotate(a) 
            translate([ 5,0,-2.5+8]) sphere(2.5,$fn=RES);
    }
}
