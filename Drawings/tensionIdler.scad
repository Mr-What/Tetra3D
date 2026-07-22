// lower flange to align with motor seems to be about 19mm from extrusion
// I think this will need about a 32mm M5 bolt

RES=30;

BeltWidth=6;
BeltClearance = 20;
CenterHeight = BeltClearance + BeltWidth/2;
TensionScrewDist = 4.5;

CR=3;  // corner radius

translate([60,0,0]) {
%armProxy();
idlerClamp();
}

screwBase();


//KeyCenter=-20;

module screwBase() difference () { screwBaseBody();
    translate([10,0,-.01]) cylinder(d=5,h=30,$fn=RES);
    translate([4,0,CenterHeight]) pairY(TensionScrewDist)
        rotate([0,-90,0]) {
            translate([0,0,-50]) cylinder(d=3.1,h=51,$fn=RES/2);
            cylinder(d1=5.5,d2=5.8,h=10,$fn=RES/2);
        }
    translate([-14,0,-.1]) {
        cylinder(d=5,h=41,$fn=RES/2);
        translate([0,0,6]) cylinder(d1=8.3,d2=8.6,h=10,$fn=RES/2);
    }

    //translate([10,0,10+23]) cube(20,center=true);
}

module idlerClamp() difference() { idlerClampBody();
    cylinder(d=5+.1,h=55,center=true,$fn=RES);
    //mirror([0,1,0]) key(1.05);
    translate([-28,0,0]) cylinder(d=3.1,h=40,$fn=RES/2);
    translate([-16,0,CenterHeight]) rotate([0,-90,0])
        pairY(TensionScrewDist) {
            cylinder(d=3,h=25,$fn=24);
            translate([0,0,7]) cylinder(d=6.5,h=2.5,$fn=6);
        }
}

module screwBaseBody() union() {
    hull() {
        translate([0,0,CR]) pairX(18) pairY(7) corner();
        translate([12,0,CenterHeight+2]) pairX(6) pairY(7) corner();
    }
}

module baseTorus() rotate_extrude($fn=2*RES)
    translate([7,0]) pairY(1) circle(CR,$fn=RES/2);
module corner() sphere(CR,$fn=RES/2);

TorusDx=12;
module idlerClampBody() union() {
    translate([0,0,10.5]) cylinder(d1=12,d2=6.5,h=8,$fn=RES);
    translate([-TorusDx,0,13.5]) hull() pairX(TorusDx) baseTorus();
    hull() {
        translate([-2*TorusDx,0,13.5]) baseTorus();
        translate([-2*TorusDx-2,0,CenterHeight-CR]) pairY(7) pairX(5) corner();
    }
}

//module key(scl=1) translate([KeyCenter+5,4,23])
//       scale(scl) corner();

module armProxy() {
    translate([0,0,23]) difference () {
        cylinder(d=18,h=8.6+.2,$fn=36,center=true);
        cylinder(d=12,h=10,$fn=36,center=true); //diameter, to outside of teeth
    }
    translate([-30,0,-10]) cube([120,20,20],center=true);
    translate([40,0,3+20]) pairY(6) cube([80,2,6],center=true);
    //%translate([8,0,0]) cube(20);  // 20mm to bottom of belt
    //%cube(4);  // M5 nuts often 4mm thick
}


*difference() { idlerMountEnvelope();
    cylinder(r=2.5,h=44,center=true,$fn=RES/2);
    
    pairX(13) { cylinder(r=1.5,h=44,center=true,$fn=RES/2);
        translate([0,0,5]) cylinder(r1=2.6,r2=4,h=10,$fn=RES);
    }
} 
    
module idlerMountEnvelope() union() {
    // M5 regular nut, 3.5mm thick, 
    //         add another 1mm for washers???
    translate([0,0,3]) cylinder(r2=3.5,r1=9,h=16-3.5-1,$fn=RES);

    hull() {
        translate([0,0,2]) pairX(16) pairY(8) sphere(2,$fn=RES);
        translate([0,0,12]) cylinder(r=4,h=.1,$fn=RES);
    }
}

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();
module pairDiag(d) for(a=[-1,1]) translate([-a*d,a*d,0]) children();
