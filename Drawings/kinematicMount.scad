// test/prototype for a kinematic mount, to be used to
// carry a hot-end/nozzle probe combo
RES=30;   // make larger for production  render

dBall = 8;//12;  // I have some 12mm balls, although I'd prefer 8mm
dMag = 6; //10;  // Actually like 9.8 to 9.9, but I have them .2ish fuzz factor
tMag = 3; //2.6;  // would prefer 3mm thick, but this is what I have
zMag = 11.5;  // offset for magnet assembly

rBase = 23.2;
wHorns = 40;  // must match the width between arm-mount horns on carriage

// angle on mount.  usually 45, but it can differ
// >45 for more vertical holding, at the expense of less XY stability.
// <45 for more XY stability at the expense of less Z holding force
aMag = 45;

%hotEndFrame();
//difference() {
effector();
//rotate(180) translate([-50,-50,30]) cube(100);
//translate([-25,30,8]) cube([50,50,30],center=true);
    //rotate($t*360) translate([0,0,-20]) cube(100);
    //translate([0,0,$t*43-15]) cube([100,100,20],center=true);
//}
//effectorBody();
//translate([0,0,35+$t*15]) cube([90,90,h80],center=true);
//translate([-50,-50,0]) cube(100);
//translate([0,0,-10]) rotate(-210) cube(50);
//}

use <util.scad>;
use <hotEnd.scad>;
%translate([0,0,10]) rotate(180) hotEnd();

//%translate([0,0,12]) onMount() ball();

module hotEndFrame() difference() {
    union() {
        translate([0,0,53.65]) intersection() { 
            cube([40,40,12.9],center=true); 
            hotEndMount(false);
        }
        
        for(a=[90:120:355]) rotate(a) {
            translate([rBase, 0, zMag])
                rotate([0,-30,0]) {
                    cylinder(d1=dBall-.5,d2=4,h=20,$fn=RES);
                }
        }
        
        translate([0,0,9]) {  // hot end cooling shroud
            cylinder(r=19,h=40,$fn=RES*1.5);
            for(a=[90:120:355]) rotate(a) {
                for (k=[-120,120]) translate([0,0,6])
                    linear_extrude(40-6,twist=k,$fn=RES*2) translate([18,0])
                        scale([2,3]) circle(1,$fn=RES/2);
                    translate([18,0,6]) 
                        scale([4,2]) cylinder(r=1,h=40-6,$fn=RES/2);
            }
        }

        rotate(30) translate([17,0,30]) rotate([0,-90,0])
            fan30screwMount();
    }
    translate([0,1,53.65]) retentionTabBase(.1);
    
    translate([0,0,zMag]) onMount() sphere(d=dBall+.2,$fn=RES);

    rotate(30) translate([17,0,30]) rotate([0,-90,0])
        fan30holes(1.45,20);  // re-drill holes through shroud

    // trim off any protrusions into the fan
    rotate(30) translate([17,0,30]) rotate([0,-90,0])
        translate([0,0,-5]) cube([31,31,10],center=true);
    
    cylinder(r=16+1,h=50-4,$fn=RES*1.5);
}

module effector() difference() { effectorBody();
    
    // make sure bottom is flat
    //translate([0,0,-4-4]) cube([80,80,8],center=true);
    
    armBolts();
    airDucts();  // for part cooling fan
    
    translate([0,0,zMag]) onMag() #mag(d=dMag+.2);
}

module armBolts() onMount(rBase+7) rotate([90,0,0])
    cylinder(r=1.55,h=41,center=true,$fn=RES/2);

//translate([0,0,-30]) { %airDucts(); #armBolts(); }
module airDucts() difference() { airDuctsWhole();
    // remove unnecessary section
    translate([0,rBase+12,0]) cube(40,center=true);
}
module partFanDuctJoint() translate([0,-rBase-4.5,10])
    pairX(9) sphere(3.5,$fn=RES/2);

module airDuctsWhole() {
    for(a=[0:120:355]) rotate(a) {
        translate([0,-rBase+3,-3.5]) rotate([90,0,90])
            linear_extrude(38,center=true) polygon([
                [-3,0],[-2.5,5],[0,7],[2.5,5],[3,0]]);
       
        translate([0,rBase,-3.5]) rotate([90,0,90]) 
            linear_extrude(20,center=true) polygon([
                [-5,0],[-3.5,5],[-1,7],[3,5],[4,2],[6,0]]);
    }
    
    // part fan
    hull() { partFanDuctJoint();
        translate([0,-rBase-4.5,17]) cube([19.5,8,.1],center=true); }
    hull() { partFanDuctJoint();
        translate([0,-rBase+3.5, 0]) cube([32,3,1],center=true);  }
    
    // outlets
    translate([0,-rBase,0]) hull() {
        translate([0,10,-6]) cube([8,1,2],center=true);
        translate([0,2,3]) cube([10,1,3],center=true);
    }
    mirrorX() rotate(60)
    hull() translate([0,rBase,0]) {
        translate([0,-12,-7]) cube([12,1,2],center=true);
        translate([0,-5,-.5]) cube([14,.1,4],center=true);
    }
}

module outerBrace(len=50) rotate([90,0,180])
    linear_extrude(len,center=true)
        polygon([[-2,0], [-1,9], [0,10], [6,10],[8,0]]);

//translate([0,0,-30]) outerBrace();
//translate([0,0,100]) { %magMount(); rotate([-aMag,0,0]) magMount(); }
module effectorBody() union() {
    translate([0,0,zMag]) onMag() magMount();
        
    onMount(rBase+7) mountHorns();

    for(a=[30:120:355]) rotate(a) translate([rBase,0,-5])
        outerBrace(36);        
    for(a=[90:120:355]) rotate(a) translate([rBase+4.5,0,-3.5]) hornBrace(20);

    translate([0,-rBase-4,11]) partFanDuct();
}

module partFanDuct() {    // part fan duct
    hull() { pairX(8) sphere(6,$fn=RES);
        translate([0,0,5]) cube([21+2,12,1],center=true); }
    hull() { pairX(8) sphere(6,$fn=RES);
        translate([0,8,-13]) pairX(17) cylinder(r=3,$fn=RES/2); }

    // fan mount
    translate([-9.3,6,9]) rotate([90,0,0]) difference() {
        hull() {
            translate([-3,-4]) cube(2);
            translate([0,-8,.5]) cube(1.5);
            translate([24,0]) cylinder(d=6,h=2,$fn=RES/2);
            translate([20,-12]) cube(2);
            translate([0,24]) cylinder(d=6,h=2,$fn=RES/2);
        }
        translate([24,0]) cylinder(r=1.3,h=6,$fn=RES/3,center=true);
        translate([0,24]) cylinder(r=1.3,h=6,$fn=RES/3,center=true);
    }
    %translate([2.7,4,21]) rotate([90,0,0]) fan3010();
}

//translate([0,0,-30]) hornBrace(22);
module hornBrace(len=20) rotate([0,0,180]) hull() {
    translate([0,  0, 8.35]) cube([15,len,.3],center=true);
    translate([2.5,0,-1.35]) cube([20,len,.3],center=true);
}

module mountHorns() mirrorY(wHorns/2) hull() { rotate([90,0,0])
    cylinder(r1=2.5, r2=4, h=3, $fn=RES);
    translate([0,-12,0]) cube(10,center=true);
}

/* util

module fan40() difference() {
    hull() pairX(16) pairY(16) cylinder(r=4, h=10,$fn=36);
    translate([0,0,-1]) {
       pairX(16) pairY(16) cylinder(r=1.5,h=12,$fn=24);
    //pairX(16) pairY(16) cylinder(d=3,h=11,center=true,$fn=24);
       cylinder(d=38,h=12,$fn=48);
    }
}
module fan30() difference() {  // labeled 3007, but 8mm thick!
    translate([0,0,4]) cube([30,30,8],center=true);
    translate([0,0,-1]) {
       pairX(12) pairY(12) cylinder(r=1.5,h=12,$fn=24);
    //pairX(16) pairY(16) cylinder(d=3,h=11,center=true,$fn=24);
       cylinder(d=28,h=12,$fn=48);
    }
}
module fan3010() difference() {  // labeled 3007, but 8mm thick!
    translate([0,0,5]) cube([30,30,10],center=true);
    translate([0,0,-1]) {
       pairX(12) pairY(12) cylinder(r=1.5,h=12,$fn=24);
    //pairX(16) pairY(16) cylinder(d=3,h=11,center=true,$fn=24);
       cylinder(d=28,h=12,$fn=48);
    }
}

module fan30holes(r=1.5,h=40) translate([0,0,-1]) {
    pairX(12) pairY(12) cylinder(r=r,h=h,$fn=RES/2);
    cylinder(d=27,h=h,$fn=RES*1.5);
    translate([0,0,-5]) cube([30,30,10],center=true);
}
*/

// tight holes to force-screw M3 into plastic
//translate([0,0,-50]) difference() { fan30screwMount(); #fan30holes();}
module fan30screwMount(h=20) { %translate([0,0,-10]) fan3010();
    for(a=[45:90:355]) rotate(a) translate([12*sqrt(2),0,0]) hull() {
        cylinder(r1=4,r2=5,h=8,$fn=RES/2);
        translate([-4,0,2]) cube([1,12,4],center=true);
    }
    cylinder(r=15,h=h,$fn=RES*1.5);
}


module fan30mount(h=20) { %translate([0,0,-10]) fan3010();
    difference() {
        union() {
            for(a=[45:90:355]) rotate(a) translate([12*sqrt(2),0,0]) hull() {
                cylinder(r=4,h=4,$fn=RES/2);
                translate([-6,0,4]) cube([1,12,8],center=true);
            }
            cylinder(r=15,h=h,$fn=RES*1.5);
        }
        translate([0,0,3]) pairX(12) pairY(12) cylinder(d=5.5,h=6,$fn=RES/2);
        translate([0,0,-1]) {
            pairX(12) pairY(12) cylinder(r=1.6,h=12,$fn=RES/2);
            cylinder(d=27,h=h+2,$fn=RES*1.5);
        }
    } 
           
}
module fan40mount(h=20) { %translate([0,0,-10]) fan40();
    difference() {
        union() {
            for(a=[45:90:355]) rotate(a) translate([16*sqrt(2),0,0]) hull() {
                cylinder(r=4,h=4,$fn=RES/2);
                translate([-6,0,4]) cube([1,12,8],center=true);
            }
            cylinder(r=20,h=h,$fn=RES*1.5);
        }
        translate([0,0,3]) pairX(16) pairY(16) cylinder(d=5.5,h=6,$fn=RES/2);
        translate([0,0,-1]) {
            pairX(16) pairY(16) cylinder(r=1.6,h=12,$fn=RES/2);
            cylinder(d=37,h=h+2,$fn=RES*1.5);
        }
    } 
           
}

// put magnet face at z=0
module magMount() hull() {
    %translate([0,0,dBall/2]) sphere(d=dBall,$fn=30);
    //difference() {
    // expose top 1.5mm of magnet
        translate([0,0,-tMag-2.5]) cylinder(r1=dMag/2+2, r2=dMag/2+1,
            h=tMag+1, $fn=RES);
    //    #translate([0,-5,-8]) rotate([aMag,0,0]) cube([20,8,20],center=true);
    //}
    translate([0,3,-9]) rotate([aMag,0,0]) 
        cube([dMag+4,sin(aMag)*dMag+4,.1],center=true);
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
