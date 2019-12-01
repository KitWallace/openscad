use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type1_4-tiles.scad>

module light_circle(d,edge) {
 eps=0.0001;
 difference() {
      circle(d/2);
      circle(d/2 - edge);
 }

 translate([0,d/2+edge,0]) 
  difference() {
       circle(3);
       circle(1);
 }
 difference() {
   circle(d/2-edge+eps);
   children();
 }
}


colors=["red","green","yellow","blue","lightblue","orange","purple","gray"];
n=20;
m=20;
inset=0.5;
scale=4;
A=100;
b=1.5;
B=80;
E=130;

tiles=Type1_4_tiles(A,b,B,E,n,m);
ftiles=centre_tiles(flatten(tiles));

$fn=100;
 light_circle(90,2)
   fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset),colors);

