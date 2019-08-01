// Model for Misumi HFS3-1515 extrusion

ext15(10,0.12);
%translate([0,0,-.1]) ext15(30.2,0);
translate([0,0,20])ext15(10,-0.12);

//%translate([0,0,.5]) ext15profile();
//ext15profile(-0.1);

ew=15;  // extrusion width

module ext15(len,fuzz=0) {
  if (fuzz == 0)
    linear_extrude(len) ext15profile();
  else if (fuzz > 0)
    linear_extrude(len) minkowski() {
      ext15profile(fuzz,1.5*fuzz);
      circle(r=fuzz/2,$fn=12);
    }
  else linear_extrude(len) difference() {
    square([ew+1,ew+1],center=true);
    minkowski() {
      difference() {
        square([ew+2,ew+2],center=true);
        ext15profile(fuzz,-1.5*fuzz);
      }
      circle(r=-fuzz/2,$fn=12);
    }
  }
}


// these are used (almost) exclusively for cutting out
//    hi-fi when fuzz=0, for cut-outs otherwise
//    crr -- corner relief radius, for cutouts
// fuzz>0 for 3d-printing slop, where we want hole to be a little oversized for overextrusion
// fuzz<0 for laser-cut profile, where we want hole undersized for kerf
module ext15profile(fuzz=0,crr=0.2) {
rc=1;  // radius of outer corner
sw=3.4; // width of slot
swi=5.7;  // width slot, inside
cbr=2.5/2;  // center bore radius
wt=1.1; // outide wall thickness
shi = 2.6;  // slot height, inner.  max nut height
sd = wt+shi+1;  // total slot depth, from surface

  if (fuzz==0) { // high-fidelity model
    difference() {
      hull() for(x=[-1,1]) for(y=[-1,1])
        translate([x*(ew/2-rc),y*(ew/2-rc)])
          circle(r=rc,$fn=36);

      circle(r=cbr,$fn=36);
      for(a=[0:90:355]) rotate(a) union() {
        translate([ew/2,0]) square([sd*2,sw],center=true);
        
        hull() {
          translate([ew/2-sd+1,0]) square([2,swi-2],center=true);
          translate([ew/2-wt-shi/2,0]) square([shi,swi],center=true);
        }
      }
    }

  } else {  // lower-fidelity for cutouts
        
    union() {
      difference() {
        //hull() for(x=[-1,1]) for(y=[-1,1])
        //translate([x*(ew/2-abs(fuzz*2)),y*(ew/2-abs(fuzz*2))])
        //  circle(r=abs(fuzz)*2,$fn=12);
        square([ew,ew],center=true);

        for (a=[0:90:355]) rotate(a)
          hull() {
            translate([ew/2,0]) square([.5,sw],center=true);
            for(y=[-1,1])  // tabs need to go deep to hold M3 nut cut-outs sometimes
              translate([ew/2-2,y*(sw/2-0.4)])
                circle(0.3,$fn=36);
          }
      }

      // add extra corner relief for cutouts
      for (a=[0:90:355]) rotate(a) {
        translate([ew/2-abs(fuzz),ew/2-abs(fuzz)])
            circle(r=abs(fuzz)*1.6,$fn=11);

          // relief at corner of slots
          //for (y=[-1,1])
          //  translate([w/2-crr*.7,y*(slot/2+crr*0.8)])
          //    circle(r=crr,$fn=11);
      }
    
    }
  }
}
