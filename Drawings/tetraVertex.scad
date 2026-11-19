
RES=24;

include<tetraV20cfg.scad>
use<tetraV20.scad>

vertex();

use<nema17.scad>
module atNema17() translate([0,-50.7,BaseRailHeight-10])
    rotate([RailTilt-90,0,0]) children();

//----------------------------------------------------------vertex

//draw frog carriage, so we can mount motor to put belts as close to rail as possible
showCarriage();

use<frogCarriage60_20v.scad>
module showCarriage() translate([0,-60,280]) rotate([90+RailTilt,0,0]) {
    %frogCarriage();
    %overlays();  // Show wheels, belts, etc.
}

// clearnce to mount stepper, in nema17 coords
module stepperClearance() { // clearnce to mount stepper, in nema17 coords
    // main open area at back
    hull() {
        pairX(26) translate([0,0,-4-4])
            rotate([90,0,0])
                cylinder(r=8,h=100,center=true,$fn=RES);
        translate([0,0,-90]) cube([180,100,1],center=true);
    }
    
        // open area after stepper mount plate
    hull() {
        translate([0,0,27-4]) rotate([90,0,0])
            pairX(12) cylinder(r=4,h=100,center=true,$fn=RES);
        pairX(20) translate([0,0,3.9+4]) rotate([90,0,0])
            cylinder(r=4, h=80,center=true, $fn=RES);
    }
}

module vertex() difference() { 
    translate([0,-76,BaseRailHeight]) baseVertexShell();
    
    #translate([0,-TowerRadius,0]) tetraExtrusions(.1);
    //import("tetraRails1500.stl");
 
    *atNema17(){
        
        // main open area at back
        *hull() {
            pairX(20) translate([0,-80,BaseRailHeight])
                #rotate([RailTilt,0,0]) translate([0,0,-20])
                   cylinder(r=8,h=100,center=true,$fn=RES/2);
            #translate([0,-140,50]) cube([120,1,90],center=true);
        }
    
        // open area after stepper mount plate
        hull() {
        translate([0,-32.4+3*0,BaseRailHeight])
            rotate([RailTilt,0,0]) translate([0,0,-20])
               cylinder(r=8,h=100,center=true,$fn=RES/2);
        pairX(18-4) translate([0,-56.9+4,50]) rotate([RailTilt,0,0])
               cylinder(r=8, h=80,center=true, $fn=RES);
        
        }
    }
    
    
    atNema17() {
        %nema17();

        #nema17holes();
        //nema17MountHoles();
        %translate([0,0,23.4]) rotate([180,0,0]) toothedPulley();
        %translate([0,0,3.5]) cube([20,10,7],center=true);  // show typical spacing of pulley from mount face
        
        stepperClearance();  // clearnce to mount stepper
        
        #translate([0,-9,40]) boltM5(20,.05);
    }
}

module boltM5(len,kerf=.05) {
    translate([0,0,-19.9]) cylinder(d1=M5head+1+kerf,d2=M5head+kerf, h=20, $fn=RES);
    cylinder(d=M5diam+kerf*2,h=len,$fn=RES/2);
}


module baseVertexShell() {
cr=4;  // corner radius
zHi=10-cr;
zLo=-10+cr;
    hull() {
      for(x=[-1,1]) {
        translate([11*x,70,zHi]) sphere(r=cr,$fn=RES);
        translate([11*x,75.5,zLo-20]) sphere(r=cr,$fn=RES);

        translate([36.5*x,65,zHi   ]) sphere(r=cr,$fn=RES);
        translate([36.5*x, 65,zLo-10]) sphere(r=cr,$fn=RES);
        translate([87.5*x,-25,zLo- 6]) sphere(r=cr,$fn=RES);
        translate([82  *x,-35,zLo- 6]) sphere(r=cr,$fn=RES);
        translate([87.5*x,-25,  0   ]) sphere(r=cr,$fn=RES);

        // extra bump to keep central rail ridge
        %translate([84*x,-30,0]) sphere(r=10,$fn=RES*1.5);
        translate([74*x,-36,zHi]) sphere(r=cr,$fn=RES/2);
          
        // bottom level for step motor mount
        translate([28*x,34,-38]) sphere(r=6,$fn=RES*1.5);
      }
    } // end hull
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

  *for (a=[-1,1]) {
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

module nema17MountHoles() {
  // make central more superset of shaft
  cylinder(r=11+1, h=2*9+35, $fn=48,center=true);
  //#cylinder(r=2.5+.2, h=25, $fn=36);  // shaft

  for (a = [0:90:359]) {
    rotate([0, 0, a]) translate([15.5, 15.5, 0])
      cylinder(r=2.94/2+.1, h=20, $fn=11,center=true);
  }
}





/*


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






module foot() {
  hull() for(x=[-1,1]) for(y=[-1,1]) {
     translate([12*x,12*y,2]) sphere(2,$fn=RES);
     translate([9*x,9*y-1,9]) sphere(4,$fn=RES);
  }
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


//----------------------------------------------------------util

module bevilHole(nf=48) rotate_extrude($fn=nf) bevilProfile();
module bevilThroughHole(r=3,h=10) union() {
*  mirror([0,0,1])
    translate([0,0,-h/2]) scale(r,r,h) bevilHole();
*    translate([0,0,-h/2]) scale(r,r,h) bevilHole();
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
*/

module toothedPulley() difference() { cylinder(r=8,h=15.9,$fn=48);
    for (a=[0:360/20:355]) rotate([0,0,a])
        translate([0,6.5,6.8+.1]) linear_extrude(6.7+.1)
        polygon([[-3,0],[-.4,0],[0,-.7],[.4,0],[3,0],[4,2],[-4,2]]);
    
    // 20 indentations for teeth
}

