// cut-out model to fit Openbuilds V-Slot 20mm extrusion

// fuzz is -1/2 kerf for a laser cutter,
// or the amount of extrusion spread for a 3D printer

//slotV20profile(3);
//ext20profile(3);
ext20v(50,0.2);

module ext20v(len,kerf=0,verbose=0) {
  if (kerf == 0)
    linear_extrude(len) ext20profile();
  else if (kerf > 0)
    linear_extrude(len) minkowski() {
      ext20profile(kerf);
      circle(r=kerf/2,$fn=12);
    }
  else linear_extrude(len) difference() {
    square([21,21],center=true);
    minkowski() {
      difference() {
        square([21,21],center=true);
        ext20profile(kerf);
      }
      circle(r=-kerf/2,$fn=12);
    }
  }
}

module slotV20profile(verbose=0) {
// center of square cylinder for V cut-out is 1mm outside of extrusion.
// outside border of extrusion is 1.9mm.  inner slot width is 6.35mm, but
// corners are beveled, so ideal corner would be less
// 1/2 slot width is the same dist as sr-(1+1.9), hence
sr = 1+1.9+(6.2/2);
  difference() {
    // having testing trouble.  I don't want to worry about v-slot tab yet.
    // make it extra small until I'm really ready to tweak it (remove -.3)
    translate([-10-1,0]) circle(r=sr-.3,$fn=4);
    translate([-8+.3+4/2,0]) square([4,7],center=true);  // arbitrary .3mm extra lip to tab
  }

  // actual slot profile
  if(verbose % 2) %hull() {
    translate([-10+2+1.2/2]) square([1.2,10.6],center=true);
    translate([-5,0]) square([2,4],center=true);
  }

}


module ext20profile(kerf=0,verbose=0) {
w=20;
w2f = w/2 - 0.6*abs(kerf);  // offset to center of corner stress relief loop
rc = (abs(kerf) < 0.1) ? 0.2 : 2*abs(kerf);  // radius of corner releif loop
ro=1;
$fn=24;
  difference() {
    union() {
      square([w,w],center=true);
      if (kerf > 0) // extra clearance around corners
        for(i=[-1,1]) for(j=[-1,1]) // extra clearance around corners
          translate([w2f*i,w2f*j,0]) circle(r=rc,$fn=8);
    }

    for (a=[0:90:355]) {
       rotate([0,0,a])
          slotV20profile();
    }
    if (floor(verbose/2) % 2) circle(r=2);
  }
}
