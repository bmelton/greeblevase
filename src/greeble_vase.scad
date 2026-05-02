$fa = 1;
$fs = 0.5;

// parameters
// Overall height
h = 125;
// Outer diameter
d = 60;
// Wall thickness
w = 2;

// pattern parameters
greeble_panel_height = 70;
// Number of columns (depends on outer diameter)
num_cols = 26;
top_buffer = 5;
// Panel depth should be greater than wall thickness if you want it to cut through (but too big and it will cut through the other side)
panel_depth = 5;
// inset radius (it will get overridden most of the time, but if you do extremely few columns, this is needed)
panel_radius = 3;

/*
/ "random"    — original randomised panel heights / row counts
/ "authentic" — Death Star corridor panel pattern (top band + offset rows)
*/
pattern_mode = "authentic";  // ["authentic", "random"]

/*
/ "vase" — original vase with floor
/ "lamp" — no floor, cable notch at base
*/
use_case = "vase";  // ["vase", "lamp"]

// Lamp-specific parameters
cable_notch_w = 4;    // notch width (enough for LED Kit 0001 cable + some wiggle room)
cable_notch_h = 6;    // notch height
cable_notch_d = w + 2; // slightly deeper than wall thickness to ensure clean cut


// ── Liner parameters ──────────────────────────────────────────────────────
include_liner  = true;
liner_w     = 0.42;   // single extrusion width
liner_gap   = 0.2;    // radial clearance so it slips in easily
liner_offset = d + 10; // how far to the side the liner renders

module liner_profile() {
    liner_r_outer = d/2 - w - liner_gap;
    liner_r_inner = liner_r_outer - liner_w;
    liner_h = (use_case == "lamp") ? h - cable_notch_h : h;

    difference() {
        hull() {
            translate([0, 0]) square([liner_r_outer, 1]); // flat base, no fillet
            translate([liner_r_outer - 0.1, liner_h]) square([0.1, 0.1]);
            translate([0, liner_h]) square([0.1, 0.1]);
        }
        hull() {
            translate([0, -10]) square([liner_r_inner, 1]); // flat inner base
            translate([liner_r_inner, liner_h + 1]) square([0.1, 0.1]);
            translate([-0.1, liner_h + 1]) square([0.1, 0.1]);
        }
    }
}

r_fillet = 5;


module liner() {
    translate([liner_offset, 0, 0])
        rotate_extrude()
            liner_profile();
}

module vase_profile() {
    difference() {
        hull() {
            translate([r_fillet, r_fillet]) circle(r = r_fillet);
            translate([d/2 - r_fillet, r_fillet]) circle(r = r_fillet);
            translate([d/2 - 0.1, h]) square([0.1, 0.1]);
            translate([0, h]) square([0.1, 0.1]);
        }
        hull() {
            translate([-r_fillet, -10]) circle(r = r_fillet);
            translate([d/2 - w - r_fillet, -10]) circle(r = r_fillet);
            translate([d/2 - w, h + 1]) square([0.1, 0.1]);
            translate([-0.1, h + 1]) square([0.1, 0.1]);
        }
    }
}

module vase_floor() {
    cylinder(d = d - w, h = w);
}

module cable_notch() {
    // Centered on X axis, cut from the outside of the wall inward at the base
    translate([-cable_notch_w / 2, d/2 - cable_notch_d, 0])
        cube([cable_notch_w, cable_notch_d, cable_notch_h]);
}

module rounded_panel(depth, width, panel_h, r) {
    r_clamped = min(r, width/2, panel_h/2);
    hull() {
        translate([0, r_clamped, r_clamped])
            rotate([0, 90, 0]) cylinder(r = r_clamped, h = depth);
        translate([0, width - r_clamped, r_clamped])
            rotate([0, 90, 0]) cylinder(r = r_clamped, h = depth);
        translate([0, r_clamped, panel_h - r_clamped])
            rotate([0, 90, 0]) cylinder(r = r_clamped, h = depth);
        translate([0, width - r_clamped, panel_h - r_clamped])
            rotate([0, 90, 0]) cylinder(r = r_clamped, h = depth);
    }
}

// ── RANDOM mode ───────────────────────────────────────────────────────────
module ds_pattern_random() {
    start_z = h - greeble_panel_height + top_buffer;
    end_z = h - top_buffer;
    available_h = end_z - start_z;
    col_width = (PI * d) / (num_cols * 2);
    gap = 3;
    min_panel_h = 10;

    for (i = [0 : num_cols - 1]) {
        num_rows = 2 + floor(rands(0, 2.999, 1, i * 13)[0]);
        total_gaps = gap * (num_rows - 1);
        pool = available_h - total_gaps;
        guaranteed = min_panel_h * num_rows;
        flex = pool - guaranteed;

        s = rands(0, 1, 3, i * 31);
        a = min(s[0], min(s[1], s[2]));
        c = max(s[0], max(s[1], s[2]));
        b = s[0] + s[1] + s[2] - a - c;

        h0 = min_panel_h + a * flex;
        h1 = min_panel_h + (b - a) * flex;
        h2 = min_panel_h + (c - b) * flex;
        h3 = min_panel_h + (1 - c) * flex;

        p0 = h0;
        p1 = (num_rows >= 2) ? h1 : 0;
        p2 = (num_rows >= 3) ? h2 : 0;
        p_last = pool - (num_rows == 2 ? p0
                       : num_rows == 3 ? p0 + p1
                       :                 p0 + p1 + p2);

        heights = num_rows == 2 ? [p0, p_last, 0,      0     ]
                : num_rows == 3 ? [p0, p1,     p_last, 0     ]
                :                 [p0, p1,     p2,     p_last];

        rotate([0, 0, i * (360 / num_cols)])
        translate([d/2 - panel_depth, -col_width/2, start_z]) {
            for (j = [0 : num_rows - 1]) {
                ph = heights[j];
                pz = j == 0 ? 0
                   : j == 1 ? heights[0] + gap
                   : j == 2 ? heights[0] + heights[1] + gap * 2
                   :           heights[0] + heights[1] + heights[2] + gap * 3;
                translate([0, 0, pz])
                    rounded_panel(panel_depth + 1, col_width, ph, panel_radius);
            }
        }
    }
}

// ── AUTHENTIC mode ────────────────────────────────────────────────────────
module ds_pattern_authentic() {
    start_z    = h - greeble_panel_height + top_buffer;
    end_z      = h - top_buffer;
    col_width  = (PI * d) / (num_cols * 2);
    gap        = 3;
    top_band_height = 10;
    body_h      = (end_z - start_z) - top_band_height - gap;
    offset_frac = 0.15;

    for (i = [0 : num_cols - 1]) {
        is_odd = (i % 2);
        split = is_odd ? (0.5 + offset_frac) : 0.5;
        lower_h = body_h * split       - gap / 2;
        upper_h = body_h * (1 - split) - gap / 2;
        body_start_z  = start_z;
        upper_start_z = body_start_z + lower_h + gap;
        band_start_z  = end_z - top_band_height;

        rotate([0, 0, i * (360 / num_cols)])
        translate([d/2 - panel_depth, -col_width/2, 0]) {
            translate([0, 0, body_start_z])
                rounded_panel(panel_depth + 1, col_width, lower_h, panel_radius);
            translate([0, 0, upper_start_z])
                rounded_panel(panel_depth + 1, col_width, upper_h, panel_radius);
            translate([0, 0, band_start_z])
                rounded_panel(panel_depth + 1, col_width, top_band_height, panel_radius);
        }
    }
}

// ── dispatch ──────────────────────────────────────────────────────────────
module ds_pattern() {
    if (pattern_mode == "authentic") {
        ds_pattern_authentic();
    } else {
        ds_pattern_random();
    }
}

// ── assembly ──────────────────────────────────────────────────────────────
difference() {
    union() {
        rotate_extrude() vase_profile();
        if (use_case == "vase") vase_floor();
    }
    ds_pattern();
    if (use_case == "lamp") cable_notch();
 }
 
if (include_liner) liner();
