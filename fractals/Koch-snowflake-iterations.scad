use <../lib/tile_fns-v19.scad>
use <../lib/lsystem.scad>


scale=20;
align=0;
k=1;
curve=curve_named("Koch snowflake");
 
echo(curve);

for (k=[0:5]) {
   sentence=gen(curve_axiom(curve),curve_rules(curve),k);
  
   points = string_to_points(sentence,angle=curve_angle(curve));
   iscale= scale /pow(3,k);
   cpoints= centre_tile(scale_tile(points,iscale));
//echo(cpoints);

   translate([30*k,0,0])
    path(cpoints,0.2,$fn=50);
}

