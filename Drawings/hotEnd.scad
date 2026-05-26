// somewhat large hot-end I happen to have
RES=30;  // higher for production render

Hbody = 50;  // height of aluminum base
Dbody = 25;  // diameter at outside of cooling fins
Gblock = 3.7; // gap from body to top of block
IDmount = 12; // inner diameter of mount groove
ODmount = 16; // outer diameter of mount groove
WtopFlange = 4;
Wmount = 5.3;
WbotFlange = 3;

Hblock=12.1; // height of heat block
Wblock = 16; // width of heat block, heater parallel to W axis
Dblock = 16; // nozzle NOT centered in +-D direction

DsocketHeadM3 = 5.4;
HsocketHeadM3 = 3;

%hotEnd();

%translate([0,20,43.35])
rotate([0,90,-90])  // let face of carriage be y=0
railMGN7H();

//difference() { union() {
translate([0,0,Hbody-WtopFlange-Wmount/2])
%retentionTab();

translate([0,0,Hbody-WtopFlange-Wmount/2])
hotEndMount();
//} translate([0,0,53]) cube([80,80,20],center=true);}

WmountBrace=14;
module hotEndMount(withBrace=true) difference() {
    union() {
        translate([0,9,0]) rotate([90,0,0]) hull() pairX(WmountBrace) 
            cylinder(r=6.5,h=1,$fn=RES);
        translate([0,10,0]) rotate([90,0,0]) hull() pairX(WmountBrace) 
            cylinder(r=6.5,h=19,$fn=RES);
        translate([0,20,0]) hull() {
            pairX(6) pairZ(13) rotate([90,0,0])
                cylinder(r=2,h=1,$fn=RES/2);
            translate([0,-11,0]) pairX(WmountBrace) rotate([90,0,0])
                cylinder(r=6.5,h=1,$fn=RES);
        }
        
        // cut away from this sheath over the hot-end as little
        // as possible, for strength
        if (withBrace) braceSheath();
    }
    
    translate([0,1,0]) retentionTabBase(.1);
    hull() {
        cylinder(d=IDmount+.2,h=Wmount+.2,center=true,$fn=RES);
        translate([0,-20,0]) cube([IDmount+.2,1,Wmount+.2],center=true);
    }

    cylinder(d=IDmount,h=20,center=true,$fn=RES);
    pairZ(Wmount/2-.1 +4/2) hull() {
        cylinder(d=ODmount+.2,h=4,center=true,$fn=RES);
        translate([0,-10,0]) cube([ODmount+.2,1,4],center=true);
    }

    // I think the taps on MGN7 carriage are only about 3mm deep
    //   plan on M2 screw to go only 2mm below face of carriage
    if(withBrace)
    translate([0,20.1,0]) rotate([90,0,0]) pairX(6) pairY(6.5) {
        cylinder(r=1.05,h=20,$fn=RES/3);  // M2 socket head? 8mm
        translate([0,0,8-2]) cylinder(d1=3.8,d2=4.2,h=13.5,$fn=RES/2);
    }
    
    translate([0,18,0]) pairX(13) rotate([90,0,0]) cylinder(r=1.6,h=14,$fn=RES/2);
    translate([0,19,0]) pairX(13) rotate([90,0,0])  // M3 nut hole 
       cylinder(d1=6.8, d2=5.5/cos(30),h=10,$fn=6);
    
    translate([-25,20,-51]) cube([50,16,80]);    // don't overlap carriage
    
    translate([0,0,-11]) {   // clearance from hot end
        translate([0,0,-34])
        cylinder(d=Dbody+6, h=34.1,$fn=RES);
        cylinder(d1=Dbody+6, d2=Dbody-3,h=4,$fn=RES);
    
        // clearance from block
        translate([0,-3,-40]) cube([26,24,16],center=true);
    }
}

module braceSheath() difference() {
    hull() {
        cube([36,18,3.5],center=true);

        difference() {
            translate([0,0,-40])
                cylinder(r=24, h=30, $fn=RES*1.5);

            translate([-25,-28,-51]) cube([50,50,18]);
            translate([-25,20,-60]) cube([50,20,80]);

            // don't interfere with blowers
            hull() {
                translate([-25,-29,-5.4])   cube([50,20,1]);
                translate([-25,-28,-40]) cube([50,50,1]);
                //#translate([0,6,-25]) rotate([0,90,0])
                //    cylinder(r=6,h=60,center=true,$fn=RES/2);
            }
        }            
        
    }

    translate([0,0,-51]) cylinder(d=Dbody+12, h=44.55, $fn=RES*1.5);

    
}

module retentionTabBase(fuzz=0) {
    difference() {
        union() {
            hull() {
                translate([0,-5.5,0])
                    cube([ODmount+fuzz-.1,ODmount/2+2,Wmount+4-.2],center=true);
                translate([0,-15,0]) cube([ODmount-1,1,Wmount+2],center=true);
            }
            translate([0,-5.5,0])
            cube([ODmount+6,ODmount/2+2,Wmount-.2],center=true);
            rotate([90,0,0]) pairX(13) hull() {
                sphere(r=4+fuzz,$fn=RES);
                translate([0,0,8+2]) cylinder(r=4+fuzz,h=1,$fn=RES);
            }
            rotate([90,0,0]) hull() pairX(13)
                translate([0,0,8.5+2]) cylinder(r=4+fuzz,h=6,$fn=RES);
            
        }
        
        cylinder(d=IDmount-fuzz,h=Wmount+1,center=true,$fn=RES);
        //*pairX(13) rotate([90,0,0]) {
        //    cylinder(r=1.5,h=40,center=true,$fn=RES/2);
        //    translate([0,0,15]) cylinder(d1=DsocketHeadM3, d2=DsocketHeadM3+.2,
        //        h=HsocketHeadM3+1, $fn=RES/2);
        //}
        pairZ(Wmount/2+1+2*fuzz) cylinder(d=ODmount+2*fuzz,h=2,center=true,$fn=RES);
        
        //%cylinder(d=ODmount,h=1,center=true,$fn=RES);
    }
}

//just add screw holes, for re-use in hotEndMount()
module retentionTab(fuzz=0) difference() { retentionTabBase(fuzz);
    pairX(13) rotate([90,0,0]) {
            cylinder(r=1.5,h=40,center=true,$fn=RES/2);
            translate([0,0,13]) cylinder(d1=DsocketHeadM3, d2=DsocketHeadM3+.2,
                h=HsocketHeadM3+1, $fn=RES/2);
    }
}

module railMGN7H(len=50,pos=0) {
    // H=8 H1=1.5
    // total assembly thickness H=8
    // bot of rail to bot of carriage, H1=1.5
    // width of rail, Wr=7
    // height of rail, HR=4.8
    // width of carriage W=17
    // bolts on center, perp to motion B=12
    // length of carriage, L=30.8
    // bold spacing, parallel to motion, C=13
    // dist bet. rail holes on center , P=15
    // hole diam d=2.4
    // head diam D=4.2
    // head depth, h=2.3
    
    //put face of carriage at Y=0
    color("silver")
    translate([0,0,-8+2.4]) rail7(len);
    translate([-pos,0,0]) MGN7H();
}
module MGN7H() translate([0,0,(1.5-8)/2])
    difference() { cube([30.8,17,8-1.5],center=true);
        #pairX(13/2) pairY(6)
            cylinder(r=1,h=5,$fn=16);
    }


module rail7(len=50) difference() { cube([len,7,4.8],center=true);
    for(k=[0:15:len/2]) pairX(k) {
        cylinder(d=2.4,h=22,$fn=16,center=true);
        translate([0,0,(4.8/2)-2.3]) cylinder(d=4.2,h=3,$fn=16);
    }
}

module pairX(d) for(a=[-d,d]) translate([a,0,0]) children();
module pairY(d) for(a=[-d,d]) translate([0,a,0]) children();
module pairZ(d) for(a=[-d,d]) translate([0,0,a]) children();
    
module hotEnd() {
    hotBlock();
    cylinder(d=Dbody,h=32,$fn=36);  // cooler setion of body
    cylinder(d=IDmount,h=Hbody,$fn=24);
    translate([0,0,38]) {  // mount flanges
        translate([0,0,WbotFlange+Wmount])
            cylinder(d=ODmount,h=WtopFlange,$fn=24);
            cylinder(d=ODmount,h=WbotFlange,$fn=24);
    }
}
    
module hotBlock() { // nozzle and mount on Z axis
    translate([0,-3,-Hblock/2-Gblock])  // offset from center of nozzle
        cube([Wblock, Dblock,Hblock],center=true);
    translate([0,0,-Hblock-5-Gblock]) cylinder(h=5,r2=3,r1=.3,$fn=6);  // nozzle
    translate([0,-6,-Gblock-6/2-2]) rotate([0,90,0])
        cylinder(d=6,h=Wblock+3,center=true, $fn=24); // heater
}