// clip(s) to hold bed to frame

RES=32;  // larger for production render

bedClip15();

module bedClip15() difference() {  // for 15mm extrusions
    //union() {  don't do this.  often used pointing at an angle
    //    translate([6,0,-1.5]) hull() pairX(1) cylinder(r1=1,r2=2,h=2,$fn=RES/2);
    hull() { 
        translate([-4,0,2]) pairY(2) cylinder(r=2,h=4,$fn=RES/2);
        cylinder(r=5,h=6,$fn=RES);
        translate([5.5,0,0]) cylinder(r1=4,r2=2,h=4,$fn=RES);
    }
    
    cylinder(r=1.6,h=40,center=true, $fn=RES/2);  // M3 screw hole, with slop
    translate([-180,0,-1]) cylinder(r1=178,r2=177,h=3, $fn=3*RES);
    translate([0,0,4]) cylinder(r1=2.6,r2=3,h=6,$fn=RES/2);
}

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
