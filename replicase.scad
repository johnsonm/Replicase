// find an appropriate grill for the outside of the fan!

// These parameters are generally meant to be modified
fan_diameter = 80;
fan_screw_d = 5;
fan_screw_off = 36;
screw_d = 2.26; // diameter of holes for assembly screws
flange = 10; // width of mounting flange
m_d = 5.2; // diameter of mounting holes in flange
clip_d = 0.5; // size of board retention clip; as much as 1 for PETG

// substantial modifications unlikely to work well
shell = 2;
pcb_z = 1.4; // thickness of PCB

// these are considered internal variables and are not well-constrained
w = 111; // x interior dimension
d = 81; // y interior dimension
bb_width = inches(2.15);
y_off = (d/2-bb_width/2); // BB edge offset from inside of shell
io_off = 3; // power/usb offset from board edge
io_width = 36;
usb_off = 39.5; // USB port under board offset from board edge
usb_width = 12; // enough room to actually plug in a cable
usb_h = 7; // height of micro/mini usb cutout
s_h = 8; // height of standoffs above shell in z (bottom of pcb)
s_d = 6; // diameter of standoff column
c_h = 5; // height above standoff of standoff pcb clip

top_clip_offset = 10;
top_clip_len = 5;
top_h = 20;
molex_z = 15;
molex_d = 72;
molex_off = d/2-molex_d/2; // center molex slot
ctrl_w = 86;
ctrl_z = 10;
ctrl_off = 7;

hd = 3; // air holes

sandwich_h = 12; // height from bottom of beaglebone PCB to top of mounted replicape PCB (bottom of molex connectors)
ethernet_z = 3; // relief for ethernet etc. above beaglebone PCB
in_h = s_h + pcb_z + sandwich_h; // total interior height of base
molex_h = s_h+sandwich_h; // total interior height of bottom of molex

e = 0.01; // offset to avoid coincident surfaces to improve preview
function inches(i) = i / 0.039370079;

module standoff(x, y, z, r) {
    // standoff with screw hole (at origin) and integrated clip
    $fn = 30;
    s_r = s_d/2;
    c_d = clip_d;
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
                cylinder(d=c_d, h=s_d);
        }
    }
}
module fan_hole(x, y) {
    translate([x, y, -e]) {
        // fan area
        cylinder(d=fan_diameter, h=shell+2*e, $fn=180);
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
module case_bottom() {
    difference() {
        union() {
            cube([w+shell*2, d+shell*2, shell+in_h]);
            bottom_flange(0, 0, w+shell*2, d+shell*2);
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
                ventilate(d, molex_h);
            // BB ethernet/usb/power access
            translate([-e, shell+y_off+io_off, shell+s_h+pcb_z])
                cube([shell+2*e, io_width, e+in_h-(s_h+pcb_z)]);
            // mini/micro USB
            translate([-e, shell+y_off+usb_off, shell+pcb_z+s_h-usb_h+(pcb_z/2)])
                cube([shell+2*e, usb_width, usb_h]);
            // molex connectors
            translate([shell+w-e, shell, shell+molex_h])
                cube([shell+2*e, d, in_h-(molex_h)+e]);
            // top case clip relief
            len=top_clip_len*1.1; // room for fit
            for (o=[
                [0, 0],
                [0, d],
                [w-len, 0],
                [w-len, d]]) {
                translate([shell+o[0], shell+o[1], shell+in_h-(top_clip_offset+shell/2)])
                    rotate([0, 90, 0])
                    cylinder(r=shell/2, h=len, $fn=30);
            }
        }
    }
    // location of mounting holes from BB SRM
    standoff(shell+inches(0.575), shell+y_off+inches(0.125), shell, 270);
    standoff(shell+inches(0.575), shell+y_off+inches(2.025), shell, 90);
    standoff(shell+inches(3.175), shell+y_off+inches(0.25), shell, -45);
    standoff(shell+inches(3.175), shell+y_off+inches(1.9), shell, 45);
};
module case_top() {
    // printed upside down
    difference() {
        cube([w+2*shell, d+2*shell, top_h+shell]);
        union() {
            translate([shell, shell, shell]) cube([w, d, top_h+e]);
            fan_hole(shell+w/2, shell+d/2);
            // ethernet relief (io_off and y_off upside down)
            translate([-e, shell+d-(io_off+y_off+io_width), shell+top_h-ethernet_z])
                cube([shell+2*e, io_width, ethernet_z+e]);
            // molex power space
            translate([shell+w-e, shell+molex_off, shell+top_h-molex_z])
                cube([shell+2*e, molex_d, molex_z+e]);
            // control/sensor cable space
            for (y=[0, d+shell]) {
                translate([ctrl_off, y-e, shell+top_h-ctrl_z])
                    cube([ctrl_w, shell+2*e, ctrl_z+e]);
            }
            // let some air out above usb/ethernet side
            translate([shell, shell*3, shell]) rotate([0, 0, 90])
                ventilate(d-shell*2, top_h-ethernet_z);
            // labels
            in=(shell/2)-e;
            rin=d+2*shell-in+(2*e);
            for (labels=[
                    ["Z2", 15, rin, 180],
                    ["Y2", 24, rin, 180],
                    ["X2", 32, rin, 180],
                    ["Z1", 40, rin, 180],
                    ["Y1", 48, rin, 180],
                    ["X1", 56, rin, 180],
                    ["H", 64, rin, 180],
                    ["B", 70, rin, 180],
                    ["E", 76, rin, 180],
                    ["1W", 85, rin, 180],
                    ["X", 87, in, 0],
                    ["Y", 76, in, 0],
                    ["Z", 65, in, 0],
                    ["E", 54, in, 0],
                    ["H", 43, in, 0],
                    ["F0", 32, in, 0],
                    ["F1", 24, in, 0],
                    ["F2", 16, in, 0],
                    ["F3", 8, in, 0],
                ]) {
                t = labels[0];
                x = labels[1] + shell;
                y = labels[2];
                zr = labels[3];
                translate([x, y, ctrl_z])
                    rotate([90, 180, zr])
                    linear_extrude(height=in+2*e)
                    text(t, size=4, valign="bottom", halign="center", font="Liberation Sans:style=Bold");
            }
            for (labels=[
                    ["+", 0],
                    ["V", 5],
                    ["V", 10],
                    ["-", 14],
                    ["-", 20],
                    ["E", 25],
                    ["+", 30.5],
                    ["-", 38],
                    ["B", 43],
                    ["B", 48],
                    ["+", 53],
                    ["-", 58],
                    ["H", 62],
                    ["+", 67],
                ]) {
                t = labels[0];
                y = labels[1] + 3 + molex_off; // indexed from first pin
                translate([w+(2*shell)-in, shell+y, (shell+top_h-molex_z)/2])
                    rotate([90, 180, 90])
                    linear_extrude(height=in+2*e)
                    text(t, size=5, valign="center", halign="center", font="Liberation Sans:style=Bold");            }
        }
    }
    for (o=[
            [0, 0],
            [0, 1],
            [1, 1],
            [1, 0],
        ]) {
        x = o[0];
        y = o[1];
        translate([shell+w/2, shell+d/2])
            mirror([x, 0, 0]) mirror([0, y, 0])
            translate([-w/2, -d/2, 0]) {
            difference() {
                union() {
                    cube([top_clip_len, molex_off, shell+top_h+top_clip_offset+shell]);
                    translate([0, 0, top_h+top_clip_offset+1.5*shell])
                        rotate([0, 90, 0])
                        cylinder(r=shell/2, h=top_clip_len, $fn=30);
                }
                // end cutout for easier fit
                translate([-e, -shell, shell+top_h+e])
                    cube([e+shell/4, shell+molex_off, top_clip_offset+shell]);
            }
        }
    }
}
case_bottom();
translate([0, d+flange+5*shell, 0])
    case_top();
