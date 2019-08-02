use <ext20.scad>;

// openbeam sells 1515 extrusions in 270length (and others).
// I think I got misumi at 300, but they are selectable.

// the simple drawing, ext15.scad has no fuzz, so I'll
// use the OpenBeam model, ext15ob.scad until I add that.
//use <ext15ob.scad>;
use <ext15m.scad>;  // Mistumi 1515 extrusion profile

extFuzz=0.1;  // extra padding to put around extrusion cut-outs

baseExtLen = 370;
railTilt = 13;//9.5;//10.34;//10.8;  // degrees
towerExtLen = 1000;

use <nema17.scad>;

baseRailHeight = 60;

//translate([0,-0.5*baseExtLen]) {// center lower vertex
//translate([0,0,-960]) // center apex
difference() {
  union() {
    translate([0,0.47*baseExtLen,baseRailHeight]) baseVertex();
    translate([0,0,towerExtLen*cos(railTilt)-21]) apex();
    translate([0,0.68*baseExtLen,-5]) foot();
  }

  dilatedExtrusions(3);  // for cut-outs for extrusions
}

// extra supports for printing vertex
//translate([0,0.47*baseExtLen,baseRailHeight]) vertexSupports();}

//baseVertexShell();
//translate([50,0]) M3railHole();  // for 15mm extrusion, uses regular nut
//translate([30,0]) M3screwHole();
//translate([0,20]) M5boltHole(0.1,3);
//translate([0,20,20]) rotate([180,0,0]) %Tnut20();
//translate([0,-20]) M3rail20hole();  // using slider t-nut on 20mm extrusion
//M5rail20hole();  // using slider t-nut on 20mm extrusion

module dilatedExtrusions(verbose=3) {
  for (a=[-120,0,120]) rotate([0,0,a]) 
    translate([0,0.683*baseExtLen,0])
      rotate([railTilt,0,0]) {

        // make a little indent at foot of model to make feet fit better
        difference() {
          if (verbose % 2)
            #ext20(1000,extFuzz);
          else
            ext20(1000,extFuzz);
          cube([14,14,1],center=true);
        }

        // want NEMA face plate 36ish mm from extrusion.
        // make sure this is carved out
        hull() {
          for(x=[-1,1]) translate([25*x,-7.5-36-4,baseRailHeight])
             cylinder(r=4,h=80,$fn=24,center=true);
          translate([0,-7.5-36-30,baseRailHeight])
              cube([90,1,80],center=true);
        }

        // clear zone for linear motion parts around shaft
        hull() for(x=[-1,1]) {
          translate([10*x,-19,baseRailHeight/2-20]) cylinder(r=3,h=100,$fn=24);
          translate([20*x,-36,baseRailHeight/2-20]) cylinder(r=3,h=100,$fn=24);
        }
      }

  for (a=[-90,30,150]) rotate([0,0,a])
    translate([.36*baseExtLen,(baseExtLen+1)/2,baseRailHeight])
      rotate([90,0,0]) difference() {
        if (floor(verbose/2) % 2)
          #ext15(baseExtLen+1,extFuzz);
        else
          ext15(baseExtLen+1,extFuzz);

        // cut out ext hallow .5mm too long, but put a little
        // spacer at the desired position
        cube([12,12,1],center=true);
        cylinder(r1=1.1,r2=0.8,h=2,$fn=16);
        translate([0,0,baseExtLen+1]) cube([12,12,1],center=true);
        translate([0,0,baseExtLen-1]) cylinder(r1=0.8,r2=1.1,h=2,$fn=16);
      }
}



module foot() {
  hull() for(x=[-1,1]) for(y=[-1,1]) {
     translate([12*x,12*y,2]) sphere(2,$fn=24);
     translate([9*x,9*y-1,9]) sphere(4,$fn=24);
  }
}

module apex() {
  difference() {
    hull() for (a=[-120,0,120]) rotate([0,0,a]) for(x=[-1,1]) { 
       translate([12*x,40.7, 0]) sphere(2,$fn=36);
       translate([12*x,37,16]) sphere(2,$fn=36);
    }


    // remove outside slot residual, and (most of) side rails
    for (a=[-120,0,120]) rotate([0,0,a]) 
      translate([0,35.2, 0]) 
        rotate([railTilt,0,0])
          cube([16.8,22,50],center=true);

    // side bolt holes
    for (a=[-120,0,120]) rotate([0,0,a]) for(x=[-1,1])
      translate([9.8*x,30.73,8.2]) 
        rotate([0,90*x,0]) rotate([0,0,x*railTilt])
          M3rail20hole(4,.15);

    // inside bolt holes
    for (a=[-120,0,120]) rotate([0,0,a]) {
      translate([0,20.3,8.4]) 
        rotate([90+railTilt,0,0]) M5rail20hole(6,.13);

      //driver pass-through grooves
      translate([0,-30,-6]) rotate([114,0,0])
           cylinder(r1=3.5,r2=7,h=30,center=true,$fn=24);
    }

    // center cut-out
    //%translate([0,0,-4]) cylinder(r1=28,r2=24,h=24,$fn=6);
    translate([0,0,-5]) linear_extrude(30,scale=0.67) 
       roundedTri(20,5);
    translate([0,0,-4]) linear_extrude(4,scale=0.7) 
       roundedTri(32,3);
    translate([0,0,15]) linear_extrude(4,scale=1.5) 
       roundedTri(12,3);
    //#for(a=[0:120:355]) rotate(a) for(x=[-1,1])
    //  translate([x*17,22,-5])
    //    cylinder(r1=3,r2=2,h=30,$fn=6);

    //rotate([0,0,0*120]) translate([0,-100,-10]) cube([100,200,40]);
  }
}

module roundedTriHex(dy,dx,rc) hull() 
  //for(a=[0:120:355]) rotate(a)
    for(x=[-1,1]) translate([x*dx,dy]) circle(rc,$fn=36);

module roundedTri(dx,rc) hull() 
  for(a=[30:120:355]) rotate(a)
    translate([dx,0]) circle(rc,$fn=36);

//%scale(1.02) nema17();
//nema17MountHoles();

// add some manual supports to baseVertex() for printing
module vertexSupports() color([.2,.3,.8,.4]) {

  //color([1,0,0]) {
    for (a=[-1,1]) translate([a*31.2,25.8,2.4]) rotate([0,0,30*a])
      //hull() {
        cube([2,55,.5],center=true);
      //  translate([0,0,5.25]) cube([.6,45,.1],center=true);
      //}
    translate([0,28,-14])
      rotate([90,0,0]) difference() {
        cylinder(r=11,h=5,$fn=36,center=true);
        cylinder(r=10.5,h=6,$fn=36,center=true);
        translate([0,3,0]) cube([24,20,6],center=true);
      }
  //}
}

// shave off some odities from main vertex and drill holes
module baseVertex() difference() {
  baseVertexShell();

  translate([0,23,-15]) rotate([railTilt-90,0,0]) {
    %scale(1.02) nema17();
    nema17MountHoles();
  }

  // remove outside of vertical rail strip
  translate([0,70,0]) rotate([railTilt,0,0]) 
       cube([16,25,50],center=true);

  railZone();
  mirror([1,0,0]) railZone();

  for (a=[-1,1]) {
    translate([39*a,2,0]) rotate([0,0,-90-a*60])
      rotate([0,90,0]) M3railHole(8);
    translate([17*a,40,0]) rotate([0,0,-90-a*60])
      rotate([0,90,0]) M3railHole(8);
  }

  // inside 20v mount screw
  translate([0,56,-5])
    rotate([90+railTilt,0,0]) M5rail20hole(4,.15);

  for (a=[-1,1]) translate([9.8*a,64.9,0])
     rotate([0,90*a,0]) rotate([0,0,a*railTilt]) M3rail20hole(5,.15);

  // extra holes for tie-downs
  translate([0,38,-19]) rotate([0,90,0])
    cylinder(r=4,$fn=6,h=88,center=true);
  translate([0,17,-14]) rotate([0,90,0])
    cylinder(r=3,$fn=6,h=88,center=true);

  //translate([-100,-100,-50]) cube([100,200,100]);
}

// hole for setting up an 8mm M3 screw to attach to a 1515 extrusion
module M3railHole() {
nutRad = 5.46/2/cos(30);
  M3screwHole(8);
  translate([0,0,-8.8]) rotate([0,0,30])
    cylinder(r1=nutRad+.2,r2=nutRad,h=4,$fn=6);
}

// get rid of extranious junk around rails on vertex
module railZone() {
  translate([-49.5,9,0]) rotate([0,0,-30]) {
    cube([12,100,16],center=true);
    hull() {
      translate([-10,20,-30]) sphere(8,$fn=22);
      translate([4,0,-5]) cube([9,100,5],center=true);
    }
  }
}

module baseVertexShell() {
cr=2;  // corner radius
zHi=7.5-cr;
zLo=-7.5+cr;//-4;
  union() {

    hull() {
      for(x=[-1,1]) {
        translate([11*x,71.8,zHi]) sphere(r=cr,$fn=24);
        translate([11*x,74.4,zLo]) sphere(r=cr,$fn=24);

        for(z=[zLo,zHi]) translate([27*x,56,z]) sphere(r=cr,$fn=24);
        for(z=[zLo,zHi]) translate([44*x,-2,z]) sphere(r=cr,$fn=24);
      }
    }

    hull() for(x=[-1,1]) {
      // repeat lower nodes on outside of vertex tip
      translate([11*x,74.4,zLo]) sphere(r=cr,$fn=24);
      translate([26*x,29,-34]) sphere(r=cr,$fn=24);
      translate([44*x, 0,-4 ]) sphere(r=cr,$fn=24);
    }
  }
}

module M3screwHole(holeDepth=10,sinkHeight=4,fuzz=0.05) {
  translate([0,0,-holeDepth]) cylinder(r=2.96/2+fuzz,h=holeDepth+1,$fn=16);
  cylinder(r1=5.38/2+fuzz,r2=5.38/2+sinkHeight*fuzz/2,h=sinkHeight,$fn=20);
}

module nema17MountHoles() {
  // make central more superset of shaft
  cylinder(r=11+1, h=2*9+35, $fn=48,center=true);
  //#cylinder(r=2.5+.2, h=25, $fn=36);  // shaft

  for (a = [0:90:359]) {
    rotate([0, 0, a]) translate([15.5, 15.5, 0])
      cylinder(r=2.94/2+.1, h=20, $fn=11,center=true);
  }
}




m5rad = 4.92/2;//4.88/2;
m5_head_radius = 8.62/2;//8.5/2;  // 5mm head height, uses 4mm hex drive

module M5boltHole(fuzz=0.1,gap=3) {
    cylinder(r=m5rad+fuzz,h=20,$fn=15);
    translate([0,0,-25])
       cylinder(r2=m5_head_radius,r1=m5_head_radius+1,h=25,$fn=24);

    // extra clearance for extrusion nut
    %translate([0,0,8.8]) cube([10,16,4],center=true);
    %translate([0,0,6  ]) cylinder(r=3.5+.2,h=4,$fn=17);

    // clear out area for 20mm extrusion nut
    #translate([0,0,3+gap]) cube([11,11,6],center=true);

}

// using slider t-nut on 20mm extrusion
// gap from bottom of sockethead to surface of extrusion
module M3rail20hole(gap=3,fuzz=0.1) {
  // slot is 6mm deep.  4mm below 2mm thick extrusion wall
  translate([0,0, -4]) cylinder(r=2.96/2+fuzz,h=5+gap,$fn=24);
  translate([0,0,gap]) cylinder(r1=5.38/2+fuzz,r2=3.2,h=20,$fn=24);

  // leave 0.5mm space to surf of extrusion.  Slider T nuts look like
  // about 1.5mm above bottom of slot wall.  Less??
  // slider is 10mm long.  6mm wide at slot, but wider farther down.
  // just call width also about 10mm.  leave some slop... 1mm...
  translate([0,0,-3.5+.2]) cube([11,11,6],center=true);
}

// using slider t-nut on 20mm extrusion
// gap from bottom of sockethead to surface of extrusion
module M5rail20hole(gap=3,fuzz=0.1) {
  // slot is 6mm deep from surf to bottom of slot.
  // surface wall is 2mm thick
  translate([0,0, -4]) cylinder(r=m5rad+fuzz,h=5+gap,$fn=24);

  // make cap countersink VERY long, so allow wrench access
  translate([0,0,gap]) cylinder(r1=m5_head_radius+fuzz,
         r2=m5_head_radius+1,h=25,$fn=24);

  // sliding t-nut is 4.5mm thick, total.
  // looks like about 1.5mm into slot... 0.5mm from surface
  // leave .3mm space to surf of extrusion.
  // slider t-nuts seem to go up to about 0.5mm from surface
  // slider is 10mm long.  6mm wide at slot, but wider farther down.
  // just call width also about 10mm.  leave some slop... 1mm...
  translate([0,0,-3.3]) cube([11,11,6],center=true);
}

// sliding t-nut for typical 20mm extrusion slots
module Tnut20() union() {
  translate([0,0,-2]) cube([6,10,4],center=true);
  hull() {
    translate([0,0,-4.5+.5]) cube([ 6,10,1],center=true);
    translate([0,0,-2-.5])   cube([10,10,1],center=true);
  }
}
