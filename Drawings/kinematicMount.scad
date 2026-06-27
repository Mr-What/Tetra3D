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
%translate([-1.75,-10,-12])
switchMount();

//%hotEndFrame();
//difference() {
effector();
//rotate(180) translate([-50,-50,30]) cube(100);
//translate([-25,30,8]) cube([50,50,30],center=true);
    //rotate($t*360) translate([0,0,-20]) cube(100);
    //translate([0,0,$t*43-15]) cube([100,100,20],center=true);
//}
//effectorBody();
//translate([0,0,35+$t*15]) cube([90,90,h80],center=true);
//translate([0,-125,-10]) cube(100);
//translate([0,-80,-10]) rotate(-210) cube(50);
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
                rotate([0,-35,0]) {
                    cylinder(d1=dBall-.5,d2=5,h=20,$fn=RES);
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
    
    // cut down corners of part fan duct. 
    //   this is an area which may interfere with horns
    translate([-19,-38.5,10]) cylinder(r=10,h=20,$fn=4);

    // these intersect frame, so must drill out after body
    switchMountRxMagnetHoles();
}

//%translate([-1.75,-10,-12]) nanoSwitch();
module switchMount() { %nanoSwitch();
    difference() {
        union() {
            translate([0,-3,10.4]) rotate([90,0,0])
                switchMountTip();
            hull() {
                translate([0,-4.25,10]) cube([1,2.5,1],center=true);
                translate([0,-4.25,6]) {
                    cube([11,2.5,1],center=true);
                    translate([0,0,-4]) pairX(4.5) rotate([90,0,0])
                        cylinder(d2=2,d1=3,h=2.5,center=true,$fn=RES/2);
                }
            }
            hull() {
                translate([0,-4.25,6-4]) pairX(4.5) rotate([90,0,0])
                        cylinder(d2=2,d1=3,h=2.5,center=true,$fn=RES/2);
                translate([0,-8.5,6.7]) pairX(5) cylinder(d=6,h=.3,$fn=RES/2);
            }
        }
    // inverse taper the magnet pair sockets so they fit cleanly
    // to the bottom for glue mount.  Had trouble with printer
    // kind of 'fillet'ing the bottom corners, so magnet did
    // not have a tight, aligned seat.
    #translate([0,-8.5,6.4]) pairX(4) cylinder(d1=3.2, d2=3.1,h=1,$fn=RES/2);
    #translate([0,-5.5,10.4]) rotate([-90,0,0]) magnet3x1hole();
    #translate([0,0,5.7]) pairX(3) rotate([90,0,0])  // M2 screw holes, self-tap
        cylinder(d1=2.2,d2=1.7,h=7,$fn=RES/2);
}}
    
//translate([0,0,-30]) outerBrace();
//translate([0,0,100]) { %magMount(); rotate([-aMag,0,0]) magMount(); }
PosSwitchRx  = [-1.75,-15.4,-5];
PosSwitchMag = [0,-3.1,-0.2];
module effectorBody() union() {
    translate([0,0,zMag]) onMag() magMount();
        
    onMount(rBase+10) mountHorns();

    //%for(a=[30:120:355]) rotate(a) translate([rBase+1,0,-5])
    //    outerBrace1(45);        
    for(a=[30:120:355]) rotate(a) translate([rBase-2,0,.663])  //-.146 for r=5
        outerBrace(43);        
    for(a=[90:120:355]) rotate(a) translate([rBase+2.5+5,0,-3.5])
        hornBrace(26);

    translate(PosSwitchRx) switchMountRx();
    
    translate([0,-rBase-1,12]) partFanDuct();
}


module switchMountRxMagnetHoles(p=PosSwitchRx) translate(p)
    translate(PosSwitchMag) pairX(4)
        cylinder(d1=3.2, d2=3, h=1.6, $fn=RES/2);  // double size hole

//translate([0,0,-50])
//switchMountCatch();
//switchMountTip();
module switchMountTip(fuzz=0) //{ difference() {
    //intersection() {
      //  cube([7,18,8],center=true);
        translate([0,0,-fuzz])
            cylinder(d1=3+fuzz,d2=8+fuzz,h=2.5+2*fuzz,$fn=RES);
    //}
//    translate([0,0,.97]) magnet3x1hole();
//}
module switchMountCatch() difference() {
    translate([0,2,0]) cylinder(d1=5,d2=9,h=4,$fn=RES);
    translate([0,.5,0]) switchMountTip(.15);
}

module switchMountRx() difference() {
    union() {
        hull() {
            translate([0,-3.1,0]) pairX(5) cylinder(d=6,h=3,$fn=RES/2);
            translate([0,0,7.2]) rotate([90,0,0]) cylinder(d=1,h=5,$fn=4);
        }
        
        // capture tip of switchMount
        translate([0,1.9,3]) rotate([90,0,0]) switchMountCatch();
    }
    
    %switchMountRxMagnetHoles([0,0,0]);
    translate([0,0,3]) rotate([90,0,0]) 
        cylinder(d1=3.1, d2=2.9,h=1.1,$fn=RES/2);
}

module armBolts() onMount(rBase+10) rotate([90,0,0])
    cylinder(r=1.55,h=41,center=true,$fn=RES/2);

//module airDucts() difference() { airDuctsWhole();
//    // remove unnecessary section
//    translate([0,rBase+12,0]) cube(40,center=true);
//}
module partFanDuctJoint() translate([0,-rBase-1,12])
    pairX(7) sphere(3.5,$fn=RES/2);

//translate([0,0,-30]) { %airDucts(); %armBolts(); }
//module airDuctsWhole() {
module airDucts() {
    for(a=[0:120:355]) rotate(a) {
        translate([0,-rBase+1.7,-3.5]) rotate([90,0,90])
            linear_extrude(46,center=true) polygon([
                [-3,0],[-2.5,5],[0,7],[2.5,5],[3,0]]);
       
        translate([0,rBase+5,-3.5]) rotate([90,0,90]) 
            linear_extrude(25,center=true) polygon([
                [-1.5,0],[-4,3],[-4,5],[-1,7],[4,4],[6,0]]);
                //[-1.5,0],[-4,3],[-4,5],[-1,7],[2,5],[3,2],[5,0]]);
    }
    
    // part fan
    hull() { partFanDuctJoint();
        // 3010 blower hole is 20x7.4, 2.6mm in from edge
        translate([-2.7,-rBase-3.2,19]) cube([19.5,7.2,.1],center=true); }
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
module outerBrace(len=50) rotate([90,-18,0]) hull() {
    cylinder(r=7,h=len,$fn=5,center=true);
    cylinder(r=2,h=len+8,$fn=5,center=true);}

//translate([0,0,-50]) blowerMount30Base();
module blowerMount30Base() union() {
    hull() {
        translate([-2,-4]) cube(2);
        translate([24,0]) cylinder(d=6,h=2,$fn=RES/2);
        translate([16,-10]) cube(2);
        translate([0,24]) cylinder(d=6,h=2,$fn=RES/2);
    }
    translate([24,0,-2]) hull() {
        cylinder(r1=2.5, r2=4,h=4, $fn=RES/2);
        translate([-10,-18,2]) cube(2);
        translate([-10, 7,2]) cube(2);
    }
    translate([0,24,-1]) {
        hull() {
            translate([-1,0,-1]) cylinder(r1=4, r2=5,h=4, $fn=RES/2);
            translate([  -4,-48,-3]) cylinder(r=2,h=6,$fn=6);
        }
        hull() {
            translate([-5.6,-44,3.5]) pairZ(3) sphere(2.5,$fn=RES/2);
            translate([-5.6,  2,4]) pairZ(2) sphere(2.5,$fn=RES/2);
        }
    }
}

module magnet3x1() cylinder(d=2.8,h=2.8/3,$fn=16);  // true size
module magnet3x1hole() translate([0,0,-.1])
    cylinder(d1=3.2, d2=3.05,h=.2+2.8/3,$fn=RES/2);  // slightly expanded for holes
    //cylinder(d1=2.9, d2=3.05,h=.2+2.8/3,$fn=RES/2);  // slightly expanded for holes

module pfdJoint() translate([0,0,-1]) pairX(8) sphere(5.5,$fn=RES);
module partFanDuct30() {    // part fan duct, 3010 blower
    hull() { pfdJoint();
        translate([-2,-1,6]) cube([34,12,1],center=true); }
    hull() { pfdJoint();
        translate([0,2.5,-15]) pairX(16) cylinder(r=4,h=4,$fn=RES/2); }
        
    // fan mount
        //%translate([0,-50,20]) cube([30,1,50],center=true);
    translate([-9.3-2.7,5,9.5]) rotate([90,0,0]) difference() {
        blowerMount30Base();
        
        // mount holes  fan hole diameter 1.8
        // make for force thread on M2
        translate([24,0]) cylinder(r=.95,h=12,$fn=RES/3,center=true);
        translate([0,24]) cylinder(r=.95,h=6, $fn=RES/3,center=true);
    }
    %translate([0,3,21.5]) rotate([90,0,0]) fan3010();
}
module partFanDuct() {    // part fan duct 4020 blower
    hull() { pfdJoint();
        translate([0.5,-9-1,23.45]) cube([20,30,1],center=true); }
    hull() { pfdJoint();
        translate([0,2.5,-15]) pairX(16) cylinder(r=4,h=4,$fn=RES/2); }
        
    // fan mount
        //%translate([0,-50,20]) cube([30,1,50],center=true);
    //translate([-9.3-2.7,5,9.5]) rotate([90,0,0]) difference() {
    //    blowerMount30Base();
    translate([10,-16,45]) difference() {
        rotate([0,90,0]) hull() {
            pairX(35/2-.5) pairY(35/2-.5) cylinder(r1=3.5,r2=5,h=3,$fn=RES/2);
            translate([30,18,0]) cube(3);
        }

        #rotate([90,0,90]) on4020bolts()
            cylinder(d=3+  .2,h=33,$fn=RES/2,center=true);
    }
        // mount holes  fan hole diameter 1.8
        // make for force thread on M2
    //    translate([24,0]) cylinder(r=.95,h=12,$fn=RES/3,center=true);
    //    translate([0,24]) cylinder(r=.95,h=6, $fn=RES/3,center=true);
    //}
    %translate([10,-16,45]) rotate([0,90,180]) blower4020();
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
