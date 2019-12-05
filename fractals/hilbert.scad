use <../lib/tile_fns-v19.scad>
use <../lib/lsystem.scad>

curve=curve_named("Hilbert");
k=6;

width=0.8;
scale=2;
align=0;
$fn=100;      
echo(curve);
sentence=gen(curve_axiom(curve),curve_rules(curve),k);
//echo (sentence);
points = string_to_points(sentence,angle=curve_angle(curve),forward=curve_forward(curve));
//echo(len(points));
//echo(points);
cpoints= centre_tile(scale_tile(points,scale));
//echo(cpoints);
difference() {
//   frame(80,80,5,$fn=100);  
   rotate([0,0,align])
     color("red")
        path(cpoints,width=width,$fn=25);
}
