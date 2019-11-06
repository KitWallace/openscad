use <../lib/lsystem.scad>
use <../lib/tile_fns.scad>
index();

width=0.2;
scale=2;
align=0;
ci=7;
k=5;

curve=curves(ci);
  
echo(curve);
sentence=gen(curve[1],curve[2],k);
//echo (sentence);
points = string_to_points(sentence,angle=curve[3]);
echo(len(points));
//echo(points);
cpoints= centre_tile(scale_tile(points,scale));
// echo(cpoints);
difference() {
//   frame(80,80,5,$fn=100);  
   rotate([0,0,align])
     path(cpoints,width=width, $fn=50);
}
