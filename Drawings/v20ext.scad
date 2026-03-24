// use drawing from OpenBuilds for 2020 v-slot extrusion

//ext20v(10,0);

module v20ext(len, r=0) {
    if (r == 0) linear_extrude(len) v20profile();
    else linear_extrude(len) offset(r) v20profile();
}

module v20profile() intersection() { square(20,center=true);
    translate([-26.48,-22.57]) import("Vslot2020.dxf");
}

