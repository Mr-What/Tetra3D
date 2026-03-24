// $Id: frogCarriage20v.scad,v 1.1 2026/03/15 21:05:29 aaron Exp aaron $
// frog carriage design, for OpenBuilds 20mm V-slot extrusion,
// with low-profile OpenBuilds solid v-wheels

include <configuration.scad>;
use <beltCatch.scad>;
use <rodMountHorn.scad>;
use <v20ext.scad>;

RES=32;  // set higher for final render

thickness = 6;


belt_width = 6;
belt_x = 5.6;
belt_z = 7;

extrusion_width = 20;
horn_width=50;

// Parameters for wheeled base
base_thickness = 11; // wheel carriage level thickness

//wheel_radius = 11.9;  // larger v-slot wheel
wheel_radius = 15.23/2; // openbuilds solid low-profile v delrin wheels
wheel_slot_penetration = 1.75; // wheel rides this far inside slot
wheel_dx = extrusion_width/2+wheel_radius-wheel_slot_penetration;


wheel_offset = 25;  // wheel pair wheelbase
boltSep = 12; // tension bolt seperation half-dist

m3_head_radius=5.36/2+0.2;
m3rad = 2.94/2+0.15;  // tight fit, at least for vertical m3 screw holes.
m3nutRad = 5.45/2/cos(30);

m5rad = 4.92/2 + 0.2;//4.88/2;
m5_head_radius = 8.62/2;//8.5/2;  // 5mm head height, uses 4mm hex drive

hornAxisHeight = 13/2;


frogCarriage();

//%translate([wheel_dx+20*0,0,0]) mobileWheelMount(0);

%overlays();  // Show wheels, belts, etc.

//difference() { endstopPad(); wheelBase(); #translate([-20,0,0]) cube(50);}



module frogCarriage() {
  difference() {
    union() {
      translate([0,0,base_thickness-.4]) mirror([1,0,0]) carriage();
      wheelBase();
    }

    wheelBaseHoles();

    // extra clearance for extrusion rail
    //#translate([-9, -30,-.1]) cube([18,60,1.5]);
  }
}

module overlays() {
  clearance=0.5; // adjust for expected rail clearance in z:
  translate([0,50,-10-clearance]) rotate([90,0,0]) v20ext(100);

  translate([ 10+wheel_radius-1.3,  0,-10-clearance]) vWheel();
  translate([-10-wheel_radius+1.3, 25,-10-clearance]) vWheelLow();
  translate([-10-wheel_radius+1.3,-25,-10-clearance]) vWheel();
    
      // Timing belt (up and down).
  translate([0,0,belt_z + belt_width/2 + 10.6]) pairX(belt_x)
     cube([1.7, 120, belt_width], center=true);

  // check horn seperation
  //translate([0,0,25]) cube([40,4,4],center=true);
}

module ballJointMountHorns() {
  translate([0,0,hornAxisHeight])
    difference() {
      intersection() {
        rodMountHorn(horn_width);  // tip separation distance, mm
        cube([51,16,hornAxisHeight*2],center=true);
      }
      translate([-2,0,0]) cube([16,50,22],center=true);
    }
}

module carriage() {
  difference() {
    union() {
      // Main body
      hull() {
        translate([-9.5,-15,-.5])         cube([19.2,30,1]);
        translate([-9.5, -8,thickness-1]) cube([19.2,16,1]);
      }

      ballJointMountHorns();
 
      mirrorX(10) hornSupport();

      translate([2.1,0,3.5]) mirrorY(8.1) mirror([1,0,0]) beltCatch(9.5);
      
      // belt catch support/fill
      translate([ 3  ,-24,3.5]) cube([4,48,3.5]);
      translate([-1.6,-16,3.5]) cube([6,32,3.5]);
    }

    // Screws for ball joints.
    translate([0,0,hornAxisHeight]) rodMountHornBore(boreLen=13);

  }
}

module hornSupport() hull() {
    pairY(7) cylinder(h=13,r=1.25,$fn=RES);
    pairY(20) translate([1,0]) scale([3,4,1]) cylinder(h=1,r=1,$fn=RES);
    translate([horn_width/2-9.5-6,0,-2]) pairY(wheel_offset/2)
           cylinder(r=1,h=.1,$fn=RES/2);
}

module wheelAxleBrace() {
  intersection() {
    cylinder(h=base_thickness+5,r=7,$fn=RES);
    translate([0,0,-5.3]) scale([1,1,2.5]) sphere(10,$fn=RES);
  }
}
module wheelAxleHole(dHeadRad) {
  translate([0,0,-30]) cylinder(h=60,r=m3rad,$fn=13);
  translate([0,0,base_thickness-1])
    cylinder(h=9,r1=m3_head_radius-.1+dHeadRad,
                 r2=m3_head_radius+.5+dHeadRad,$fn=30);
}
module wheelAxleHole5(dHeadRad) {
  translate([0,0,-40]) cylinder(h=60,r=m5rad,$fn=13);
  cylinder(h=11,r1=m5_head_radius-.1+dHeadRad,
                  r2=m5_head_radius+.5+dHeadRad,$fn=30);
}
module mobileWheelMount(dilation) {
bthick = base_thickness + 2*dilation;
br = 7 + 2*dilation;
  difference() {
    hull() {
      translate([-br,0,base_thickness/2])
        rotate([0,90,0]) for (a=[-1,1]) {
          translate([0,boltSep*a,0])
            intersection() {
              cylinder(h=18+99*abs(dilation),r=bthick*0.55,$fn=6);
              cube([bthick,20,60],center=true);
            }
        }
    }
    if (dilation==0) { // this is the ACTUAL mount, not a socket, add screw holes
      translate([0,0,bthick-5.1]) wheelAxleHole5(0);
      translate([0,0,bthick/2  ]) rotate([0,90,0]) {
        for (i=[-boltSep,boltSep]) {
          translate([0,i,-1]) wheelAxleHole(-0.1);
        }
      }
    }
  }
}

module cableCatchBrace() {
  hull() {
    translate([25.7,-5,0]) cylinder(r1=3,r2=1,h=5,$fn=RES/2);
    translate([26,-5,11]) sphere(2,$fn=RES/2);
    translate([ -7,-11,0]) cylinder(r1=2,r2=1,h=14,$fn=4);
    translate([  10,10,0]) cylinder(r=1,h=17,$fn=4);
  }
}

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module mirrorY(d) {
  mirror([0,1,0]) translate([0,d,0]) children();
                  translate([0,d,0]) children();
}
module mirrorX(d) {
  mirror([1,0,0]) translate([d,0,0]) children();
                  translate([d,0,0]) children();
}


module wheelBase() {
supportSpread = 6;
  difference() {
    union() {
      for (i=[-wheel_offset,wheel_offset]) {
        hull() { // main wheel axle screw holder pair
          translate([-wheel_dx, i,0]) wheelAxleBrace();
          translate([-wheel_dx+30,(i<0)?i+5 :i-5 ,0]) cylinder(r=1,h=10,$fn=8);
          translate([-wheel_dx+5 ,(i<0)?i+20:i-20,0]) cylinder(r=1,h=12 ,$fn=8);
        }
      }

      // tension screw housing pair
      translate([-1,0,base_thickness/2]) rotate([0,90,0]) 
        hull() translate([0,0,-20]) pairY(boltSep)
          cylinder(r=5.5,h=20,$fn=RES);

      // brace section for mobile mount 
      hull() {
        translate([-5,0,base_thickness/2]) pairY(boltSep+4)
          rotate([0,90,0])
            intersection() {
              rotate([0,0,22.5])
                 cylinder(r=base_thickness/2+1,h=32,$fn=8);
              cube([base_thickness,base_thickness,80],center=true);
            }
        translate([-7,0,base_thickness]) cube([1,14,.1],center=true);
      }

      // extra bracing from belt catch to mobile mount rails
      mirrorY(-15) cableCatchBrace();

      endstopPad();  // flat area for endstops to touch
    }

    // Adjustable tension screw holes
    translate([-1,0,base_thickness/2]) rotate([0,90,0]) {
      translate([0,0,-24]) pairY(boltSep) {
          cylinder(r=m3rad,h=60,$fn=13);
          cylinder(r1=m3nutRad+.4, r2=m3nutRad-.2, h=7, $fn=6);
      }
    }
  }
}

// make a nice flat area for endstops to sense
module endstopPad() translate([0,0,8]) mirrorY(24) rotate([-90,0,0]) hull() {
   translate([0,0.5,6]) pairX(8) cylinder(r=2.5,h=1,$fn=RES);
   translate([0,2,0]) pairX(8) cylinder(r=6,h=.1,$fn=RES);
}

module wheelBaseHoles() {
  for (a=[-wheel_offset,wheel_offset])
    translate([-wheel_dx,a,base_thickness+1]) wheelAxleHole5(0);
  translate([wheel_dx-1.5,0,0  ]) mobileWheelMount(.15); // dilated version for main slot
  // raise supported ceiling a bit, since it is hard to clen supports
  translate([wheel_dx+2.3,0,base_thickness-.7])
     cube([22,2*(boltSep+2),2],center=true);
}

use <support.scad>;

module mobileMountSupportBlade() {
  intersection () {
    rotate([60,0,0]) cube([.4,3,6],center=true);
    translate([-1,-2,0]) cube([1,6,3]);
  }
}
module mobileMountSupport() {
  for(a=[-3.9:4:10])
    translate([a,-boltSep-4.3,0]) mobileMountSupportBlade();
}


// OpenBuilds low-profile wheel for v-slot
module vWheelLow() rotate_extrude($fn=RES*2) polygon([
    [2.5,4.5],[6.5,4.5],[7.6,3.2],  [7.6,-3.2],[6.5,-4.5],[2.5,-4.5]]);

// Larger wheel, I think OpenBuilds sells these.
module vWheel() rotate_extrude($fn=RES*2) polygon([
    [2.5,5],[10.1,5],[11.9,3.25],   [11.9,-3.25],[10.1,-5],[2.5,-5]]);

// support structures
*color("Cyan") {
  translate([ 22.3,0,base_thickness+.2])                 scale([0.5,0.6,0.7]) earBrace();
  translate([-22.3,0,base_thickness+.2]) mirror([1,0,0]) scale([0.5,0.6,0.7]) earBrace();

  // under horn.  Slightly different heights for mobile clearance
  translate([19.5,0,0]) rotate([0,0,90]) supportPillar(0,0,base_thickness+.2,r=1,xscale=5);


  for (i=[-1,1]) {
    supportPillar(24*i,0,12.2,r=1.5);  // under horn earBrace()'s

    // horn overhang
    supportPillar(13.5 ,11.4*i,base_thickness+.2,r=1,xscale=6,rot=15*i);
    supportPillar4(10.5  , 10.5  *i,5,4,base_thickness+.2);
  }
  supportPillar4(12.6,0,9,15,base_thickness+.2);
  supportPillar4(12.6,0,5,11,base_thickness+.2);
  supportPillar4(12.6,0,2, 7,base_thickness+.2);
  supportPillar(-9.5,0,9,r=1.4,xscale=5,rot=90);
  supportPillar(-5  ,0,8,r=1.3,xscale=5,rot=90);
}

//use <endstop20v.scad>;
// This carriage sits 1.8mm above extrusion
//%translate([0,-40,6-1.8]) rotate([0,180,0]) microswitchEndstop20v(0);

// $Log: frogCarriage20v.scad,v $
// Revision 1.1  2026/03/15 21:05:29  aaron
// Initial revision
//
// forked from Mr-Boim kossel design 260311
