use <ext20.scad>;

// openbeam sells 1515 extrusions in 270length (and others).
// I think I got misumi at 300, but they are selectable.

// the simple drawing, ext15.scad has no fuzz, so I'll
// use the OpenBeam model, ext15ob.scad until I add that.
//use <ext15ob.scad>;
use <ext15m.scad>;  // Misumi 1515 extrusion profile

extFuzz=0.1;  // extra padding to put around extrusion cut-outs

baseExtLen = 370;
railTilt = 13;//9.5;//10.34;//10.8;  // degrees
towerExtLen = 1000;

use <nema17.scad>;

baseRailHeight = 60;

//translate([0,-0.5*baseExtLen]) //{// center lower vertex
//translate([0,0,-960]) // center apex
difference() {
  union() {
    translate([0,0.47*baseExtLen,baseRailHeight]) baseVertex();
    translate([0,0,towerExtLen*cos(railTilt)-21]) apex();
    translate([0,0.68*baseExtLen,-5]) foot();
  }

  dilatedExtrusions(3);  // for cut-outs for extrusions
}

// extra supports for printing vertex (not needed with newer cura)
//translate([0,0.47*baseExtLen,baseRailHeight]) color([.2,.3,.8,.4]) vertexSupports();}

// show height above table
towerEdgeBelow0 = sin(railTilt)*10;  // tip of tower goes below z=0
railTopToTableTop = baseRailHeight+towerEdgeBelow0+7.5;
echo("Top of base rail to table top (no foot) ",railTopToTableTop);
//%translate([-100,-80,-towerEdgeBelow0]) cube([200,10,railTopToTableTop]);



// disgnostic.  From lowest tip of tower, to where
// inside edge of tower meets top plane of vertex
vertexTop2tableTop=60/cos(railTilt)+towerEdgeBelow0+7.5/cos(railTilt);
echo("VertexTop to lowest tower edge ",vertexTop2tableTop);

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

        // diagnostic to show distance from vertex top
        // to lower edge of tower leg
        *%translate([0,-10/cos(railTilt),vertexTop2tableTop/2])
            cube([80,30,vertexTop2tableTop],center=true);

        // want NEMA face plate 36ish mm from extrusion.
        // make sure this is carved out
        hull() {
          for(x=[-1,1]) translate([25*x,-7.5-36-4,baseRailHeight])
             cylinder(r=4,h=80,$fn=24,center=true);
          translate([0,-7.5-36-36,baseRailHeight])
              cube([97,.1,80],center=true);
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
          #ext15(baseExtLen+.6,extFuzz);
        else
          ext15(baseExtLen+.6,extFuzz);

        // cut out ext hallow .3mm too long, but put a little
        // spacer at the desired position
        cube([12,12,.6],center=true);
        cylinder(r1=1.1,r2=0.8,h=2,$fn=16);
        translate([0,0,baseExtLen+.3]) cube([12,12,.6],center=true);
        translate([0,0,baseExtLen-1]) cylinder(r1=0.8,r2=1.1,h=2,$fn=16);
      }
}



module foot() {
  hull() for(x=[-1,1]) for(y=[-1,1]) {
     translate([12*x,12*y,2]) sphere(2,$fn=24);
     translate([9*x,9*y-1,9]) sphere(4,$fn=24);
  }
}

//------------------------------------------------------------- apex

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
    //#translate([0,0,-5]) linear_extrude(30,scale=1.3) 
    //   roundedTri(15,5);
    hull() {
      translate([0,0,-5]) linear_extrude(1) rotate(60) roundedTriHex(16,3,4);
      translate([0,0,20]) linear_extrude(1) roundedTri(18,1);
    }
    translate([0,0,-3]) linear_extrude(4,scale=0.8) 
       roundedTriHex(14,16,3);
    translate([0,0,15]) linear_extrude(4,scale=1.5) 
       roundedTri(15,2);
    //#for(a=[0:120:355]) rotate(a) for(x=[-1,1])
    //  translate([x*17,22,-5])
    //    cylinder(r1=3,r2=2,h=30,$fn=6);

    //rotate([0,0,0*120]) translate([0,-100,-10]) cube([100,200,40]);
  }
}

//----------------------------------------------------------vertex


// add some manual supports to baseVertex() for printing
module vertexSupports() {
dr=0; // moves ridge support rail towards/away from tower

  for (a=[-1,1]) translate([a*(dr*sin(30)+35.7),-cos(30)*dr+18,2.3])
     rotate([0,0,30*a])
       cube([2,74,.5],center=true);

  translate([0,28,-14]) rotate([90,0,0]) difference() {
     cylinder(r=11.5,h=5,$fn=36,center=true);

     cylinder(r=11,h=6,$fn=36,center=true);
     translate([0,1.5,0]) cube([24,22,8],center=true);
  }
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
       cube([16.6,25.6,50],center=true);

  railZone();
  mirror([1,0,0]) railZone();

  for (a=[-1,1]) {
    translate([45.1*a,-9,0]) rotate([0,0,-90-a*60])
      rotate([0,90,0]) M3railHole(8);
    translate([17*a,40,0]) rotate([0,0,-90-a*60])
      rotate([0,90,0]) M3railHole(8);
  }

  // inside 20 t-slot screw
  //translate([0,56,-5])
  //translate([0,57.4,-9])
  //translate([0,57.7,-14])
  translate([0,58.8,-18])
    rotate([90+railTilt,0,0]) M5rail20hole(3.5,.15);

  for (a=[-1,1]) translate([9.8*a,64.9,0])
     rotate([0,90*a,0]) rotate([0,0,a*railTilt]) M3rail20hole(5,.15);

  // nut insertion holes
  translate([21.1+sin(30)*3,56-cos(30)*3,7.5-2]) rotate([0,0,30]) 
      cube([6.5,12,4],center=true);
  translate([-27,56,0]) 
     rotate([0,0,-30]) cube([4,12,6.5],center=true);

  // extra holes for tie-downs
  //%translate([0,38,-19]) rotate([0,90,0])
  //  cylinder(r=4,$fn=6,h=88,center=true);
  *for (a=[-1,1]) translate([25*a,40,-14]) rotate([0,90,30*a])
     intersection() { 
       cylinder(r=6.5,h=22,$fn=12,center=true);
       bevilThroughHole(4,14);
    }
  for (a=[-1,1]) translate([24*a,43,-21]) rotate([0,90,30*a])
     intersection() { 
       cylinder(r=6.5,h=22,$fn=12,center=true);
       bevilThroughHole(4,14);
    }
  //%translate([0,17,-14]) rotate([0,90,0])
  //  cylinder(r=3,$fn=6,h=88,center=true);
  *for (a=[-1,1]) translate([36*a,15,-14]) rotate([0,90,30*a])
    scale([1,1,2])bevilThroughHole(3,5.3);
  for (a=[-1,1]) translate([35.5*a,18,-20]) rotate([0,90,30*a])
    scale([1,1,2])bevilThroughHole(3,4.5);

  //translate([-100,-100,-50]) cube([100,200,100]);
}

// get rid of extranious junk around rails on vertex
module railZone() {
  translate([-49.5,9,0]) rotate([0,0,-30]) {
    cube([12,100,16],center=true);
    hull() {
      translate([-12,35,-25]) cylinder(r=8,h=1,$fn=22);
      translate([0,1.7,-7.55]) cube([9+8,100,.1],center=true);
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
        translate([12*x,71.8,zHi]) sphere(r=cr,$fn=24);
        translate([12*x,77.1,zLo-12]) sphere(r=cr,$fn=24);

        for(z=[zLo,zHi]) translate([27*x,56,z]) sphere(r=cr,$fn=24);
        for(z=[zLo,zHi]) translate([52*x,-12,z]) sphere(r=cr,$fn=24);

        // extra bump to keep central rail ridge
        translate([52*x,-12,0]) sphere(r=cr,$fn=24);

        // bottom level for step motor mount
        translate([26*x,29,-34]) sphere(r=cr,$fn=24);
      }
    }
  }
}

//----------------------------------------------------------util

module bevilHole(nf=48) rotate_extrude($fn=nf) bevilProfile();
module bevilThroughHole(r=3,h=10) union() {
  mirror([0,0,1])
    translate([0,0,-h/2]) scale(r,r,h) bevilHole();
    translate([0,0,-h/2]) scale(r,r,h) bevilHole();
  cylinder(r=r,$fn=48,center=true,h=h+1);
}

module roundedTriHex(dy,dx,rc) hull() 
  for(a=[0:120:355]) rotate(a)
    for(x=[-1,1]) translate([x*dx,dy]) circle(rc,$fn=36);

module roundedTri(dx,rc) hull() 
  for(a=[30:120:355]) rotate(a)
    translate([dx,0]) circle(rc,$fn=36);

//%scale(1.02) nema17();
//nema17MountHoles();

// hole for setting up an 8mm M3 screw to attach to a 1515 extrusion
module M3railHole() {
nutRad = 5.46/2/cos(30);
  M3screwHole(8);
  translate([0,0,-8.8]) rotate([0,0,30])
    cylinder(r1=nutRad+.2,r2=nutRad,h=4,$fn=6);
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

module bevilProfile() polygon( points = [
[2,-0.05],
 [1.826352  , 0.015192],
  [ 1.741181 ,  0.034074],
  [ 1.657980 ,  0.060307],
  [ 1.577382 ,  0.093692],
  [ 1.500000 ,  0.133975],
  [ 1.426424 ,  0.180848],
  [ 1.357212 ,  0.233956],
  [ 1.292893 ,  0.292893],
  [ 1.233956 ,  0.357212],
  [ 1.180848 ,  0.426424],
  [ 1.133975 ,  0.500000],
  [ 1.093692 ,  0.577382],
  [ 1.060307 ,  0.657980],
  [ 1.034074 ,  0.741181],
  [ 1.015192 ,  0.826352],
[0.96,1.1],[.5,1.1],[.5,-0.05],[0.96,-0.05]]);
