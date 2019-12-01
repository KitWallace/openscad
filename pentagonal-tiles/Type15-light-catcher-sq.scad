use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type15-tiles.scad>

module light_square(side,edge) {

difference() {
      square(side,center=true);
      square(side - edge*2,center=true);
}

translate([side/2-edge,side/2 + edge,0]) 
 difference() {
       circle(3);
       circle(1);
 }
 translate([-side/2+edge,side/2 + edge,0]) 
 difference() {
       circle(3);
       circle(1);
 }
difference() {
   square(side-edge*2,center=true);
   children();
}
}

scale=2;
inset=0.2;
n=25;
m=7;

tiles =Type15_tiles(n,m);
ftiles=centre_tiles(flatten(tiles));

difference() {
  light_square(90,2) 
  fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));
}