// test/prototype for a kinematic mount, to be used to
// carry a hot-end/nozzle probe combo
RES=30;   // make larger for production  render

use <util.scad>;

PosSwitchMag = [0,-3.1,-0.2];

//%import("switchMount1.stl");
//%translate([0,-4.9,7.05]) import("switchMountRx1.stl");

%switchMount();  // true for proxy in glue jig

//magMountJig();

MagCenterY = -7;
MagZ = 11.5;
MountX = 14;
EffZ = 7;  // bottom of effector level

//translate([0,-MagCenterY,-4.5])
switchMountRx(true);  // true == proxy for glue jig

// mostly just for testing.  Production use, this
// assembly is added to effector, then at end
// holes are dirlled
module switchMountRx(proxy=false) difference() union() {
    difference() {
        switchMountRxBody();
        switchMountRxHoles();
            
        if (proxy) {
            // make top flat for possible clamp
            translate([-10,-15,16.5]) cube(20);
            // make sure bottom does not quite touch mount
            translate([-10,-15,-12]) cube(20);
        }
    }
        
    if (proxy) translate([0, MagCenterY,EffZ+7.3])
        cylinder(d1=4.5,d2=7,h=2.2,$fn=RES/2);
}

// flat area for clamp on mount
//difference() { translate([0,MagCenterY,2]) cube([16,16,5],center=true);  scale(1.02) #switchMount(); }

// plunger to mount magnet in effector
//union() { cylinder(d2=5.7,d1=5,h=11,$fn=RES); cylinder(r1=5,r2=2,$fn=6,h=4); }

// plug for when switch not in place
//translate([0,0,EffZ+1])
//difference() { cylinder(d1=6/cos(30),d2=6/cos(30)-.2,$fn=6,h=6);
//    translate([0,0,4]) cylinder(d=6,h=4,$fn=RES);
//    cylinder(d1=3.1,d2=2.8,h=8,$fn=16); }

module mountEdge() translate([0,-4.25,EffZ-1.25])
    pairX(MountX/2-1) sphere(d=2.5,$fn=RES/2);

module switchMount(proxy=false) { %nanoSwitch();
    difference() {
        union() {
            // magnet post
            translate([0,MagCenterY,EffZ-.1])
                cylinder(r=3/cos(30)-.05,h=4.8,$fn=6);
            
            if (proxy) {  // add proxy magnet for glue jig
                translate([0,MagCenterY,EffZ+4.5])
                    cylinder(d1=6,d2=5,h=4,$fn=RES/2);
            } else {
                // add a temporary alignment piece, to be removed
                // after magnet is glued in place
                difference() {
                    translate([0,MagCenterY,EffZ+4.6])
                        cylinder(d=8,h=2,$fn=6);
                    translate([-5,-5.7,8]) cube(10);
                }
            }
            
            //%translate([0,-8,3+1]) cube([MountX,10,6],center=true);
            //%translate([0,-4.25,8]) cube([MountX,2.5,10],center=true);
            hull() { mountEdge();
                translate([0,-4.25,EffZ+6])
                    pairX(MountX/2-2) sphere(d=2.5,$fn=RES/2);
            }
            hull() { mountEdge();
                translate([0,-12,EffZ-1])
                    pairX(MountX/2-2) sphere(1,$fn=RES/2);
                translate([0,-10,4])
                    pairX(MountX/2-3) sphere(2,$fn=RES/2);
                translate([0,-4.25,2])
                    pairX(6) sphere(1.25,$fn=RES/2);
            }

        }
        
        if (proxy) translate([-10,MagCenterY-8,-16])
            cube(20);   // chop off for flat bottom
        else {
            // clear out magnet zone
            #translate([0,MagCenterY,MagZ]) cylinder(d=6.2,h=3,$fn=RES/2);
        
            // M2 screw holes, self-tap
            translate([0,0,5.7]) pairX(3) rotate([90,0,0])
                cylinder(d1=2.2,d2=1.7,h=7,$fn=RES/2);
        }
    }
}

module switchMountRxBody(p=[0,0,0]) translate(p) hull() {
    translate([-MountX/2,-11.5,EffZ]) cube([MountX,6,1]);
    %translate([-3.5,-10.5,EffZ+11]) cube([7,5,1]);
    translate([0,-6.5,EffZ+12]) pairX(3.5) sphere(1,$fn=RES/2);
    translate([0,-11,EffZ+13.5]) cube([5,.1,.1],center=true);
}

module switchMountRxHoles(p=[0,0,0]) translate(p) {
    translate([0,MagCenterY,MagZ]) {
        // clear area including switch magnet
        cylinder(d=6.1,h=6.4,$fn=RES/2);
 
        // give magnet mount an inverse taper, so that any spread on the corner
        // is less likely to keep the magnet from seating properly
        #translate([0,0,3]) hull() {
            cylinder(d1=5.9,d2=6.2,h=3.2,$fn=22);
            cylinder(d=.1,h=3.8,$fn=6);  // flat ceiling hard to print
        }
    }
    
    translate([0,MagCenterY,6.8]) cylinder(d=0.2+ 6/cos(30),$fn=6,h=7);
}

//%translate([0,25,13]) rotate([180,0,0]) import("kinEffector.stl");
module magMountJig() difference() { rotate([90,0,0])
    cylinder(d=16.5,h=12,$fn=4,center=true);
    translate([0,0,-10]) cube(20,center=true);
    translate([0,0, 16.3]) cube(20,center=true);
    #translate([0,0,5.5]) mirrorX(3.4) rotate([0,45,0]) hull() {
                         cylinder(d=6.2,h=3,$fn=RES,center=true);
        translate([3,0]) cylinder(d=6.2,h=3,$fn=RES,center=true);}
}

/* $Id$
$Log$
*/
