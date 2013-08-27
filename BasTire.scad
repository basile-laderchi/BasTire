tread_type = "simple";
tread_angle = 10;
tread_height = 0.5;
tread_width = 1;
tire_thickness = 1;

// Same as BasWheel parameters
wheel_diameter = 60;
wheel_height = 10;
rim_height = 1;

/*
 *
 * BasTire v1.01
 *
 * by Basile Laderchi
 *
 * Licensed under Creative Commons Attribution-ShareAlike 3.0 Unported http://creativecommons.org/licenses/by-sa/3.0/
 *
 * v 1.01, 27 August 2013 : Fixed invalid Manifold
 * v 1.00, 27 August 2013 : Initial release
 *
 */

basTire(tread_type, tread_angle, tread_height, tread_width, tire_thickness, wheel_diameter, wheel_height, rim_height, $fn=100);

module basTire(tread_type, tread_angle, tread_height, tread_width, tire_thickness, wheel_diameter, wheel_height, rim_height) {
	union() {
		tire(tire_thickness, wheel_diameter, wheel_height, rim_height);
		tread(tread_type, tread_angle, tread_height, tread_width, tire_thickness, wheel_diameter, wheel_height, rim_height);
	}
}

module tire(thickness, wheel_diameter, wheel_height, rim_height) {
	wheel_radius = wheel_diameter / 2;
	radius = wheel_radius + thickness;
	height = wheel_height - rim_height * 2;

	ring(radius, thickness, height);
}

module tread(type, angle, height, width, tire_thickness, wheel_diameter, wheel_height, rim_height) {
	padding = 0.1;

	wheel_radius = wheel_diameter / 2;
	tire_radius = wheel_radius + tire_thickness;
	tire_height = wheel_height - rim_height * 2;

	if (type == "simple") {
	  for (i = [0 : 360 / angle]) {
			rotate([0, 0, i * angle]) {
				translate([tire_radius + height / 2 + padding, 0, 0]) {
					cube([height + padding * 2, width, tire_height], center=true);
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
