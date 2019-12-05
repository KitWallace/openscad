use <../lib/tile_fns-v19.scad>
use <../lib/lsystem.scad>


scale=10;
align=0;
width=5;
k=2;
curve=curve_named("Koch square");
factor=1.5;
echo(curve);


sentence=gen(curve_axiom(curve),curve_rules(curve),k);
  
points = string_to_points(sentence,angle=curve_angle(curve));
iscale= scale /pow(factor,k);
cpoints= centre_tile(scale_tile(points,iscale));
//echo(cpoints);
   
linear_extrude(height=100)
  path(cpoints,width,$fn=50);
linear_extrude(height=5)
  fill_tile(cpoints);

