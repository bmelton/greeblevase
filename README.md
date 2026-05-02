# Greeble Vase

The Greeble Vase is a vase inspired by the Death Star's greeble-patterned walls. 

This is a parametric, OpenSCAD model that you can use to render a vase, pencil/pen cup, makeup brush holder, toothbrush holder, or (with the option toggled) a lampshade, and can optionally render a diffusion layer alongside that is designed to be printed in vase mode. 

I'm not an OpenSCAD expert so probably a lot of this code is dumb, or at least unlikely to be idiomatic. Apologies in advance.

## Usage

Download the greeble_vase and open it in OpenSCAD. Play with the parameters (they should all have comments) until you get the vase you want. Voila. 

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `h` | `100` | Overall height of the vase in mm |
| `d` | `60` | Diameter of the vase in mm |
| `w` | `2` | Wall thickness in mm |

| Parameter | Default | Description |
|-----------|---------|-------------|
| `pattern_mode` | `"authentic"` | Pattern style — `"authentic"` for a Death Star corridor-inspired layout (top band + offset rows), or `"random"` for randomized panel heights and row counts |
| `greeble_panel_height` | `70` | Height of the greeble zone, measured from the top of the vase |
| `num_cols` | `26` | Number of panel columns around the circumference |
| `top_buffer` | `5` | Blank margin at the very top and bottom of the greeble zone in mm |
| `panel_depth` | `5` | How deep the recessed panels are cut into the wall in mm |
| `panel_radius` | `3` | Corner radius on each panel (used as a fallback for very wide panels) |

### Use Case

| Parameter | Default | Description |
|-----------|---------|-------------|
| `use_case` | `"vase"` | Set to `"vase"` to include a solid floor, or `"lamp"` to omit the floor and cut a cable notch at the base for use as a lampshade |

### Lamp Options

Only relevant when `use_case = "lamp"`.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `cable_notch_w` | `4` | Width of the cable notch in mm |
| `cable_notch_h` | `6` | Height of the cable notch in mm |
| `cable_notch_d` | `w + 2` | Depth of the cable notch — slightly deeper than wall thickness to ensure a clean cut |

### Liner

The liner is a thin-walled insert designed to be printed separately in vase mode. It sits inside the main vase body and acts as a diffusion layer when used as a lamp, or simply as a watertight inner shell for the vase.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `include_liner` | `true` | Whether to render the liner alongside the main vase |
| `liner_w` | `0.42` | Liner wall thickness — set this to match your nozzle diameter for single-wall vase mode printing |
| `liner_gap` | `0.2` | Radial clearance between the liner and the inner wall of the vase in mm |
| `liner_offset` | `d + 10` | How far to the side the liner is placed in the render, so the two bodies don't overlap on the print bed |


## Printing Tips

- Print the main vase in your filament of choice. I think black is appropriate for several reasons, but I am not very imaginative. I also think that matte finishes work better than glossy, but glossy PETG might actually be more appropriate. YMMV.
- Print the liner in **vase mode** (single-wall, no top/bottom layers, no infill) using a filament that matches your `liner_w` nozzle diameter. If you're using a 0.4mm nozzle, the `liner_w` value should be 0.42. White is what I've used here, but as Chef John might say, you are the designer, of your greeble vase liner. 
