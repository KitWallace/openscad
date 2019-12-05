use <../lib/lsystem.scad>
use <../lib/tile_fns-v19.scad>



width=0.1;
scale=0.3;
align=0;
sentence0="F+F+F+F+";
sentence1="F+FF+F+FF+";
sentence2="F+F-F+FF+  F+F-F+FF+";
sentence3="F+F-F-F +F+F-F   +FF+  F+F-F-F+F+F-F+FF+";
//sentence4="F+F-F-F+F+F-F+FF+F+F-F-F+F+F-F+FF+";
sentence=sentence3;

echo (sentence);
points = string_to_points(sentence,angle=90);
echo(len(points));
echo(points);
fill_tile(points);
/*
cpoints= scale_tile(centre_tile(points),scale);
//echo(cpoints);
ipoints=inset_tile(cpoints,-0.01);
//echo(ipoints);
difference() {
//   frame(80,80,5,$fn=100);  
   rotate([0,0,align])
//     path(cpoints,width=width,$fn=30);
      fill_tile(ipoints);
}
*/