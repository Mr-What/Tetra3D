// cut-out model to fit 20mm extrusion

ext20(10,0.12);
%translate([0,0,-.1]) ext20(30.2,0);
translate([0,0,20])ext20(10,-0.12);

module ext20(len,fuzz=0,verbose=0) {
  if (fuzz == 0)
    linear_extrude(len) ext20profile();
  else if (fuzz > 0)
    linear_extrude(len) minkowski() {
      ext20profile(fuzz,1.5*fuzz);
      circle(r=fuzz/2,$fn=12);
    }
  else linear_extrude(len) difference() {
    square([21,21],center=true);
    minkowski() {
      difference() {
        square([21,21],center=true);
        ext20profile(fuzz,-1.5*fuzz);
      }
      circle(r=-fuzz/2,$fn=12);
    }
  }
}


// these are used (almost) exclusively for cutting out
//    hi-fi when fuzz=0, for cut-outs otherwise
//    crr -- corner relief radius, for cutouts
module ext20profile(fuzz=0,crr=0.4) {
w = 20;
cr = .3;  // radius of outside corner, actual 0.3mm
wall=2;  // outer wall, 2mm
slot=6;  // slot width
innerSquare=8;
innerBoreRadius = 3.55/2;


  if (fuzz==0) { // high-fidelity model
    difference() {
      union() {
        difference() {
          hull() for(x=[-1,1]) for(y=[-1,1])
            translate([x*(w/2-cr),y*(w/2-cr)])
              circle(r=cr,$fn=36);

          square([w-2*wall,w-2*wall],center=true);
          square([w+1,slot],center=true);
          square([slot,w+1],center=true);
        }

        square([innerSquare,innerSquare],center=true);
        for (a=[-45,45]) rotate(a)
          square([(w-wall)*1.41,1.4],center=true);
      }
      circle(r=innerBoreRadius,$fn=32);
    }
  } else {  // lower-fidelity for cutouts
        
    union() {
      difference() {
        square([w,w],center=true);

        for (a=[0:90:355]) rotate(a)
          hull() {
            translate([w/2,0]) square([.5,slot],center=true);
            for(y=[-1,1])
              translate([innerSquare/2+slot/2+1.9,y*(slot/2-1)])
                circle(0.7,$fn=36);
          }
      }
    //square([innerSquare,innerSquare],center=true);

      if(fuzz != 0) { // add extra corner relief for cutouts
        for (a=[0:90:355]) rotate(a) {
          translate([w/2-crr*.6,w/2-crr*.6])
            circle(r=crr,$fn=11);

          for (y=[-1,1])
            translate([w/2-crr*.7,y*(slot/2+crr*0.8)])
              circle(r=crr,$fn=11);
        }
      }
    
    }
  }
}
