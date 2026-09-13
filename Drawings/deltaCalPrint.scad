// calibration print.  Take measurements
HEX_RAD = 5/cos(30);
PATTERN_RAD = 60;//80;
HEX_HEIGHT = 3;

testHex(0,0,"Z");  // zero, origin

// note tower names as labels next
for(a=[0:2]) testHex(cos(a*120-150)*PATTERN_RAD,sin(a*120-150)*PATTERN_RAD, chr(ord("A")+a));

// sides
for(a=[0:2]) testHex(cos(a*120+30)*PATTERN_RAD,sin(a*120+30)*PATTERN_RAD, chr(ord("a")+a));

CR=1.5;  // corner radius for hexagon
X0 = CR * cos(60) * sin(30) / cos(30);  // intermediate value
DX = HEX_RAD - X0 - CR * cos(30);
module testHex(x,y,txt,rot=0) translate([x,y]) union() { //difference() {
    rotate(rot) hull() { // bevil to avoid top layer "ears", hard to measure
        %cylinder(r=HEX_RAD,h=HEX_HEIGHT-.5,$fn=6);
        for (a=[0:60:355]) rotate(a) translate([DX,0])
            cylinder(r=1.5,h=HEX_HEIGHT-.6,$fn=60);
        translate([0,0,HEX_HEIGHT-.1]) cylinder(r=HEX_RAD-.8, h=.1, $fn=6);
    }
    translate([0,0,HEX_HEIGHT-1]) linear_extrude(1.5)
            text(txt,size=HEX_RAD-1,halign="center",valign="center");
}