tire_type = "auto"; // (flat, hemispherical, bike, auto)
tread_type = "none"; // (none, simple)
tread_angle = 10;
tread_height = 0.5;
tread_width = 1;
tire_thickness = 1;
auto_tire_roundness_radius = 2;
hollow_tire_thickness = 1;

// Same as BasWheel parameters
wheel_diameter = 60;
wheel_height = 10;
wheel_extra_height = 0;
rim_width = 1;
rim_height = 1;

/*
 *
 * BasTire v2.03
 *
 * by Basile Laderchi
 *
 * Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International http://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 * v 2.03,  3 Jan 2014 : Added parameter wheel_extra_height (from wheel)
 * v 2.02,  3 Dec 2013 : Changed license from CC BY-SA 3.0 to CC BY-NC-SA 4.0
 * v 2.01, 11 Sep 2013 : Added old tread_type to tire_type. Renamed old tread_type "tube" to tire_type "bike". Added tire_type "auto"
 * v 2.00, 10 Sep 2013 : Added tire_type and rim_width (from wheel) parameters. Change values accepted for tread_type parameter. Changed hollow_tube_thickness parameter to hollow_tire_thickness
 * v 1.05,  6 Sep 2013 : Added tread_type "tube". It can use the hollow_tube_thickness parameter
 * v 1.04,  6 Sep 2013 : Renamed tread_type "tube" to "hemispherical" and dropped tread_type "hollow_tube"
 * v 1.03,  5 Sep 2013 : Added tread_type "hollow_tube" and hollow_tube_thickness parameter
 * v 1.02, 29 Aug 2013 : Added tread_type "tube", in tread_type "simple" changed from cubes to arcs
 * v 1.01, 27 Aug 2013 : Fixed invalid Manifold
 * v 1.00, 27 Aug 2013 : Initial release
 *
 */

basTire(tire_type, tread_type, tread_angle, tread_height, tread_width, tire_thickness, auto_tire_roundness_radius, hollow_tire_thickness, wheel_diameter, wheel_height, wheel_extra_height, rim_width, rim_height, $fn=100);

use <MCAD/2Dshapes.scad>

module basTire(tire_type, tread_type, tread_angle, tread_height, tread_width, tire_thickness, auto_tire_roundness_radius, hollow_tire_thickness, wheel_diameter, wheel_height, wheel_extra_height, rim_width, rim_height) {
	wheel_full_height = wheel_height + wheel_extra_height;

	union() {
		tire(tire_type, tire_thickness, auto_tire_roundness_radius, hollow_tire_thickness, wheel_diameter, wheel_full_height, rim_width, rim_height);
		tread(tread_type, tread_angle, tread_height, tread_width, tire_thickness, wheel_diameter, wheel_full_height, rim_height);
	}
}

module wheel(wheel_diameter, wheel_height, rim_height) {
	padding = 0.1;

	wheel_radius = wheel_diameter / 2;
	height = wheel_height - rim_height * 2;

	cylinder(r=wheel_radius, h=height + padding, center=true);
}

module tire(type, thickness, auto_roundness_radius, hollow_thickness, wheel_diameter, wheel_height, rim_width, rim_height) {
	padding = 0.1;

	wheel_radius = wheel_diameter / 2;
	radius = wheel_radius + thickness;
	height = wheel_height - rim_height * 2;
	height_padded = height + padding * 2;

	union() {
		if (type == "flat" || type == "hemispherical") {
			ring(radius, thickness, height);
		}
		if (type == "hemispherical") {
			rotate_extrude() {
				translate([radius, 0, 0]) {
					difference() {
						circle(r=height / 2);
						translate([-height_padded, -height_padded / 2, 0]) {
							square(height_padded);
						}
					}
				}
			}
		} else if (type == "bike") {
			rotate_extrude() {
				translate([wheel_radius, 0, 0]) {
					difference() {
						union() {
							hull() {
								translate([wheel_height / 2 + rim_width + 0.5, 0, 0]) {
									circle(r=wheel_height / 2);
								}
								translate([rim_width, -height / 2, 0]) {
									square([0.5, height]);
								}
							}
							translate([0, -height / 2, 0]) {
								square([rim_width, height]);
							}
						}
						if (hollow_thickness > 0) {
							inner_tire(type, hollow_thickness, wheel_height, rim_width, rim_height, padding);
						}
					}
				}
			}
		} else if (type == "auto") {
			rotate_extrude() {
				translate([wheel_radius, 0, 0]) {
					difference() {
						union() {
							hull() {
								if (auto_roundness_radius < wheel_height / 2) {
									translate([rim_width + wheel_height + 0.5, -wheel_height / 2 + auto_roundness_radius, 0]) {
										square([0.5, wheel_height - auto_roundness_radius * 2]);
									}
									translate([rim_width + wheel_height - auto_roundness_radius + 1, wheel_height / 2 - auto_roundness_radius, 0]) {
										circle(r=auto_roundness_radius);
									}
									translate([rim_width + wheel_height - auto_roundness_radius + 1, -wheel_height / 2 + auto_roundness_radius, 0]) {
										circle(r=auto_roundness_radius);
									}
								} else {
									translate([rim_width + wheel_height + 0.5, -wheel_height / 2, 0]) {
										square([0.5, wheel_height]);
									}
								}
								translate([wheel_height / 2 + rim_width + 0.5, 0, 0]) {
									circle(r=wheel_height / 2);
								}
								translate([rim_width, -height / 2, 0]) {
									square([0.5, height]);
								}
							}
							translate([0, -height / 2, 0]) {
								square([rim_width, height]);
							}
						}
						if (hollow_thickness > 0) {
							inner_tire(type, hollow_thickness, wheel_height, rim_width, rim_height, padding);
						}
					}
				}
			}
		}
	}
}

module inner_tire(type, hollow_thickness, wheel_height, rim_width, rim_height, padding) {
	height = wheel_height - rim_height * 2;

	if (type == "bike" || type == "auto") {
		union() {
			hull() {
				translate([wheel_height / 2 + rim_width + 0.5, 0, 0]) {
					circle(r=wheel_height / 2 - hollow_thickness);
				}
				translate([rim_width, - height / 2 + hollow_thickness, 0]) {
					square([0.5, height - hollow_thickness * 2]);
				}
			}
			translate([-padding, - height / 2 + hollow_thickness, 0]) {
				square([rim_width + padding, height - hollow_thickness * 2]);
			}
		}
	}
}

module tread(type, angle, height, width, tire_thickness, wheel_diameter, wheel_height, rim_height) {
	wheel_radius = wheel_diameter / 2;
	tire_radius = wheel_radius + tire_thickness;
	tire_circumference = 2 * PI * tire_radius;
	tire_height = wheel_height - rim_height * 2;
	slice_width = width / tire_circumference * 360;

	if (type == "simple") {
	  for (i = [0 : 360 / angle]) {
			rotate([0, 0, i * angle]) {
				translate([0, 0, -tire_height / 2]) {
					donutSlice3D(tire_radius, tire_radius + height, 0, slice_width, tire_height);
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
