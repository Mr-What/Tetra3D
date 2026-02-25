
//----------------------------------------------------------vertex

module bevilHole(nf=48) rotate_extrude($fn=nf) bevilProfile();
module bevilThroughHole(r=3,h=10) union() {
  mirror([0,0,1])
    translate([0,0,-h/2]) scale(r,r,h) bevilHole();
    translate([0,0,-h/2]) scale(r,r,h) bevilHole();
  cylinder(r=r,$fn=48,center=true,h=h+1);
}

module roundedTriHex(dy,dx,rc) hull() 
  for(a=[0:120:355]) rotate(a)
    for(x=[-1,1]) translate([x*dx,dy]) circle(rc,$fn=36);

module roundedTri(dx,rc) hull() 
  for(a=[30:120:355]) rotate(a)
    translate([dx,0]) circle(rc,$fn=36);

//%scale(1.02) nema17();
//nema17MountHoles();

// hole for setting up an 8mm M3 screw to attach to a 1515 extrusion
module M3railHole() {
nutRad = 5.46/2/cos(30);
  M3screwHole(8);
  translate([0,0,-8.8]) rotate([0,0,30])
    cylinder(r1=nutRad+.2,r2=nutRad,h=4,$fn=6);
}

module M3screwHole(holeDepth=10,sinkHeight=4,fuzz=0.05) {
  translate([0,0,-holeDepth]) cylinder(r=2.96/2+fuzz,h=holeDepth+1,$fn=16);
  cylinder(r1=5.38/2+fuzz,r2=5.38/2+sinkHeight*fuzz/2,h=sinkHeight,$fn=20);
}

module nema17MountHoles() {
  // make central more superset of shaft
  cylinder(r=11+1, h=2*9+35, $fn=48,center=true);
  //#cylinder(r=2.5+.2, h=25, $fn=36);  // shaft

  for (a = [0:90:359]) {
    rotate([0, 0, a]) translate([15.5, 15.5, 0])
      cylinder(r=2.94/2+.1, h=20, $fn=11,center=true);
  }
}


m5rad = 4.92/2;//4.88/2;
m5_head_radius = 8.62/2;//8.5/2;  // 5mm head height, uses 4mm hex drive

module M5boltHole(fuzz=0.1,gap=3) {
    cylinder(r=m5rad+fuzz,h=20,$fn=15);
    translate([0,0,-25])
       cylinder(r2=m5_head_radius,r1=m5_head_radius+1,h=25,$fn=24);

    // extra clearance for extrusion nut
    %translate([0,0,8.8]) cube([10,16,4],center=true);
    %translate([0,0,6  ]) cylinder(r=3.5+.2,h=4,$fn=17);

    // clear out area for 20mm extrusion nut
    #translate([0,0,3+gap]) cube([11,11,6],center=true);

}

// using slider t-nut on 20mm extrusion
// gap from bottom of sockethead to surface of extrusion
module M3rail20hole(gap=3,fuzz=0.1) {
  // slot is 6mm deep.  4mm below 2mm thick extrusion wall
  translate([0,0, -4]) cylinder(r=2.96/2+fuzz,h=5+gap,$fn=24);
  translate([0,0,gap]) cylinder(r1=5.38/2+fuzz,r2=3.2,h=20,$fn=24);

  // leave 0.5mm space to surf of extrusion.  Slider T nuts look like
  // about 1.5mm above bottom of slot wall.  Less??
  // slider is 10mm long.  6mm wide at slot, but wider farther down.
  // just call width also about 10mm.  leave some slop... 1mm...
  translate([0,0,-3.5+.2]) cube([11,11,6],center=true);
}

// using slider t-nut on 20mm extrusion
// gap from bottom of sockethead to surface of extrusion
module M5rail20hole(gap=3,fuzz=0.1) {
  // slot is 6mm deep from surf to bottom of slot.
  // surface wall is 2mm thick
  translate([0,0, -4]) cylinder(r=m5rad+fuzz,h=5+gap,$fn=24);

  // make cap countersink VERY long, so allow wrench access
  translate([0,0,gap]) cylinder(r1=m5_head_radius+fuzz,
         r2=m5_head_radius+1,h=25,$fn=24);

  // sliding t-nut is 4.5mm thick, total.
  // looks like about 1.5mm into slot... 0.5mm from surface
  // leave .3mm space to surf of extrusion.
  // slider t-nuts seem to go up to about 0.5mm from surface
  // slider is 10mm long.  6mm wide at slot, but wider farther down.
  // just call width also about 10mm.  leave some slop... 1mm...
  translate([0,0,-3.3]) cube([11,11,6],center=true);
}

module bevilProfile() polygon( points = [
[2,-0.05],
 [1.826352  , 0.015192],
  [ 1.741181 ,  0.034074],
  [ 1.657980 ,  0.060307],
  [ 1.577382 ,  0.093692],
  [ 1.500000 ,  0.133975],
  [ 1.426424 ,  0.180848],
  [ 1.357212 ,  0.233956],
  [ 1.292893 ,  0.292893],
  [ 1.233956 ,  0.357212],
  [ 1.180848 ,  0.426424],
  [ 1.133975 ,  0.500000],
  [ 1.093692 ,  0.577382],
  [ 1.060307 ,  0.657980],
  [ 1.034074 ,  0.741181],
  [ 1.015192 ,  0.826352],
[0.96,1.1],[.5,1.1],[.5,-0.05],[0.96,-0.05]]);
