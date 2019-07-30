// cut-out model to fit 20mm extrusion

//ext20profile(.2);
ext20(50,0.2);

module ext20(len,fuzz=0,verbose=0) {
  if (fuzz == 0)
    linear_extrude(len) ext20profile();
  else if (fuzz > 0)
    linear_extrude(len) minkowski() {
      ext20profile(fuzz);
      circle(r=fuzz/2,$fn=12);
    }
  else linear_extrude(len) difference() {
    square([21,21],center=true);
    minkowski() {
      difference() {
        square([21,21],center=true);
        ext20profile(fuzz);
      }
      circle(r=-kerf/2,$fn=12);
    }
  }
}


// these are used (almost) exclusively for cutting out
module ext20profile(fuzz=0) {
w = 20;
cr = .3;  // radius of outside corner, actual 0.3mm
wall=2;  // outer wall, 2mm
slot=6;  // slot width
innerSquare=8;
innerBoreRadius = 3.55/2;

  // don't bother beveling corner.
  // these are (almost?) always for cut-outs.
  // we will add extra corner relief anyway
  //hull() for(x=[-1,1]) for(y=[-1,1])
  //  translate([x*(w/2-cr),y*(w/2-cr)])
  //    circle(r=cr,$fn=36);

  union() {
    difference() {
      square([w,w],center=true);

      square([w+1,slot],center=true);
      square([slot,w+1],center=true);
    }
    square([innerSquare,innerSquare],center=true);

    if(fuzz>0)  // add extra corner relief for cutouts
      for(x=[-1,1]) for(y=[-1,1])
        translate([x*(w/2-fuzz*.2),y*(w/2-fuzz*.2)])
          circle(r=fuzz*.6,$fn=11);
    
  }
}

/*
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
*/