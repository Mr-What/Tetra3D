// test/prototype for a kinematic mount, to be used to
// carry a hot-end/nozzle probe combo
RES=30;   // make larger for production  render

FanTilt4020=45;  // tilt of mount for 4020 blower


//difference() {  
//translate([0,-rBase,7.8])
fanDuct4020(withSupport=true);
//translate([0,-100,0]) cube(100);}

D4020=35;  // distance between centers of 4020 mount holes

//blower4020();
module blower4020() {
    //%translate([0,0,10]) cube([40,40,20],center=true);
    cylinder(r=20,h=20,$fn=64);
    
    #translate([1,-20+1.2,1.5]) cube([20,26,16.5]);
    difference() {
        on4020bolts() cylinder(r=3,h=13,$fn=24);
        boltHoles4020();
    }
}
module on4020bolts() {
D2 = D4020/2;
    for (p=[[D2,D2],[-D2,D2],[-D2,-D2]])
        translate(p) children();
}
module boltHoles4020() translate([0,0,6]) on4020bolts()
    cylinder(d=3,h=16,$fn=24,center=true);


use <util.scad>;

hasMountOverlap = true;  // true to cut out for switchMount

//module partFanDuctJoint() translate([0,-rBase-.3,10])
//    pairX(8) cylinder(d=10,h=1,$fn=RES/2);

module pfdJoint() pairX(10) cylinder(d=12,h=1,$fn=RES);

module blower4020mount() difference() {
    union() {
        rotate([0,90,0]) hull() {
            pairX(35/2-.5) pairY(35/2-.5) cylinder(r1=3.5,r2=5,h=3,$fn=RES/2);
            translate([35,0,0]) cube(3);
        }
    
        // braces    
        hull() {
            translate([3,18,18]) sphere(d=6,$fn=RES/2);
            translate([3,-3,-28]) sphere(d=6,$fn=RES/2);
        }
        hull() {
            translate([3,-18,18]) sphere(d=6,$fn=RES/2);
            translate([3,3,-14]) sphere(d=6,$fn=RES/2);
        }
        hull() {
            translate([3,-18,-17.5]) sphere(d=6,$fn=RES/2);
            translate([3,2,-16]) sphere(d=6,$fn=RES/2);
        }
    }

    rotate([90,0,90]) on4020bolts() {
        #cylinder(d=3.1,h=6,$fn=RES/2);
        // M3 nut uses 5.5 wrench, but nuts often measure 5.3.
        // tip to tip they are measuring around 5.9
        translate([0,0,3-.5]) cylinder(d1=5.8,d2=6.1,h=4,$fn=6);
    }
}

module fanDuctMount(fuzz=0) pairX(10) cylinder(r1=6+fuzz,r2=4+fuzz,h=3,$fn=RES);

module fanDuct4020(withSupport=false) {
    %translate([10-.3,-44,31.5]) rotate([FanTilt4020,0,0])
        rotate([0,90,180]) blower4020();

    difference() {
        fanDuct4020body();
        fanDuct4020interior();
        
        // cut out any obstruction from switchMountRx
        if (hasMountOverlap) translate([-1.75,15,-19.5])
            %import("switchMountRx.stl");
    }
    
    //not actual support, but designed to improve support performance
    if (withSupport) {
        *hull() {
            translate([0,-9,.05]) cube([30,1,.1],center=true);
            translate([-3,-36,8.2]) cube([12,.1,1],center=true);
        }
        *hull() {
            translate([10,-46,1]) cube([10,1,2],center=true);
            translate([12,-20,3]) cube([4,.1,1],center=true);
        }
        #hull() {
            translate([12.5,-47,1.3]) cube(1);
            translate([12.5,-73,27.3]) cube(1);
            translate([12,-75,0]) cube([2,25,2]);
        }
    }
}

module fanDuct4020body() {
    hull() {
        fanDuctMount(1.5);
        translate([0,0,6]) fanDuctMount(1);
        translate([0,-25,20]) rotate([FanTilt4020,0,0])
            cube([20,30,1],center=true);
    }
    translate([10,-44,31.5]) rotate([FanTilt4020,0,0])
       blower4020mount();
        
}
module fanDuct4020interior() {
    translate([0,0,-.1]) hull() fanDuctMount(.1);
    hull() {
        translate([0,0,2.8]) pairX(10) cylinder(d=9,h=1,$fn=RES/2);
        translate([0,-25,20.5]) rotate([FanTilt4020,0,0])
            cube([18,27,1],center=true);
    }
}    


/* $Id$
$Log$
*/
