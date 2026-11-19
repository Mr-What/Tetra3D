// simple initial calibration plate for tetra
R=70;// max radius for cal point centers
DX=25; // spacing between fiducials
DF=10;  // diameter of fiducial

DT = (DF/2) * sin(90-67.5);  // depth of taper of 135 deg. jobber bit 
NX = floor(R/DX)+1;
R2 = R*R;
FP = [-NX*DX:DX:NX*DX];  // fiducial point locations
$fn=96;

//%circle(r=R+DX/2);

difference() {
    translate([0,0,1.5]) cube([2*R+DX,2*R+DX,3],center=true);
    
    for(y=FP) for(x=FP) if((x*x+y*y)<=R2)
        translate([x,y,3-DT-.1]) bit();
    
    //cube(100);
}
    
module bit(d=DF) hull() {
    cylinder(d1=.01, d2=d, h=DT);
    translate([0,0,10]) cylinder(d=d,h=1);
}
