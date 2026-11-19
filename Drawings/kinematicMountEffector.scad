// test/prototype for a kinematic mount, to be used to
// carry a hot-end/nozzle probe combo
RES=30;   // make larger for production  render

dBall = 8;//12;  // I have some 12mm balls, although I'd prefer 8mm
dMag = 6; //10;  // Actually like 9.8 to 9.9, but I have them .2ish fuzz factor
tMag = 3; //2.6;  // would prefer 3mm thick, but this is what I have
zMag = 11.5+1.5;  // offset for magnet assembly

rBase = 26+2;  // might need a bit more for M4
wHorns = 40+20;  // must match the width between arm-mount horns on carriage

// angle on mount.  usually 45, but it can differ
// >45 for more vertical holding, at the expense of less XY stability.
// <45 for more XY Hornstability at the expense of less Z holding force
aMag = 45;

//rotate(-60)
hotEndFrame();

%rotate(60)
effector(0,0); //withAirDuct=1,withSwitchMount=1

//%rotate(-30) translate([17,0,24]) rotate([0,90,0]) fan3010();
//%translate([0,0,-20]) import("kinematicMountSimple.stl");

//rotate([-90,0,0])
*%translate([-1.75,-10,-12])
switchMount();

use <partFanMounts.scad>;
use <blower4020.scad>;
//difference() {  
*%translate([0,-rBase,7.8])
fanDuct4020();
//translate([0,-100,0]) cube(100);}

//effectorBody();
//translate([0,0,35+$t*15]) cube([90,90,h80],center=true);
//translate([0,-125,-10]) cube(100);
//translate([0,-80,-10]) rotate(-210) cube(50);
//}

//PosSwitchRx  = [-1.75,-15.4,-5];
PosSwitchRx  = [-1.75,-10,-12];

use <util.scad>;
use <hotEnd.scad>;
%translate([0,0,10-5]) rotate(180) hotEnd();

// estimating nozzle offset :
//translate([0.1,-10,-12.5]) cube(.1,center=true);
//translate([0,0,-10.8]) cube(.1,center=true);

//%translate(PosSwitchRx) switchMount();
//%translate([0,0,12]) onMount() ball();

//%rotate(60) ballMounts1();
module ballMounts(nf=RES) for(a=[90:120:355]) rotate(a) {
            translate([rBase, 0, zMag]){
                hull() { ballMountJoint(nf);
                    cylinder(d=dBall+1.5,h=.1,$fn=nf); }
                hull() { ballMountJoint(nf);
                    translate([-11,0,16]) rotate([0,90,0])
                        scale([28,8,1]) cylinder(d=1,h=.1,$fn=nf/2); } 
            }
        }
module ballMountJoint(nf) translate([-.5,0,2]) difference() {
    sphere(d=dBall+2,$fn=nf);
    translate([0,0,-4]) cube([10,10,5],center=true);
}

module ballMounts1(nf=RES) for(a=[90:120:355]) rotate(a) {
            translate([rBase, 0, zMag])
                rotate([0,-30,0]) {
                    cylinder(d1=dBall,d2=dBall-2,h=20,$fn=nf);
                }
        }
module kinMountBalls(fuzz=.2,nf=RES) translate([0,0,zMag])
       onMount() sphere(d=dBall+fuzz,$fn=nf);

TubeHeight = 39+5;  //40
module hotEndFrame() difference() {
    union() {
        if (RES < 40)
           translate([0,0,53.65-5]) rotate(-60) hotEndMount(false,false);
        else
           translate([0,0,10.25-5]) rotate(-60) import("hotEndMount.stl");
        
        ballMounts();
        
        
        translate([0,0,9-10]) {  // hot end cooling shroud
            cylinder(r=19,h=TubeHeight,$fn=RES*1.5);
            for(a=[90:120:355]) rotate(a) {
                for (k=[-1,1]) translate([0,0,9+7])
                    linear_extrude(TubeHeight-9-7,twist=k*120,$fn=RES)
                        translate([18,0]) //scale([3,3])
                            circle(3,$fn=RES/2);
                translate([18,0,9+10]) {
                    scale([4,2]) cylinder(r=1,h=TubeHeight-9-10,$fn=RES/2);
                    hull() {
                        translate([rBase-18,0,zMag-9-9])
                            ballMountJoint(RES/2);
                        translate([-2,0,-1]) pairY(3.4)
                            sphere(2,$fn=RES/2);
                    }
                }
            }
            rotate(90) translate([0,0,42])
                rotate_extrude(angle=240,$fn=RES*2)
                    translate([19,0]) circle(d=4,$fn=RES/2);
        }

        rotate(30) translate([17,0,30-6]) rotate([0,-90,0])
            fan30screwMount();
        
        // fill in under edges of hotEndMount
        rotate(-60) translate([0,.5,51.2-5]) mirrorX(19) {
            hull() {
                translate([0.5,4.25,2]) cube([1,27.5,1],center=true);      
                translate([-3,4.25,-3.5]) cube([3,27.5,1],center=true);      
            }
        }
        rotate(30) translate([15.4,0,42.3])
            mirrorY(12.4) hull() {
                cube([6,10,.1],center=true);
                translate([-2,-1,-3.8]) cube([6,9,.5],center=true);}
            
        // re-enforcement at top of ridges around shroud
        for(a=[-30:120:290]) rotate(a) translate([19,0,51.2-5.5]) 
            translate([0,0,-4]) sphere(3.5,$fn=RES/2);
    }
    translate([.5,.5,53.65-5]) rotate(-60) retentionTabBase(.1);

    kinMountBalls();
    //translate([0,0,zMag]) onMount() sphere(d=dBall+.2,$fn=RES);

    rotate(30) translate([17,0,30-6]) rotate([0,-90,0])
        fan30holes(1.4,8);  // re-drill holes through shroud

    // trim off any protrusions into the fan
    rotate(30) translate([17,0,30-6]) rotate([0,-90,0])
        translate([0,0,-5]) cube([31,31,10],center=true);
    
    translate([0,0,-7.9]) cylinder(r=16+1,h=TubeHeight+7,$fn=RES*1.5);
    
    // remove top of ball on open end
    rotate(30) translate([-19,0,43.6]) rotate([0,15,0])
        cylinder(r=4,h=5,$fn=12);
    
    // carve out to insert hot-end
    wc=3.5;
    *#translate([0,-wc,TubeHeight+5+2]) hull() pairY(wc)
        cylinder(d=16.2,h=5,$fn=RES);
}

TubeHeight1 = 39;  //40
module hotEndFrame1() difference() {
    union() {
        if (RES < 40)
           translate([0,0,53.65]) hotEndMount(false,false);
        else
           translate([0,0,10.25]) import("hotEndMount.stl");
        
        ballMounts();
//        #for(a=[90:120:355]) rotate(a) {
//            translate([rBase, 0, zMag])
//                rotate([0,-30,0]) {
//                    cylinder(d1=dBall-.5,d2=dBall-2,h=20,$fn=RES);
//                }
//        }
        
        translate([0,0,9]) {  // hot end cooling shroud
            cylinder(r=19,h=TubeHeight,$fn=RES*1.5);
            for(a=[90:120:355]) rotate(a) {
                for (k=[-1,1]) translate([0,0,9])
                    linear_extrude(TubeHeight-9,twist=k*120,$fn=RES)
                        translate([18,0]) //scale([3,3])
                            circle(3,$fn=RES/2);
                    translate([18,0,9]) {
                        scale([4,2]) cylinder(r=1,h=TubeHeight-9,$fn=RES/2);
                        hull() {
                            scale([6,3.5,4]) sphere($fn=RES/2);
                            translate([-1,0,-7]) cube(1,center=true);
                        }
                    }
            }
        }

        rotate(30) translate([17,0,30]) rotate([0,-90,0])
            fan30screwMount();
        
        // fill in under edges of hotEndMount
        translate([0,.5,51.2]) mirrorX(19) {
            hull() {
                translate([0.5,4.25,2]) cube([1,27.5,1],center=true);      
                translate([-3,4.25,-3.5]) cube([3,27.5,1],center=true);      
            }
            hull() {
                translate([-2,-10.5,-4.5]) sphere(3,$fn=RES/2);
                translate([0,-9,2]) cube(.1);
            }
        }
        translate([0,19,47.4]) hull() { sphere(3,$fn=RES/2);
            translate([0,-4,8]) cube(1,center=true);
        }
    }
    translate([0,1,53.65]) retentionTabBase(.1);

    kinMountBalls();
    //translate([0,0,zMag]) onMount() sphere(d=dBall+.2,$fn=RES);

    rotate(30) translate([17,0,30]) rotate([0,-90,0])
        fan30holes(1.4,8);  // re-drill holes through shroud

    // trim off any protrusions into the fan
    rotate(30) translate([17,0,30]) rotate([0,-90,0])
        translate([0,0,-5]) cube([31,31,10],center=true);
    
    cylinder(r=16+1,h=TubeHeight+7,$fn=RES*1.5);
    
    // carve out to insert hot-end
    wc=3.5;
    translate([0,-wc,TubeHeight+5]) hull() pairY(wc)
        cylinder(d=16.2,h=5,$fn=RES);
}

// about 6mm wide on 8mm ball (Measured 5.9 and 7.9)
// housing 011.8, 4.4 thick
module heimEyeM3() difference() {
    union() { 
        intersection() { cube([10,10,6],center=true);
            sphere(d=7.937,$fn=RES/2); }  // from drawing
        rotate_extrude($fn=RES)
            translate([11.8/2-2.2,0]) circle(d=4.4,$fn=RES/2);
    }
    cylinder(d=3,h=7,center=true,$fn=RES/2);
}
module heimEyeM4() difference() {
    union() { 
        intersection() { cube([10,10,7],center=true);
            sphere(d=9.525,$fn=RES/2); }  // from drawing
        rotate_extrude($fn=RES)
            translate([14/2-4.3/2,0]) circle(d=4.3,$fn=RES/2);
    }
    cylinder(d=4,h=10,center=true,$fn=RES/2);
}

module effector(withAirDuct=1,withSwitchMount=1) difference() {
    effectorBody(withAirDuct,withSwitchMount);
    
    // make sure bottom is flat
    //translate([0,0,-4-4]) cube([80,80,8],center=true);
    
    #armBolts();
    if (withAirDuct) airDucts();  // for part cooling fan
    
    // t is magnet thickness
    t = 2*tMag;  // double magnets if no air duct
    #translate([0,0,zMag]) rotate(60) onMag() mag(d=dMag+.2,t=t);

    // cut down corners of part fan duct. 
    //   this is an area which may interfere with horns
    //translate([-19,-38.5,10]) cylinder(r=10,h=20,$fn=4);

    // these intersect frame, so must drill out after body
    if (withSwitchMount) switchMountRxHoles(PosSwitchRx);
}


//%translate([-1.75,-10,-12]) nanoSwitch();

use <switchMount.scad>;

module effectorBody(withAirDuct=1, withSwitchMount=1) union() {
    translate([0,0,zMag]) rotate(60) onMag() magMount();
        
    onMount(rBase) mountHorns();

    for(a=[30:120:355]) rotate(a) translate([rBase-2+2,0,.663*0])
        rotate([90,-18,0]) cylinder(r=7,$fn=5,center=true,h=32.4);
        //-.146 for r=5
//        #outerBrace(46-15);        

    *for(a=[90:120:355]) rotate(a) translate([rBase+2.5+5,0,-3.5])
        hornBrace(26);

    if (withSwitchMount) switchMountRxBody(PosSwitchRx);
    
    if (withAirDuct) translate([0,-rBase,8]) partFanDuct();
}
module effectorBody1(withAirDuct=1, withSwitchMount=1) union() {
    translate([0,0,zMag]) onMag() magMount();
        
    onMount(rBase+10) mountHorns();

    //%for(a=[30:120:355]) rotate(a) translate([rBase+1,0,-5])
    //    outerBrace1(45);        
    for(a=[30:120:355]) rotate(a) translate([rBase-2,0,.663])  //-.146 for r=5
        outerBrace(46);        
    for(a=[90:120:355]) rotate(a) translate([rBase+2.5+5,0,-3.5])
        hornBrace(26);

    if (withSwitchMount) switchMountRxBody(PosSwitchRx);
    
    if (withAirDuct) translate([0,-rBase,8]) partFanDuct();
}



module nylocM3() difference() {
    union() {
        cylinder(d=6.1,h=3,$fn=6);
        cylinder(d=5,h=4,$fn=RES/2);
    }
    cylinder(d=3,h=9,$fn=RES/2);
}

module armBolts1() onMount(rBase+10) rotate([90,0,0])
    cylinder(r=1.55,h=41,center=true,$fn=RES/2);
module armBolts3() onMount(rBase) rotate([90,0,0]) translate([0,0,4]) {
    cylinder(r=1.55,h=80,center=true,$fn=RES/2);
    %translate([0,0,-40-3]) cylinder(d=5.5,h=3,$fn=RES/2); // sockethead
    %translate([0,0,32]) nylocM3();
}

// this is for m4.  M4 head and nyloc sizes not yet measured
module armBolts() onMount(rBase) rotate([90,0,0]) translate([0,0,3]) {
    cylinder(d=4,h=80,center=true,$fn=RES/2);
    %translate([0,0,-40-4]) cylinder(d=5.5,h=4,$fn=RES/2); // sockethead
    %translate([0,0,35]) nylocM3();
}

module airDucts() {
    for(a=[0:120:355]) rotate(a) {
        translate([0,-rBase+2,.8]) rotate([90,55,90])
            cylinder(r=4.5,h=50,$fn=5,center=true);
       
        translate([0,rBase+5,-2.85]) rotate([90,0,90]) 
            linear_extrude(23,center=true) polygon([
                [-1.5,0],[-5,4],[0,7],[5,4],[7,0]]);
    }
    
    // part fan
    // moving to modular fan mount
    *hull() { partFanDuctJoint();
        // 3010 blower hole is 20x7.4, 2.6mm in from edge
        translate([0,-rBase-30,32]) rotate([FanTilt4020,0,0])
            cube([16.4,26,1],center=true); }
    hull() { partFanDuctJoint();
        translate([0,-rBase+1.5,-2.5]) cube([34,4.5,1],center=true);  }
    
    // outlets
    //translate([0,-rBase+2,0]) hull() {
    //    translate([0,10,-6]) cube([8,1,2],center=true);
    //    translate([0,2,3]) cube([10,1,3],center=true);
    //}
    //mirrorX() rotate(60)
    //hull() translate([0,rBase-2,0]) {
    //    translate([0,-12,-7]) cube([12,1,2],center=true);
    //    translate([0,-5,-.5]) cube([14,.1,4],center=true);
    //}
    outlet(10);
    for(a=[-120,120]) rotate(a) outlet(8);
}
module outlet(w) hull() {
    translate([0,rBase-5  ,-8]) cube([w+2,4,1],center=true);
    translate([0,rBase+3, -.5]) cube([w,4,4],center=true);
}


//translate([0,0,-50]) { %outerBrace1(); outerBrace(); }
module outerBrace1(len=50) rotate([90,0,180])
    linear_extrude(len,center=true)
        polygon([[-2,0], [-1,9], [0,10], [6,10],[8,0]]);
module outerBrace(len=50) hull() {
    rotate([90,-18,0]) cylinder(r=6,h=len  ,$fn=5,center=true);
    translate([0,0,3.8-3]) rotate([90,0,0])
        cylinder(d=1,h=len+12,$fn=4,center=true);}


// has rBase, cannot be in partFanMounts.scad
module partFanDuctJoint() translate([0,-rBase-.3,10])
    pairX(8) cylinder(d=10,h=1,$fn=RES/2);

// moved to partFanMounts.scad? module fanDuctMount(fuzz=0) pairX(10) cylinder(r1=6+fuzz,r2=4+fuzz,h=3,$fn=RES);
module partFanDuct() {    // part fan duct 4020 blower
    
    // making a generic fan mount coupling, instaed of full fan mount model here.
//    *hull() { pfdJoint();
//        translate([0.5,-9-19,23.45-4])
//            rotate([FanTilt4020,0,0])
//                cube([20,30,1],center=true); }
    hull() { pfdJoint();
        translate([0,3,-11]) pairX(16) cylinder(r=4,h=4,$fn=RES/2); }
    translate([0,0,-.1]) fanDuctMount();
        
    // fan mount
        //%translate([0,-50,20]) cube([30,1,50],center=true);
    //translate([-9.3-2.7,5,9.5]) rotate([90,0,0]) difference() {
    //    blowerMount30Base();
}
module hornBrace(len=20) rotate([0,0,180]) hull() {
    translate([2.5+2,0, 7.5 ]) cube([16,len, 2],center=true);
    translate([-1+1,  0,-1.2]) cube([10,len,.6],center=true);
}

module mountHorns() rotate([90,0,0]) {
    hull() {
        mirrorZ(-wHorns/2) cylinder(r1=3.2, r2=5.5, h=4, $fn=RES);
        rotate(18) cylinder(r=7,h=wHorns-12,$fn=5,center=true);
    }
    //%pairZ(wHorns/2+3) heimEyeM3();
    %pairZ(wHorns/2+3.5) heimEyeM4();
}

// put magnet face at z=0
module magMount() difference() {
    hull() {
        // expose top 1.5mm of magnet
        translate([0,0,-tMag-2.5]) cylinder(r1=dMag/2+2, r2=dMag/2+1,
            h=tMag+1, $fn=RES);
        translate([0,3-2,-9]) rotate([aMag,0,0]) 
            cube([dMag+4,sin(aMag)*dMag+4+2,.1],center=true);
    }
    
    //translate([0,10,-12]) rotate([45,0,0]) cube(20,center=true);
    
    %translate([0,0,dBall/2]) sphere(d=dBall,$fn=30);
}

module ball(d=dBall) sphere(d=d,$fn=RES);
module mag(d=dMag, t=tMag) translate([0,0,-t])
    cylinder(d=d,h=t,$fn=RES);

module onMount(r=rBase) for(a=[90:120:355]) rotate(a) translate([r,0,0]) children();
//module mountBalls() onMount() ball();
//module mountMags() onMount() magnetPair() children();
module magnetPair(r=dBall/2) mirrorX(0) rotate([-aMag,0,0]) translate([0,0,-r]) children();
module magMounts(r=rBase) onMount(r) mirrorY(3) rotate([aMag,0,0]) magMount();
module onMag() onMount() { %ball();
    mirrorY(0) rotate([-aMag,0,0]) translate([0,0,-dBall/2]) children(); }
    

/* $Id: kinematicMount.scad,v 1.4 2026/11/13 17:20:25 aaron Exp aaron $
$Log: kinematicMount.scad,v $
Revision 1.4  2026/11/13 17:20:25  aaron
*** empty log message ***

*/
