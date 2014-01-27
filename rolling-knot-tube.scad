// rolling knot code with thanks to mathgrrl and nop head
include <lib/tube.scad>

function f(t) =   // rolling knot
   [ a * cos (3 * t) / (1 - b* sin (2 *t)),
     a * sin( 3 * t) / (1 - b* sin (2 *t)),
     1.8 * b * cos (2 * t) /(1 - b* sin (2 *t))
   ];

$fn=40;
a = 0.8;
b = sqrt (1 - a * a);
r=0.3;
step=0.5;

circle_points = circle_points(r);
loop_points = loop_points(step);
tube_points = tube_points(loop_points);
loop_faces = loop_faces(len(loop_points));

scale(10) polyhedron(points = tube_points, faces = loop_faces);
