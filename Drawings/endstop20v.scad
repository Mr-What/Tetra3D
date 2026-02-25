include <configuration.scad>;
use <microswitch.scad>;
//use <ext20v.scad>;
use <ext20.scad>;

use <tiltedDelta.scad>;

m5rad = 4.92/2;//4.88/2;
m5_head_radius = 8.62/2;//8.5/2;  // 5mm head height, uses 4mm hex drive

RES=30;  // make larger for final production render

//microswitchEndstop20v(.1);
endstop20v(.2);

//Plain endstop for 7.7mm thick linear bearing
module endstop20v(fuzz) {
    color([0,0,1,.005]) translate([0,20,-10]) rotate([90,0,0]) ext20(40,0);
    %translate([-6,-30,0]) cube([12,20,7.7]);  // linear rail
    difference() {
        union() {
            translate([0,0,2+4]) hull() {
                pairX(8) pairY(8) pairZ(4) sphere(2,$fn=RES);
            }
            translate([0,0,-1]) pairY(6) hull() pairY(1)
                scale([2,1,1]) cylinder(r1=1,r2=1.5,h=1.1,$fn=RES/2);
        }
        
        // M3 screw hole
        //cylinder(r=1.5+fuzz,h=60,center=true,$fn=RES/2);
        //translate([0,0,5]) cylinder(r1=
        translate([0,0,9]) M3screwHole(20,6,fuzz);
        //cube(100);
    }

 
    
}

module pairX(d) for(a=[-d,d]) translate([a,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a]) children();
module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();

module armMount() difference() {
    translate([0,11.5,0]) cube([26,13,44],center=true);
    #translate([0,7+3+5]) cube([1.5,6.1,1200],center=true);
}
module microswitchEndstop20v(fuzz) {
    *%translate([0,-4,-200*0+.2]) cube([12,8,400],center=true);  // linear rail
    *%translate([0,0,-22]) {
        cube([26.5,10,44],center=true); // linear rail bearing
        armMount() ;
    }
    %translate([0,8.3,7]) rotate([0,180,0]) microswitch();
  
    difference() {
        union() { translate([0,2.65-4,12]) hull()
            pairX(8) pairY(4.6) pairZ(10) sphere(2,$fn=RES);
            translate([0,-9.5,7]) hull() pairZ(3) rotate([-90,0,0])
                cylinder(r1=1.5,r2=2.5,h=3,$fn=RES/2);
        }
        
      translate([0,0,7]) {
          microswitchHoles(-.2); // make smaller, to thread M2
          //%translate([0,-20,0]) //{cube(3.8,center=true); // actual width of M2 nut
          translate([0,-3,0]) pairX(4.8) rotate([90,30,0])
              cylinder(r1=2.19,r2=2.8,h=20,$fn=6);  // M2 nut hole
      }
      translate([0,-1,18]) rotate([-90,0,0]) M3screwHole(20,8,0.15);
    }
/*
    #translate([0,16,10+6]) rotate([90,0,0]) ext20(30,fuzz,verbose=0);
    translate([-26,-12,8]) cube([20,30,8]);

    // 5mm bolt hole
    cylinder(r=m5rad+fuzz,h=11,$fn=15);
    translate([0,0,-4])
       cylinder(r2=m5_head_radius,r1=m5_head_radius+.3,h=5,$fn=24);

    // 2.4mm diam was good for M2.5.  go a little smaller for #2
    translate([-16.5,10,-1]) for(a=[0,1])
       translate([9.5*a,0,-1]) cylinder(r=2.3/2, h=11, $fn=11);

    // extra clearance for extrusion nut
    translate([0,0,8.8]) cube([10,16,4],center=true);
    translate([0,0,6  ]) cylinder(r=3.5+.2,h=4,$fn=17);
  }
    */
}


// support (not helpful with current shallow countersink... just clean up with drill bit)
*%color("Cyan") {
  difference() {
    cylinder(h=.8,r=3.5,$fn=10);
    translate([0,0,-1]) cylinder(h=7,r=3.2,$fn=10);
  }
}