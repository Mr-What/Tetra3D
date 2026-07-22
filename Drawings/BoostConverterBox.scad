// box fot MT3608 based boost-converter card
//    With hole for JST-PH connector, to be glued to box.
//    Male end should be on wire

RES=24*1;
CardX=37;
CardY=17;
CardZ=7;
WithVents=true;

//%difference() {
boxBase();
//    translate([50,0,0]) cube(100,center=true);}
*translate([0,0,12.5+.2])
//rotate([180,0,0])
boxLid();

//%translate([0,0,7]) cube([CardX,CardY,CardZ],center=true);

module boxLid() union() {
    difference() {
        hull() pairX(CardX/2-2) pairY(CardY/2-2) sphere(4.5, $fn=RES);
        translate([0,0,-1.5]) cube([50,40,8],center=true);
        if (WithVents) lidVents();
    } 
    translate([0,0,1.2]) pairX(CardX/2-2) pairY(CardY/2-2)
        cylinder(r1=2,r2=2.5,h=2,$fn=RES);
    translate([0,0,.5]) retainerRidge();
    mirrorY(CardY/2) pairX(11) hull() {
        translate([0,0,-.2]) cube([3,.8,.1],center=true);
        translate([0,0,3.5]) cube([7,.1,.1],center=true);
        translate([0,-3,3])cube([2,.1,.1],center=true);
    }
}

module ventHole() hull() pairX(2) cylinder(r1=.8,r2=1.7,h=3,$fn=RES);
module lidVents() translate([0,0,2]) {
    for(k=[-1:1]) translate([k*12,0,0]) ventHole();
    pairY(5) pairX(6) ventHole();
}
module mirrorY(d) {  translate([0,d,0]) children();
    mirror([0,1,0]) translate([0,d,0]) children();}

module boxBase() difference() {
    translate([0,0,7.5]) // put bottom of box at z=0
    hull() pairX(CardX/2-2) pairY(CardY/2-2) pairZ(5) sphere(4.5  ,$fn=RES);
    translate([0,0,2.5])
    hull() { translate([0,0,16])
        pairX(CardX/2-2) pairY(CardY/2-2) cylinder(r=2.5,h=1,$fn=RES);
        pairX(CardX/2-2) pairY(CardY/2-2)   sphere(2.5,$fn=RES);
    }
    
    // hole for timmper pot
    translate([-CardX/2+.5+8, -CardY/2, 7]) rotate([90,0,0])
        cylinder(r1=1,r2=4,h=6,center=true,$fn=RES);
    
    // hole for Vin wire, which will have female JST-PH connector
    translate([CardX/2,0,11]) rotate([0,90,0]) hull() pairY(1.5)
        cylinder(r2=1.5,r1=3,h=6,center=true,$fn=RES);
    
    // glue JST-Ph male in this hole
    translate([-CardX/2-3,0,10]) {
        cube([4,7.8,6],center=true);
        cube([9,6,4],center=true);
    }
    
    // lid cut-outs
    translate([0,0,17]) cube([50,30,4],center=true);
    
    translate([0,0,13]) retainerRidge(1.1);
    
    // side slots for screwdriver to remove lid
    translate([0,0,15]) mirrorY(9) rotate([-30,0,0]) hull() {
        cube([4,10,1],center=true);
        translate([0,0,3]) cube([8,10,1],center=true); }
        
    // slots on wire holes so we don't have to solder the board into the box
    translate([0,0,14]) pairX(20) cube([4,1,5],center=true);
        
    if (WithVents) boxVents();
}

module sideVentHole() rotate([-90,0,0]) ventHole();
module boxVents() {
    translate([0,0,4]) {
        mirrorY(8.5) {
            sideVentHole();
            translate([12,0,0]) sideVentHole();
        }
        translate([-12,8.5,0]) sideVentHole();
    }
    translate([0,8.5,9]) pairX(6) sideVentHole();
    mirror([0,1,0]) translate([6,8.5,9]) sideVentHole();
}
module retainerRidge(r=1) pairY(CardY/2)
    pairX(11) hull() pairX(2*r) sphere(r,$fn=RES/2);

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();
