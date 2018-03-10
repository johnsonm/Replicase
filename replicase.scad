// find an appropriate grill for the outside of the fan!

fan_diameter = 80;
fan_screw_d = 5;
fan_screw_off = 36;
shell = 2;

screw_d = 2.26; // diameter of holes for assembly screws
pcb_z = 1.6; // thickness of PCB

w = 111; // x interior dimension
d = 81; // y interior dimension
y_off = 14; // BB offset from inside of shell
io_off = 4; // power/usb offset from board edge
io_width = 36;
usb_off = 38; // USB port under board offset from board edge
usb_width = 14; // enough room to actually plug in a cable
usb_h = 6; // height of micro/mini usb cutout
s_h = 8; // height of standoffs above shell in z (bottom of pcb)
s_d = 6; // diameter of standoff column
c_h = 5; // height above standoff of standoff pcb clip

top_clip_offset = 10;
top_clip_len = 5;
top_h = 20;
molex_z = 15;
molex_d = 72;
molex_off = (d-molex_d)/2; // center molex slot
ctrl_w = 86;
ctrl_z = 10;
ctrl_off = 7;

hd = 3; // air holes
m_d = 5.2; // diameter of mounting holes in flange
flange = 10; // width of mounting flange

sandwich_h = 13; // height from bottom of beaglebone PCB to top of mounted replicape PCB (bottom of molex connectors)
in_h = s_h + sandwich_h;

e = 0.01; // offset to avoid coincident surfaces to improve preview
module standoff(x, y, z, r) {
    // standoff with screw hole (at origin) and integrated clip
    $fn = 30;
    s_r = s_d/2;
    translate([x, y, z]) rotate([0, 0, r]) {
        // body below clip
        difference() {
            hull() {
                cylinder(d=s_d, h=s_h);
                translate([s_r, -s_r, 0]) cube([s_r, s_d, s_h]);
            }
            cylinder(d=screw_d, h=s_h);
        }
        // clip arm beside pcb
        translate([s_r, -s_r, s_h]) cube([s_r, s_d, pcb_z]);
        // clip above pcb
        hull() {
            translate([s_r, -s_r, s_h+pcb_z])
                cube([s_r, s_d, c_h-pcb_z]);
            translate([s_r, -s_r, s_h+((c_h-pcb_z)/2)+pcb_z])
                rotate([-90, 0, 0])
                cylinder(d=s_r/2, h=s_d);
        }
    }
}
module fan_hole(x, y) {
    translate([x, y, -e]) {
        // fan area
        cylinder(d=fan_diameter, h=shell+2*e);
        // mounting screw holes
        for (n=[[-1, -1], [1, -1], [-1, 1], [1, 1]]) {
            translate([n[0]*fan_screw_off, n[1]*fan_screw_off, 0])
            cylinder(d=fan_screw_d, h=shell+2*e);
        }
    }
}
module hex_hole(x, y, z, r=0) {
    translate([x, y+shell+e, z]) rotate([90, 0, r])
        cylinder(r=hd, h=shell+2*e, $fn=6);
}
module ventilate(l, h) {
    // distribute extra space equally left-right and top-bottom
    xo = (l%(hd*1.5))/2;
    zo = (h%(hd*1.5))/2;
    for (z=[1.5*hd+zo:3*hd:h-(1.5*hd)]) {
        for (x=[1.5*hd+xo:3*hd:l-(1.5*hd)]) {
            hex_hole(x, 0, z);
        }
    }
    for (z=[3*hd+zo:3*hd:h-(1.5*hd)]) {
        for (x=[3*hd+xo:3*hd:l-(3*hd)]) {
            hex_hole(x, 0, z);
        }
    }
}
module bottom_flange(x0, y0, x1, y1) {
    // flange mm outside specified box
    // designed to mount to corner of 2020 extrusion
    // similarly to original X5S electronics
    $fn = 30;
    y_n_fl = 2.4;
    mounting_holes = [
        // long sides
        [-(x0+shell+flange/2), -(y0-flange)],
        [-(x0+shell+flange/2), y1-flange],
        [x1+shell+flange/2, -(y0-flange)],
        [x1+shell+flange/2, y1-flange],
        // short sides
        [x1-flange, y1+shell+flange/2],
        [-(x0-flange), y1+shell+flange/2],
        [x1-flange, -(y0+shell+flange/2)],
        [-(x0-flange), -(y0+shell+flange/2)],
    ];
    difference() {
        union() {
            hull() {
                for (loc=[
                    [-(x0+flange), -(y0+flange)],
                    [x1+flange, -(y0+flange)],
                    [x1+flange, y1+flange],
                    [-(x0+flange), y1+flange],
                ]) {
                    x = loc[0];
                    y = loc[1];
                    translate([x, y, 0])
                        cylinder(d=m_d, h=shell);
                }
            }
            for (loc=mounting_holes) {
                x = loc[0];
                y = loc[1];
                translate([x, y, 0]) cylinder(d=8, h=5);
            }
        }
        // screw holes
        union() {
            for (loc=mounting_holes) {
                x = loc[0];
                y = loc[1];
                translate([x, y, -e]) cylinder(d=m_d, h=5+(e*2));
            }
        }
    }
}
module ignorethis() {
    difference() {
        union() {
            translate([0, 0, 20.4]) import("replicape_case_-_bottom.stl");
            side_fill(x_off_p);
            mirror([1,0,0]) side_fill(x_off_n);
            bottom_flange();
        }
        union() {
            vents(x_off_p);
            end_vents(y_off_p);
            mirror([1,0,0]) vents(x_off_n);
            bbg_slots();
            end_power_cutout();
        }
    }
}
function inches(i) = i / 0.039370079;
module case_bottom() {
    difference() {
        union() {
            cube([w+shell*2, d+shell*2, shell+in_h]);
            bottom_flange(0, 0, w, d);
        }
        union() {
            // box inside
            translate([shell, shell, shell])
                cube([w, d, in_h+e]);
            // hex ventilation
            translate([shell+hd, 0, shell])
                ventilate(w-(2*hd), in_h);
            translate([shell+hd, d+shell, shell])
                ventilate(w-(2*hd), in_h);
            translate([w+shell*2, shell, shell]) rotate([0, 0, 90])
                ventilate(d, in_h);
            // BB ethernet/usb/power access
            translate([-e, shell+y_off+io_off, shell+s_h+pcb_z])
                cube([shell+2*e, io_width, e+in_h-(s_h+pcb_z)]);
            translate([-e, shell+y_off+usb_off, shell+s_h-usb_h])
                cube([shell+2*e, usb_width, usb_h]);
        }
    }
    // location of mounting holes from BB SRM
    standoff(inches(0.575), shell+y_off+inches(0.125), shell, 270);
    standoff(inches(0.575), shell+y_off+inches(2.025), shell, 90);
    standoff(inches(3.175), shell+y_off+inches(0.25), shell, -45);
    standoff(inches(3.175), shell+y_off+inches(1.9), shell, 45);
    // top case clips
    for (o=[
        [0, 0],
        [0, d],
        [w-top_clip_len, 0],
        [w-top_clip_len, d]]) {
        translate([shell+o[0], shell+o[1], shell+in_h-top_clip_offset])
            rotate([0, 90, 0])
            cylinder(r=shell, h=top_clip_len, $fn=30);
    }
};
module case_top() {
    // printed upside down
    difference() {
        cube([w+2*shell, d+2*shell, top_h+shell]);
        union() {
            translate([shell, shell, shell]) cube([w, d, top_h+e]);
            fan_hole(shell+w/2, shell+d/2);
            // molex power space
            translate([shell+w-e, molex_off, shell+top_h-molex_z])
                cube([shell+2*e, molex_d, molex_z+e]);
            // control/sensor cable space
            for (y=[0, d+shell]) {
                translate([ctrl_off, y-e, shell+top_h-ctrl_z])
                    cube([ctrl_w, shell+2*e, ctrl_z+e]);
            }
        }
    }
    for (o=[
            [shell, shell, shell, shell],
            [shell+w-top_clip_len, shell, shell, shell],
            [shell, d, -shell, 0],
            [shell+w-top_clip_len, d, -shell, 0],
        ]) {
        translate([o[0], o[1], 0]) {
            cube([top_clip_len, shell, shell+top_h]);
            translate([0, o[2], 0])
                cube([top_clip_len, shell, shell+top_h+top_clip_offset]);
            translate([0, o[3], top_h+top_clip_offset])
                rotate([0, 90, 0])
                cylinder(r=shell, h=top_clip_len, $fn=30);
        }
    }
}
case_bottom();
translate([0, d+flange+3*shell, 0])
    case_top();