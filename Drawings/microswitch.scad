// Don't print this file, purchase real micro switches
// e.g. Honeywell ZM10B10A01 or OMRON SS-5 or similar.

dHole = 9.5;  // scres holes on center
switchOff = 2.5;     // center of block to center of switch
hTot = 10.5;  // including bumps
hMain = 9.3;  // main body of switch
wBase = 19.8;  // perhaps design 20, measured this

microswitch();
%translate([0,0,-1.5]) cube(1.5);

%translate([-2.5,0,7.5]) rotate([180,0,0])
microswitch1();

//translate([0,-20,-1]) {
//   rotate([-90,0,0]) %microswitch();
//   //projection(cut=true)
//     microswitchGuide();
//}

module pairX(d) for (a=[-d,d]) translate([a,0]) children();

module microswitchHoles(fuzz=0) pairX(dHole/2) rotate([90, 0, 0])
      cylinder(d=2.5+fuzz, h=20, center=true, $fn=24);

module microswitch() difference() {
    union() {
        translate([2.5,0,1]) cube([9.8,6,2],center=true);
        translate([-switchOff,0,0]) {
            translate([0,0,hTot-1]) pairX(dHole/2) cube([3.5,6,2],center=true);
            translate([0,0,hTot/2]) cube([wBase,6,hMain],center=true);
            for (x = [-8.2, -1, 8.2]) translate([x, -.25, hTot+2-.3])
                cube([0.5, 3.2, 4], center=true);
        }
        translate([0, 0, .5]) cube([2, 3.3, 4], center=true); // button
    }
    
    translate([-switchOff,0,7.5]) microswitchHoles();
}
module microswitch1() {
  difference() {
    union() {
      translate([0, 0, 2.5])
        cube([19.8, 6, 10], center=true);
      translate([2.5, 0.5, 6])
        cube([2, 3.5, 5], center=true);
      for (x = [-8, -1, 8]) {
        translate([x, 0, 0])
          cube([0.6, 3.2, 13], center=true);
      }
    }
    microswitchHoles();
  }
}

module microswitchGuide() {
  intersection() {
    difference() {
      hull() {
        translate([-6,0,0]) cylinder(r=4,h=2,$fn=24);
        translate([ 6,0,0]) cylinder(r=4,h=2,$fn=24);
        translate([ 2.4,8,0]) scale([2,1,1]) cylinder(r=3,h=2,$fn=36);
      }
      translate([0,0,-1]) rotate([-90,0,0]) microswitchHoles();
    }
    translate([2.4,8,-1]) microswitchGuideSlot();
  }
}

// little slot to help glide probe handle on top of switch
module microswitchGuideSlot() {
  difference() {
    union() {
      translate([-4.6,0.5,0]) cylinder(h=4,r=4,$fn=36);
      translate([ 4.6,0.5,0]) cylinder(h=4,r=4,$fn=36);
      hull() {
        translate([-15,-13,0]) cube([25,1,4]);
        translate([-11, -1,0]) cube([18,1,4]);
      }
    }
    cylinder(h=15,r=.6,$fn=18,center=true);
  }
}
