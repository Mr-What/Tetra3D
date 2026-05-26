// ===== Global parameters =====
effector_d      = 80;      // effector outer diameter
arm_pitch_deg   = 120;     // 3 arms at 120°
arm_radius      = 35;      // distance from center to arm joint centers

// Rail parameters (MGN7)
rail_len        = 50;      // MGN7 rail length (short)
rail_offset_z   = -10;     // rail mounting Z relative to effector top
rail_pitch      = 7;       // MGN7 rail width nominal
rail_hole_pitch = 15;      // hole spacing along rail (approx / adjust to real)
rail_mount_th   = 4;       // thickness of plastic under rail

// Hotend parameters
hotend_offset_z = -30;     // nozzle tip below effector plane
hotend_mount_radius = 12;  // radius of screw circle for V6/Rapido clamp
nozzle_xy_offset = [0,0];  // keep nozzle at effector center

// Tap-like motion
probe_travel    = 1.5;     // total Z travel of floating hotend
probe_force_g   = 250;     // target probe force (grams), for spring/magnet sizing

// Magnets
//mag_d           = 6;       // magnet diameter
//mag_h           = 3;       // magnet thickness
//mag_radius      = 18;      // radial distance of magnets from center

// Optical sensor (Voron Tap style)
opt_slot_width  = 2.0;     // beam slot width
opt_slot_height = 8.0;     // vertical opening
opt_offset_r    = 20;      // radial position of sensor
opt_offset_z    = -5;      // Z position of sensor slot center

// Effector thicknesses
effector_th     = 4;       // main plate thickness
boss_th         = 4;       // extra boss thickness for mounting features
module effector_plate() {
    difference() {
        // main disc
        cylinder(h = effector_th, d = effector_d, center = false);

        // arm joint cutouts (placeholder)
        for (i = [0:2]) {
            rotate([0,0,i*arm_pitch_deg])
                translate([arm_radius,0,0])
                    cylinder(h = effector_th+0.1, d = 8, center = false);
        }

        // central clearance for hotend
        translate([0,0,-0.1])
            cylinder(h = effector_th+0.2, d = 30, center = false);
    }
}

// Rail mounting bosses (underside)
module rail_mount() {
    // Mount rail along +Y axis (you can rotate as needed)
    translate([0,0, -rail_mount_th])
    difference() {
        // rectangular boss under rail
        translate([-rail_pitch, -rail_len/2, 0])
            cube([2*rail_pitch, rail_len, rail_mount_th], center=false);

        // clearance for rail body (optional)
        translate([-rail_pitch/2, -rail_len/2, -0.1])
            cube([rail_pitch, rail_len, rail_mount_th+0.2], center=false);

        // screw holes along rail
        for (y = [-rail_len/2 + rail_hole_pitch/2 : rail_hole_pitch : rail_len/2 - rail_hole_pitch/2]) {
            translate([0, y, -1])
                cylinder(h = rail_mount_th+2, d = 3, center=false);
        }
    }
}

/*
// Magnet pockets on effector (fixed side)
module fixed_magnets() {
    for (angle = [0, 120, 240]) {
        rotate([0,0,angle])
            translate([mag_radius,0,effector_th - mag_h])
                cylinder(h = mag_h, d = mag_d, center=false);
    }
}
*/

// Sensor PCB placeholder + slot
module sensor_mount() {
    // simple block representing PCB
    translate([opt_offset_r, 0, effector_th])
        cube([16, 10, 1.6], center=true);

    // optical slot cut in front of PCB
    difference() {
        // support boss
        translate([opt_offset_r, 0, 0])
            cube([10, 6, effector_th], center=true);

        // slot for flag
        translate([opt_offset_r, 0, opt_offset_z - opt_slot_height/2])
            cube([opt_slot_width, 4, opt_slot_height], center=false);
    }
}

// Combine effector components
module effector_assembly() {
    union() {
        effector_plate();
        rail_mount();
        sensor_mount();
        // Magnet pockets would be cut or unioned depending on your approach
    }
}
// Placeholder for MGN7 carriage mount
module mgn7_carriage_mount() {
    // simple block to bolt carriage to moving plate
    // adjust hole spacing to your actual carriage
    translate([-10, -8, 0])
        cube([20, 16, 4], center=false);
    // carriage holes (example)
    for (p = [[-7, -5], [7, -5], [-7,5], [7,5]]) {
        translate([p[0], p[1], -1])
            cylinder(h = 6, d = 3, center=false);
    }
}

// Moving plate around hotend
module hotend_carrier_plate() {
    difference() {
        // circular plate
        cylinder(h = 4, d = 40, center=false);

        // hotend central clearance
        translate([0,0,-0.1])
            cylinder(h = 4.2, d = 22, center=false);

        // V6/Rapido bolt circle (M3)
        for (angle = [0:90:270]) {
            rotate([0,0,angle])
                translate([hotend_mount_radius,0,-1])
                    cylinder(h = 6, d = 3, center=false);
        }
    }
}

// Moving magnets
module moving_magnets() {
    for (angle = [0, 120, 240]) {
        rotate([0,0,angle])
            translate([mag_radius,0,4])  // top side of moving plate
                cylinder(h = mag_h, d = mag_d, center=false);
    }
}

// Optical flag
module optical_flag() {
    // Flag rises up from moving plate into sensor slot when probed
    translate([opt_offset_r, 0, 4])  // base on moving plate top
        cube([opt_slot_width - 0.2, 3, probe_travel + 2], center=false);
}

/*
// Combine moving parts
module moving_hotend_assembly() {
    union() {
        translate([0,0,effector_th + probe_travel]) {
            hotend_carrier_plate();
            mgn7_carriage_mount();
            moving_magnets();
            optical_flag();
        }
    }
}
*/

//spring_radius = 18;
//spring_d      = 5;
//spring_h      = 8;
//
//module spring_pockets_fixed() {
//    for (angle = [0,120,240]) {
//        rotate([0,0,angle])
//            translate([spring_radius,0,effector_th - spring_h])
//                cylinder(h = spring_h, d = spring_d, center=false);
//    }
//}
//
//module spring_pockets_moving() {
//    for (angle = [0,120,240]) {
//        rotate([0,0,angle])
//            translate([spring_radius,0,4])  // top of moving plate
//                cylinder(h = spring_h, d = spring_d, center=false);
//    }
//}

// Assume the parameter and module definitions from before are present:
// - effector_assembly()
// - moving_hotend_assembly()
// - (plus any helper modules)

/*
module assembly(rest_position = true) {
    // Fixed effector at Z = 0
    effector_assembly();

    // Rail visual (simple block)
    // Or you can model it properly if you like
    translate([-rail_pitch/2, -rail_len/2, effector_th + rail_offset_z])
        color("silver")
        cube([rail_pitch, rail_len, 8], center=false);

    // Moving hotend carrier:
    // at rest: nozzle at nominal Z
    // probed: carrier pushed up by probe_travel
    z_shift = rest_position ? 0 : -probe_travel;

    translate([0,0, z_shift])
        moving_hotend_assembly();
}

// Quick views
assembly(true);   // show at rest
//assembly(false); // uncomment to see probed position
*/

/*
mag_d       = 10;   // your magnets
mag_h       = 2.6;
mag_radius  = 18;
mag_count   = 2;    // start with 1–2 pairs, not 3

module fixed_magnets() {
    for (i = [0:mag_count-1]) {
        angle = i * 360 / mag_count;
        rotate([0,0,angle])
            translate([mag_radius,0,effector_th - mag_h])
                cylinder(h = mag_h, d = mag_d, center=false);
    }
}

module moving_magnets() {
    for (i = [0:mag_count-1]) {
        angle = i * 360 / mag_count;
        rotate([0,0,angle])
            translate([mag_radius,0,4])   // top of moving plate
                cylinder(h = mag_h, d = mag_d, center=false);
    }
}
*/

// Magnet parameters
mag_d        = 6;      // recommended new magnets: 6 mm
mag_h        = 3;      // thickness
mag_pairs    = 3;      // three pairs for symmetry
mag_radius   = 18;     // radial position
mag_rest_gap = 0.7;    // air gap at rest between faces (mm)

// Effector magnet pockets (fixed)
module fixed_magnets() {
    for (i = [0:mag_pairs-1]) {
        angle = i * 360 / mag_pairs;
        rotate([0,0,angle])
            translate([mag_radius, 0, effector_th - mag_h])
                cylinder(h = mag_h, d = mag_d, center=false);
    }
}

// Moving magnet pockets (moving plate)
module moving_magnets() {
    for (i = [0:mag_pairs-1]) {
        angle = i * 360 / mag_pairs;
        // Faces are separated by mag_rest_gap at rest:
        translate([mag_radius, 0, effector_th + mag_rest_gap])
            cylinder(h = mag_h, d = mag_d, center=false);
    }
}

// Update moving assembly to include magnets
module moving_hotend_assembly() {
    union() {
        translate([0,0, effector_th + mag_rest_gap]) {
            hotend_carrier_plate();
            mgn7_carriage_mount();
            moving_magnets();
            #optical_flag();
        }
        // nozzle/hotend model omitted for clarity
    }
}

// Top-level assembly: rest vs probed
module assembly(rest_position = true) {
    effector_assembly();

    // visual rail approximation
    translate([-rail_pitch/2, -rail_len/2, effector_th + rail_offset_z])
        color("silver")
        cube([rail_pitch, rail_len, 8], center=false);

    z_shift = rest_position ? 0 : -probe_travel;
    translate([0,0,z_shift])
        moving_hotend_assembly();
}

// Render
if ($t < 0.5)
    assembly(true);    // at rest
else
    assembly(false); // probed
