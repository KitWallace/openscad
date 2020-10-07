include <../lib/miller.scad>
include <../lib/basics.scad>
include <../lib/polyfns.scad>

include <miller-forms.scad>
   
shape= crystal_named("dodecahedron");

pts = miller_to_points(shape[1]);
// echo(pts);
//hull_points(pts);

poly= points_to_poly (shape[0],pts);

color("silver") scale(20) show_solid(place(poly));

