use <conway2.scad>
use <arpruss-hull.scad>

points = [ [3, 2, 1]
, [3, -2, -1]
, [-3, 2, -1]
, [-3, -2, 1]
, [2, 1, 3]
, [2, -1, -3]
, [-2, 1, -3]
, [-2, -1, 3]
, [1, 3, 2]
, [1, -3, -2]
, [-1, 3, -2]
, [-1, -3, 2]
, [3, 1, -2]
, [3, -1, 2]
, [-3, 1, 2]
, [-3, -1, -2]
, [1, -2, 3]
, [1, 2, -3]
, [-1, -2, -3]
, [-1, 2, 3]
, [-2, 3, 1]
, [-2, -3, -1]
, [2, 3, -1]
, [2, -3, 1]];

//for (p=points) echo(p,norm(p));
s=dualHull(points);
solid_1=["pentagonal icositetrahedron",s[0],s[1]];
solid_3 = dual(solid_1);
solid_2 = openface(solid_1,outer_inset_ratio=0.4,inner_inset_ratio=0.3,depth=0.4,fn=[]);    
p_render(solid_2);
