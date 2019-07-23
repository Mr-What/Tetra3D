ext15(2,0.2);
ext15(4);
translate([0,0,3.98]) ext15(2,-0.1);

module ext15(len,fuzz=0) {
  linear_extrude(len) ext15profile(fuzz);
}

module slotT1profile(w,rs,re) {
$fn=24;
  hull() {
    translate([-w/2+re,-rs-re]) circle(r=re);
    translate([   -1   , -8  ]) square([1,8-rs+1.2]);
    translate([-w/2-0.5,-10  ]) square([w/2,1]);
  }
}


// rs -- radius of slot (slot width/2)
// d  -- depth  of slot
module slotTprofile(w,rs,d) {
re=0.3;
$fn=24;
  difference() {
    translate([-w/2-2,-9]) square([w/2+2,18]);

    difference() {
      union() {
        translate([-w/2+d-rs,-10]) square([6,20]);
        mirror([0,1]) slotT1profile(w,rs,re);
                      slotT1profile(w,rs,re);
      }

      translate([-w/2, 0 ,-1]) hull() {
        translate([d-rs,0]) circle(r=rs-0.5);
        translate([0,-rs+.2]) square([0.1,2*rs-.4]);
      }
    }
  }
}

module ext15profile(fuzz=0) {
w=15;

wz = w + fuzz;
w1 = wz-abs(fuzz)*2;
  difference() {
    union() {
      square([wz,wz],center=true);

      // extra room on corners, where slop can be a problem 
      if (abs(fuzz) > 0) {
      //if (fuzz > 0) { 
        for(i=[-1,1]) for(j=[-1,1])
          translate([i*w1/2,j*w1/2,0])
           circle(r=abs(fuzz)*2,$fn=8);
      }
    }

    for (a=[0:90:355]) rotate([0,0,a])
       slotTprofile(wz,3.2/2-fuzz,4.5-fuzz);
  }
}

