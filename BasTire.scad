tread_type = "hollow_tube"; // (simple, tube, hollow_tube)
tread_angle = 10;
tread_height = 0.5;
tread_width = 1;
tire_thickness = 1;
hollow_tube_thickness = 1;

// Same as BasWheel parameters
wheel_diameter = 60;
wheel_height = 10;
rim_height = 1;

/*
 *
 * BasTire v1.03
 *
 * by Basile Laderchi
 *
 * Licensed under Creative Commons Attribution-ShareAlike 3.0 Unported http://creativecommons.org/licenses/by-sa/3.0/
 *
 * v 1.03,  5 September 2013 : Added tread_type "hollow_tube" and hollow_tube_thickness parameter
 * v 1.02, 29    August 2013 : Added tread_type "tube", in tread_type "simple" changed from cubes to arcs
 * v 1.01, 27    August 2013 : Fixed invalid Manifold
 * v 1.00, 27    August 2013 : Initial release
 *
 */

basTire(tread_type, tread_angle, tread_height, tread_width, tire_thickness, hollow_tube_thickness, wheel_diameter, wheel_height, rim_height, $fn=100);

use <MCAD/2Dshapes.scad>

module basTire(tread_type, tread_angle, tread_height, tread_width, tire_thickness, hollow_tube_thickness, wheel_diameter, wheel_height, rim_height) {
	union() {
		tire(tire_thickness, wheel_diameter, wheel_height, rim_height);
		tread(tread_type, tread_angle, tread_height, tread_width, tire_thickness, hollow_tube_thickness, wheel_diameter, wheel_height, rim_height);
	}
}

module wheel(wheel_diameter, wheel_height, rim_height) {
	padding = 0.1;

	wheel_radius = wheel_diameter / 2;
	height = wheel_height - rim_height * 2;

	cylinder(r=wheel_radius, h=height + padding, center=true);
}

module tire(thickness, wheel_diameter, wheel_height, rim_height) {
	wheel_radius = wheel_diameter / 2;
	radius = wheel_radius + thickness;
	height = wheel_height - rim_height * 2;

	ring(radius, thickness, height);
}

module tread(type, angle, height, width, tire_thickness, hollow_tube_thickness, wheel_diameter, wheel_height, rim_height) {
	padding = 0.1;

	wheel_radius = wheel_diameter / 2;
	tire_radius = wheel_radius + tire_thickness;
	tire_circumference = 2 * PI * tire_radius;
	tire_height = wheel_height - rim_height * 2;
	tire_height_padded = tire_height + padding * 2;
	slice_width = width / tire_circumference * 360;

	if (type == "simple") {
	  for (i = [0 : 360 / angle]) {
			rotate([0, 0, i * angle]) {
				translate([0, 0, -tire_height / 2]) {
					donutSlice3D(tire_radius, tire_radius + height, 0, slice_width, tire_height);
				}
			}
		}
	} else if (type == "tube") {
		rotate_extrude() {
			translate([tire_radius, 0, 0]) {
				difference() {
					circle(r=tire_height / 2);
					translate([-tire_height_padded, -tire_height_padded / 2, 0]) {
						square(tire_height_padded);
					}
				}
			}
		}
	} else if (type == "hollow_tube") {
		rotate_extrude() {
			translate([tire_radius, 0, 0]) {
				difference() {
					circle(r=tire_height / 2);
					translate([-tire_height_padded, -tire_height_padded / 2, 0]) {
						square(tire_height_padded);
					}
					difference() {
						circle(r=tire_height / 2 - hollow_tube_thickness);
						translate([-tire_height_padded + hollow_tube_thickness, -tire_height_padded / 2, 0]) {
							square(tire_height_padded);
						}
					}
				}
			}
		}
	}
}

module ring(radius, thickness, height) {
	padding = 0.1;

	inner_radius = radius - thickness;

	difference() {
		cylinder(r=radius, h=height, center=true);
		cylinder(r=inner_radius, h=height + padding, center=true);
	}
}

module donutSlice3D(innerSize, outerSize, start_angle, end_angle, height) {
	linear_extrude(height=height, convexity=10) {
		donutSlice(innerSize, outerSize, start_angle, end_angle);
	}
}
