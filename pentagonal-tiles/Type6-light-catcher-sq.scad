use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type6-tiles.scad>

module light_square(a,b,edge) {
eps=0.001;
difference() {
      square([a,b],center=true);
      square([a - edge*2,b-edge*2],center=true);
}

difference() {
   square([a - edge*2+eps,b-edge*2+eps],center=true);
   children();
 }
}

scale=5;
inset=0.5;
n=12;
m=12;
B=70;
tiles =Type6_tiles(B,n,m);
ftiles=centre_tiles(flatten(tiles));

difference() {
  light_square(40,60,2) 
  fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));
}