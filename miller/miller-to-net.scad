include <../lib/miller.scad>
include <../lib/basics.scad>
include <../lib/polyfns.scad>
include <../lib/netfns.scad>
include <miller-forms.scad>
   
shape= crystal_named("pentagonal dodecahedron");

pts = miller_to_points(shape[1]);
// echo(pts);
//hull_points(pts);

poly= points_to_poly (shape[0],pts);

p_net_render(poly);
