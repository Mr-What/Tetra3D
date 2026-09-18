// Kinematic Mount for BTT microprobe 2.0
RES=24;


use <kinematicMount.scad>;
//%import("hotEndFrame.stl");
//%import("kinEffector.stl");
//hotEndFrame();
//effector();

//%use <hotEnd.scad>; showHotEnd hotEnd();
//showHotEnd() import("hotEnd.stl");
module showHotEnd() translate([0,0,10]) rotate(180) children();

//%translate([0,0,50])
//kinematicProbe();  // kinematic mount contacts wired as probe

//kinematicSwitchMount(); // mount for common microswitch as probe
//kinMicroprobeV2mount();
//kinMMZmount();  // Mellow Multihead Zero as probe
kinD2HWmount();  // For Omron D2HW plunger microswitch

D2HWyOff=4.2;
module kinD2HWmount(slop=.2) difference() { d2hwFrame();

    #kinMountBalls(nf=RES);

    translate([0,D2HWyOff,-4.1]) cube([5.2+slop, 13.4+slop, 7.9],center=true);
    hull() {
        translate([0,D2HWyOff,0.25]) cube([4,12.8,1],center=true);
        translate([0,0,21]) cylinder(r=7,h=1,$fn=RES*1.5);
    }
    
    translate([0,0,30.9]) cube([60,60,20],center=true); // flat top
    
    // JST-XH 2.4 plug has 4x1 key that needs to fit through
    // for a pre-wired endstop
    // cut out a notch
    translate([-2.5,3,1.5]) cube([1,4,6+4],center=true);
    
    //translate([0,-30*0,-12]) cube(100);
    //translate([-102,-30,-2]) cube(100);
    //%difference() {cylinder(r=26,h=1,$fn=90); cylinder(r=1,h=5,center=true,$fn=24);}
   %translate([0,0,-11]) rotate(90) import("D2HW.stl");
}
module d2hwFrame() union() { kinematicProbeFrame();
    hull() {
        translate([0,D2HWyOff,-3])
            pairX(3) pairY(7) sphere(2,$fn=RES/2);
        
        translate([0,0,14]) for(a=[0:120:355]) rotate(a)
            translate([0,13,0]) cylinder(r1=.1,r2=3,h=1,$fn=RES/2);
    }
}


use <mellowMultiheadZero.scad>;
module kinMMZmount(slop=.2) difference() { mmzFrame();

    #kinMountBalls(nf=RES);

    // clear area around tool base
    cylinder(d=11+2*slop,h=40,$fn=RES);
    translate([0,0,22]) hull() {
        cube([20+2*slop,17.3+2*slop,22+1.95+1.95],center=true);
        // add a little dome to indent to print better
        translate([0,0,-22/2-.7-1.5]) cylinder(d=11.5,h=1,$fn=RES);
    }        

    // screw holes for mount     
    pairX(16/2) pairY(10.5/2) cylinder(d=3.1,h=5+10,$fn=16);
   
    cylinder(d=5,h=50,$fn=RES);  // M5 hole in center, no good reason
    
    translate([0,0,30.9]) cube([60,60,20],center=true); // flat top
    cylinder(r=24,h=4,$fn=6); // flat bottom
    
    // probe test 260906 had z-offset at 1.95.
    // -12.95 expected to have trigger very close to where nozzle
    // contacts bed.
    %translate([0,0,-11-1.95]) import("mellowMultiheadZero.stl");
}

// add extra bracing to make up for Mellow Multihead Zero tool
module mmzFrame() union() { kinematicProbeFrame();
    hull() {
        translate([0,0,4]) {
            // brace around mount holes
            #pairY(10.5/2) pairX(16/2) cylinder(d1=8, d2=3, h=9, $fn=RES);
            //translate([0,12,4])         cylinder(d1=6, d2=1, h=1, $fn=RES);
        }
        translate([0,0,21]) {
            translate([0,-9]) pairX(17) cylinder(r1=5, r2=3, h=1, $fn=RES);
            translate([0, 9]) pairX(10) cylinder(r1=5, r2=3, h=1, $fn=RES);
            translate([0,18]) cylinder(r1=6, r2=4, h=1, $fn=RES);
        }
    }
}


module kinMicroprobeV2mount() difference() { microprobeFrame();

    #kinMountBalls(nf=RES);

    // clear area around switch
    mirror([1,0,0]) microprobeEnvelope();
                    microprobeEnvelope();

    // wire hole
    hull() translate([0,-8.7,12]) pairX(6) cylinder(d=3,h=20,$fn=RES/2); 
        
    // mount holes.  Sensor holes slightly smaller than M3
    //   Drill them out to be free around M3 bolts
    // Make mount holes slightly less than M3. 
    //   can try to force thread into plastic, or drill out to use nuts
    //  kit comes with 02.3 bolts.  perhaps M2.5?  drill small to thread:
    translate([0,-2.75,0]) pairX(17/2-.04) cylinder(d=2.3,h=40,$fn=RES/2);
        
    cylinder(d=5,h=50,$fn=RES);  // M5 hole in center, no good reason
    
    // make top flat
    translate([0,0,30.9]) cube([60,60,20],center=true);
    
    // make bottom flat
    cylinder(r=20,h=10,$fn=6);
}

module microprobeEnvelope() linear_extrude(18.2) polygon([
            [-.1,6.5],[2.3,6.5],[6.5,4.5],[6.5,1.5],[11.5,0],
            [11.5,-5],[9,-7],[6.5,-7],[6.5,-10],
            [-.1,-10]]);


// add extra bracing to make up for microprobe carve-out
module microprobeFrame() union() { kinematicProbeFrame();
    hull() {
        translate([0,0,9]) {
                               pairX(10) cylinder(r1=1, r2=3, h=1, $fn=RES); 
            translate([0,-8])  pairX(10) cylinder(r1=1, r2=5, h=1, $fn=RES);
            translate([0,11])            cylinder(r1=1, r2=5, h=1, $fn=RES);
        
        }
        translate([0,0,21]) {
            translate([0,-9]) pairX(17) cylinder(r1=5, r2=3, h=1, $fn=RES);
            translate([0,18]) cylinder(r1=6, r2=4, h=1, $fn=RES);
        }
    }

    %translate([-9.65,35.3,-3]) rotate([90,0,90])
        import("microprobe_v2_mockup.stl");
}


use <microswitch.scad>;
module kinematicSwitchMount() union() {
    
    difference() {
        union() { kinematicProbeFrame();
            hull() {
                translate([-7.25+9.5/2,3,-2.5]) pairX(9.5/2) rotate([-90,0,0])
                    cylinder(r1=4,r2=3,h=5,$fn=RES);

                translate([0,3+6,12]) pairX(5) sphere(r=5,$fn=RES);
            }
        }
        
        kinMountBalls(nf=RES);
        translate([-2.5,8,2.5]) microswitchHoles(fuzz=-.2,len=16);
        // in case they want nuts
        translate([-2.5,7,2.5]) microswitchNutHoles();
        
        // clear area around switch
        translate([-2.5+3,-3,-2]) cube([21+5,12,20], center=true);
        
        // M5 hole in center, so you can choose switch or kinematic mount sensor
        cylinder(d=5,h=50,$fn=RES);
    
        // make top flat
        translate([0,0,30.9]) cube([60,60,20],center=true);
    }
 
    // extra brace for switch cut-out -- not needed after adjusting for correct hot end position
    //#hull() {
    //    translate([0,-8,13]) pairX(12) sphere(3,$fn=RES);
    //    translate([0,-4, 18]) cube([28,1,1],center=true);
    //}    
    
    %translate([0,0,-10]) microswitch();
}

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

module microswitchNutHoles(nutDiag=4.3) rotate([-90,0,0]) pairX(9.5/2)
    rotate(30)
    cylinder(d1=nutDiag-.1,d2=nutDiag+.4,h=4,$fn=6);

module kinematicProbeFrame() union() {
    ballMounts(nf=RES);
    
    for (a=[90,210,330]) rotate(a) hull() {
        translate([18,0,18]) sphere(5,$fn=RES);
        translate([4,0,21]) cube([.1,16,.1],center=true);
        translate([6,0,2+4]) rotate([0,90,0]) cylinder(r=2,h=.1,$fn=RES/2);
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
