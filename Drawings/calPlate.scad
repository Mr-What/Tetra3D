// If you have a very well calibrated 3D printer, likely cartesian,
//   this can be a practical calibration plate for a delta
RES=24;

R=70;// max radius for cal point centers
DX=25; // spacing between fiducials
DF=10;  // diameter of fiducial

DT = (DF/2) * sin(90-67.5);  // depth of taper of 135 deg. jobber bit 
NX = floor(R/DX)+1;
R2 = R*R;
FP = [-NX*DX:DX:NX*DX];  // fiducial point locations
$fn=96;

difference() {
    union() { plateBase();
         #annotate("+Y",-36,64);
         #annotate("-Y", 36,-64);
         #annotate("C",36,62,8);
         #annotate("+X",73,-2, rot=-90);
         #annotate("-X",-73,-2, rot=90);
         #annotate("A",-53,-32);
         #annotate("B", 53,-32);
    }
    
    translate([0,0,-2]) cube([200,200,4],center=true);  // flatten bottom
    // seems like low-angle router bits typically go up to 120.
    // I have seen some as high as 150
    for(x=[-60:20:60]) for(y=[-60:20:60]) if(sqrt(x*x+y*y) < 71) {
        #translate([x,y,4]) tool();
        //echo(x,y);
    }
    
    //translate([0,0,-1]) cube(100);
    %translate([0,0,9.17]) sphere(d=10,$fn=RES);
}

module annotate(txt,x,y,siz=6,rot=0) translate([x,y,5]) linear_extrude(1.5)
    rotate(rot) text(txt,size=siz,halign="center", valign="center");

//120 deg, D=10, expensive spot bit?
//module tool() cylinder(d1=.01,d2=10,h=10*tan(30),$fn=RES);

//150 deg, D=22, lower priced V-groove router bit
module tool() cylinder(d1=.01,d2=22,h=11*tan(15),$fn=RES*2);


module plateBase() hull() for(a=[0:60:355]) rotate(a) {
    translate([R+11,0,2.5]) sphere(3,$fn=RES);
    translate([R+10,0,4  ]) sphere(2,$fn=RES);
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
