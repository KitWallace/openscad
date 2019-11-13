use <../lib/lsystem.scad>
use <../lib/tile_fns.scad>
index();

width=0.2;
scale=10;
align=0;
ci=13;
k=3;

curve=curves(ci);
  
echo(curve);
sentence=gen(curve[1],curve[2],k);
//echo (sentence);
points = string_to_points(sentence,angle=curve[3],forward=curve[4]);
//echo(len(points));
//echo(points);
cpoints= scale_tile(centre_tile(points),scale);
//echo(cpoints);
difference() {
//   frame(80,80,5,$fn=100);  
   rotate([0,0,align])
     path(cpoints,width=width,$fn=30);
}
