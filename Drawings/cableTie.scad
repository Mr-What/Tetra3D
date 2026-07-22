// a cable tie down that attaches to slotted extrusion
RES=30;

//translate([0,0,3]) M3_8();
//%cube([20,20,1],center=true);

difference() {
    union() {
        cylinder(r1=4.5,r2=3.8,h=7,$fn=RES);
        for(a=[0:90:355]) rotate(a) tab();

        hull() { translate([8.5,0,0]) 
            scale([1.5,2]) cylinder(r1=.95,r2=.5,h=2,$fn=RES);
            cylinder(r1=5,r2=4.3,h=2,$fn=RES);
        }
        translate([0,0,5]) {
            mirror([sqrt(2),sqrt(2),0]) tieBar();
            tieBar();
        }
     }

    cylinder(r=1.4,h=22,$fn=RES/2,center=true);
    translate([0,0,3.5]) cylinder(r1=2.6,r2=3,h=8, $fn=RES);
    translate([0,0,-20]) cube(40,center=true);
}

module M3_8() { cylinder(h=3,r=2.6,$fn=24);
    translate([0,0,-7.7]) cylinder(r=1.3,h=8,$fn=16); }
module M4_8() { cylinder(h=4,r=3.3,$fn=24);
    translate([0,0,-7.7]) cylinder(r=1.9,h=8,$fn=16); }

module tieBar()rotate_extrude(angle=90,$fn=RES) translate([8,0])
       scale([1,1.5]) circle(1,$fn=RES);
    
module tab() { 
    translate([5,0,1])
    rotate([90,90,0]) rotate_extrude(angle=200,$fn=RES) translate([5,0])
    scale([1.5,2.5]) circle(1,$fn=RES);
}
    