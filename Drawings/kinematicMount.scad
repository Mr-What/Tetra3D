// test/prototype for a kinematic mount, to be used to
// carry a hot-end/nozzle probe combo
RES=30;   // make larger for production  render

dBall = 8;//12;  // I have some 12mm balls, although I'd prefer 8mm
dMag = 6; //10;  // Actually like 9.8 to 9.9, but I have them .2ish fuzz factor
tMag = 3; //2.6;  // would prefer 3mm thick, but this is what I have
zMag = 11.5;  // offset for magnet assembly

rBase = 25;
wHorns = 40;  // must match the width between arm-mount horns on carriage

// angle on mount.  usually 45, but it can differ
// >45 for more vertical holding, at the expense of less XY stability.
// <45 for more XY stability at the expense of less Z holding force
aMag = 45;

//rotate([-90,0,0])
*%translate([-1.75,-10,-12])
switchMount();

hotEndFrame();
//difference() {
*%  effector();
//}

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
%translate([0,0,10]) rotate(180) hotEnd();

// estimating nozzle offset :
//translate([0.1,-10,-12.5]) cube(.1,center=true);
//translate([0,0,-10.8]) cube(.1,center=true);

//%translate(PosSwitchRx) switchMount();
//%translate([0,0,12]) onMount() ball();

module ballMounts(nf=RES) for(a=[90:120:355]) rotate(a) {
            translate([rBase, 0, zMag])
                rotate([0,-30,0]) {
                    cylinder(d1=dBall-.5,d2=dBall-2,h=20,$fn=nf);
                }
        }
module kinMountBalls(fuzz=.2,nf=RES) translate([0,0,zMag])
       onMount() sphere(d=dBall+fuzz,$fn=nf);

TubeHeight = 39;  //40
module hotEndFrame() difference() {
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

module effector() difference() { effectorBody();
    
    // make sure bottom is flat
    //translate([0,0,-4-4]) cube([80,80,8],center=true);
    
    armBolts();
    airDucts();  // for part cooling fan
    
    translate([0,0,zMag]) onMag() #mag(d=dMag+.2);
    
    // cut down corners of part fan duct. 
    //   this is an area which may interfere with horns
    //translate([-19,-38.5,10]) cylinder(r=10,h=20,$fn=4);

    // these intersect frame, so must drill out after body
    switchMountRxHoles(PosSwitchRx);
}


//%translate([-1.75,-10,-12]) nanoSwitch();

use <switchMount.scad>;

module effectorBody() union() {
    translate([0,0,zMag]) onMag() magMount();
        
    onMount(rBase+10) mountHorns();

    //%for(a=[30:120:355]) rotate(a) translate([rBase+1,0,-5])
    //    outerBrace1(45);        
    for(a=[30:120:355]) rotate(a) translate([rBase-2,0,.663])  //-.146 for r=5
        outerBrace(46);        
    for(a=[90:120:355]) rotate(a) translate([rBase+2.5+5,0,-3.5])
        hornBrace(26);

    switchMountRxBody(PosSwitchRx);
    
    translate([0,-rBase,8]) partFanDuct();
}



module armBolts() onMount(rBase+10) rotate([90,0,0])
    cylinder(r=1.55,h=41,center=true,$fn=RES/2);

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
    rotate([90,-18,0]) cylinder(r=7,h=len  ,$fn=5,center=true);
    translate([0,0,3.8]) rotate([90,0,0])
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

module mountHorns() rotate([90,0,0]) hull() {
    mirrorZ(-wHorns/2) cylinder(r1=2.5, r2=4, h=3, $fn=RES);
    cylinder(r=5/cos(30),h=wHorns*.7,$fn=6,center=true);
}

// tight holes to force-screw M3 into plastic
//translate([0,0,-50]) difference() { fan30screwMount(); #fan30holes();}

// put magnet face at z=0
module magMount() difference() {
    hull() {
        // expose top 1.5mm of magnet
        translate([0,0,-tMag-2.5]) cylinder(r1=dMag/2+2, r2=dMag/2+1,
            h=tMag+1, $fn=RES);
        translate([0,3,-9]) rotate([aMag,0,0]) 
            cube([dMag+4,sin(aMag)*dMag+4,.1],center=true);
    }
    
    translate([0,10,-12]) rotate([45,0,0]) cube(20,center=true);
    
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
    

/* $Id$
$Log$
*/
