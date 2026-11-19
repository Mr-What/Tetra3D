// If you have a very well calibrated 3D printer, likely cartesian,
//   this can be a practical calibration plate for a delta
RES=24;

// ------------- rectangular
//R=81;  // radius (to corner) of plate
//DX=20; // spacing between fiducials
//R2=13;
//%translate([0,0, 8]) import("calPlate.stl");
//%circle(r=84,$fn=6); // rect

// ------------  smaller
//R=63;  // radius (to corner) of plate
//DX=20; // spacing between fiducials
//R2=8;
//are dbst%translate([0,0,11]) import("calPlate70.stl");
//%circle(r=68,$fn=6); // rect

// ------------------ small hex
R=70;  // radius (to corner) of plate
DX=20; // spacing between dimple centers
ND=36; // 36+center dimple hex spiral pattern
%circle(r=78-2,$fn=6); //  was 69 for R=65
%import("tetraEnv238.stl");
include <hexGrid.scad>

difference() {
    union() { plateBase(R);
         //#annotate("+Y",-8,R);
         //#annotate("-Y", 0,-R);
         //#annotate("+X", R, 0);//, rot=-90);
         //#annotate("-X",-R, 0);//, rot=90);
         //#annotate("A",-R+7,-0.5*R);
         //#annotate("B", R-7,-0.5*R);
         //#annotate("C",4,R,8);
        
         translate([0,R*0.83,5]) sphere(2,$fn=RES);
         //pairX(R*0.45) translate([0,R*0.8,6]) sphere(2,$fn=RES);
    }
    
    translate([0,0,-2]) cube([200,200,4],center=true);  // flatten bottom

    #for(k=[0:ND]) translate([DX*hexGrid[k][0],DX*hexGrid[k][1],4]) tool();
    //#rectGrid(DX,R2) tool();
    
    //translate([0,0,-1]) cube(100);
    %translate([0,0,9.17]) sphere(d=10,$fn=RES);
}

module rectGrid(dx=DX,r2) {
    m = floor(r2);
    for(y=[-m:m]) for(x=[-m:m]) if (x*x+y*y<r2)
        translate([x*dx,y*dx,4]) children();
}

module annotate(txt,x,y,siz=6,rot=0) translate([x,y,5]) linear_extrude(1.5)
    rotate(rot) text(txt,size=siz,halign="center", valign="center");

//120 deg, D=10, expensive spot bit?
//module tool() cylinder(d1=.01,d2=10,h=10*tan(30),$fn=RES);

//150 deg, D=22, lower priced V-groove router bit
//  I got the 16mm
module tool() cylinder(d1=.01,d2=16,h=8*tan(15),$fn=RES*2);


module plateBase(r=R) hull() for(a=[0:60:355]) rotate(a) {
    translate([r,0,2.5]) sphere(3,$fn=RES);
    translate([r,0,4  ]) sphere(2,$fn=RES);
}

//%circle(r=R+DX/2);

*difference() {
    translate([0,0,1.5]) cube([2*R+DX,2*R+DX,3],center=true);
    
    for(y=FP) for(x=FP) if((x*x+y*y)<=R2)
        translate([x,y,3-DT-.1]) bit();
    
    //cube(100);
}
    
module bit(d=DF) hull() {
    cylinder(d1=.01, d2=d, h=DT);
    translate([0,0,10]) cylinder(d=d,h=1);
}

module pairX(d) for(x=[-d,d]) translate([x,0,0]) children();
