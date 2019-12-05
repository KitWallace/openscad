use <../lib/lsystem.scad>
use <../lib/tile_fns-v19.scad>

curve=curve_named("Terdragon boundary");
k=7;

width=0.1;
scale=0.5;
align=0;

echo(curve);
sentence=gen(curve_axiom(curve),curve_rules(curve),k);
points = string_to_points(sentence,angle=curve_angle(curve),forward=curve_forward(curve));
cpoints= scale_tile(centre_tile(points),scale);
ipoints=inset_tile(cpoints,-0.01);

// path(cpoints,width=width,$fn=30);
fill_tile(ipoints);

