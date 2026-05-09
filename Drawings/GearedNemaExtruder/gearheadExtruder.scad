// add some features to thingiverse drawing circa 2015
RES=30;  // make larger for production render

Tlever = 11;  //lever thickness
Zlever = 10;  // lever center this far from bottom of block

Zenv = 5.5;  // height of envelope around idler

aLo = -10;  // min angle to animate
aHi = 3;  // max angle to animate

block();

// computed animation parameters, only for lever.
amp = (aHi - aLo)/2;
a0=aLo+amp;
a1 = asin(a0/amp);
p = $t*360-a1;
a = a0 + amp*sin(p);  // animation angle
//a=aHi;
echo("anim ang ",round(a));

%translate([10,-10,Zlever])  // put rotational axis where it belongs
rotate(a)  // comment this out to turn off animation
lever();

// i think gearhead holes are 20mm on center
//%translate([-10,10,5]) {
//}
//idler();

//%translate([0,0,7.8+2.25]) cube([80,1,2],center=true);


rM3nut = 5.5/cos(30);  // radius to tips of M3 nut
rM3head = 5.4/2;  // radius of M3 socket head

idlerOffset = [0,7,0];

module lever() difference() { leverBody();
    cylinder(r=1.6,h=44,center=true,$fn=RES/2); // axle

    translate(idlerOffset) {
        idlerEnvelope();
        difference() {  // remove thin walls around idler
            linear_extrude(Zenv,center=true) polygon([
                [-6,6],[4,6],[5,3], [-6,-3]]);
            cylinder(r=3.5,h=Zenv+1,center=true,$fn=20);
        }
        cylinder(r=1.4,h=44,center=true,$fn=RES/2);  // let lower be thread tight
        cylinder(r=1.6,h=11,$fn=RES/2); // top side free
    }
    
    // clearance around filiment path
    translate([-4.7,-8]) rotate([-90,0,  2]) cylinder(r=1.6,h=22,$fn=RES/2);
    translate([-6.4,-8]) rotate([-90,0,-10]) cylinder(r=1.6,h=22,$fn=RES/2);

    //translate([0,0,10]) cube([200,200,20],center=true);
}

module leverTip() intersection() { cube([20,20,4],center=true);
    rotate_extrude($fn=RES) translate([3.3,.8]) circle(1.5,$fn=RES/2);
//        if (!outerOnly)
//        rotate_extrude($fn=RES) translate([3,-.5]) scale([2,1]) circle(1,$fn=RES/2);
//    }
}

module leverForkIdler() mirrorZ() translate([0,0,4]) leverTip();

module leverForkBrace() mirrorZ() translate([0,0,4]) rotate(-45)
    translate([12,2]) scale([.6,.6,1]) leverTip();

module leverAxle() mirrorZ() translate([0,0,4]) scale([.8,.8,1]) leverTip();

module leverHandle() difference() {
    hull() { leverAxle();
        mirrorZ() translate([60,2,4]) scale([.3,.3,1]) leverTip();
    }

    // grooves for rubber bands
    mirrorZ() translate([56,1.9,7]) rotate([90,0,2])
       scale([1,1,.7])spool(5,6,6,3);    
}

module leverBody() union() {
    translate(idlerOffset) %idler();
    translate(idlerOffset) hull() { leverForkIdler(); leverForkBrace(); }

    leverHandle();    
    hull() { translate(idlerOffset) leverForkIdler();
        leverAxle();
    }
    
    // spacer to gearhead base plate
    translate([0,0,-Zlever+.1]) cylinder(r1=2.7,r2=3.8,h=5,$fn=RES);
}

module idlerEnvelope() difference() { // clear close envelope around idler
    cylinder(r=4.5,h=Zenv,center=true,$fn=RES);
    mirrorZ() translate([0,0,2.1]) cylinder(r1=2.4,r2=3.2,h=1,$fn=RES/2);
}

module mirrorZ() { mirror([0,0,1]) children(); children(); }

module blockBody() union() {
    rotate_extrude($fn=2*RES) translate([14.15-2.8,0]) hull() {
        square(6.8);
        translate([3.4,20]) circle(3.4,$fn=RES);
    }
    translate([9,12.2,Zlever]) leverHandle();
}

module block() difference() { blockBody();
        
        gearhead(.2);
        translate([0,0,21]) onHeadBolts()
            cylinder(r1=rM3head-.1, r2=rM3head+.2, h=4, $fn=RES/2);
       
        //slot for arm
        translate([0,0,Zlever]) hull() {
            translate([10,-10]) cylinder(r=5,h=Tlever+2,center=true,$fn=RES);
            translate([10,0]) rotate(10) scale([6,3,1])
                cylinder(r=1,h=Tlever+2,center=true,$fn=RES);
            translate([28,-14]) cylinder(r=.1,h=Tlever+2,center=true,$fn=3);
        }
        
        // hole for filament
        #rotate(0) translate([6,0,Zlever])
            rotate([-90,0,0]) cylinder(r=1,h=40,$fn=RES/2);
        #rotate(-7) translate([6,0,Zlever])
            rotate([ 90,0,0]) cylinder(r=1,h=40,$fn=RES/2);
        
        //translate([0,-50,10]) cube(100);
    }


// drawing I got had spacing of 19.8
// I'll assume drawing was a little off
module onHeadBolts() pairX(10) pairY(10) children();

module gearhead(fuzz=0) {
    // This drawing has holes 19.8mm on center.  Really?
    //translate([-45,-5-19.8,0])
    //#translate([-35.1,-14.9,0])
    //import("Block.STL");
    
    translate([0,0,-23]) cylinder(r=18+fuzz,h=23,$fn=40);
    cylinder(r=11+fuzz,h=2,$fn=24);
    cylinder(r=4,h=18+2,$fn=RES/2); // drive shaft
    #translate([0,0,6]) cylinder(r=11/2,h=11,$fn=24); // gnurled/grove drive sleeve
    
    // screw shafts to drill out other parts
    translate([0,0,-4]) onHeadBolts()
       cylinder(r=1.6,h=44,$fn=RES/2);
}

module block1(ext=true) union() {
    // I have some odd 05.8mm bowden ends.  tube fitting?
    // drawing seems to be 05mm.  Bore out hole a bit
    difference() {
        // put rotational axis over origin
        translate([-5.5,-21,10]) rotate([90,0,0]) cylinder(r1=2.5,r2=3,h=5,$fn=RES/2);
    }

    if (ext) translate([19,-23,2.25]) rotate([0,0,-10])
        rubberBandExtension(2.25);    
}

module lever1(ext=true) union() {
    
    // put rotation axis over origin
    translate([-45,-14,0])
        import("Lever.STL");  // original drawing from thingaverse

    if (ext) translate([19,4,0]) rotate([0,0,10])
        rubberBandExtension(0);
    
    
    %translate([0,-9.9,7.9]) idler();
}

// extended arm to use rubber bands instead of spring
module rubberBandExtension(lift=2.25, h=12, z0=7.8) difference() {
    union() {
        rotate([0,-90,0])
            linear_extrude(30,center=true) hull() {
                translate([0,-2.5]) square([1,5]);
                translate([h,0]) circle(2.5,$fn=RES);
            }
            
        translate([0,0,-lift]) hull() { 
            translate([4.4,0,0])
                cylinder(r=2.5,h=lift+.1,$fn=RES/2);
            translate([-15,-2.5,0]) cube([1,5,lift+.1]);
        }
    }
    
    translate([10,0,z0]) pairZ(7) rotate([90,0,0]) spool();
}

// for 693ZZ 3x8x4 sealed bearing
module idler() difference() { cylinder(r=4,h=4,center=true,$fn=48);
    cylinder(r=1.5, h=5, center=true, $fn=24);
}

// printed idler would need to be a little bigger than we can do with a bearing
module idler1() difference() { spool(5.5,6.8,4,1.8);
    cylinder(r=1.6,h=9,center=true,$fn=RES/2);
}
    
module spool(r=6, rg=6, w=5, gr=2.9) difference() { cylinder(r=r,h=w+.1,$fn=RES,center=true);
    rotate_extrude($fn=4*RES) translate([rg,0]) circle(gr,$fn=RES);
}

module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
