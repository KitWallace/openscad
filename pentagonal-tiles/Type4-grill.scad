use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type4-tiles.scad>

module grill(d,edge) {
 eps=0.0001;
 difference() {
      circle(d/2);
      circle(d/2 - edge);
 }

 difference() {
   circle(d/2-edge+eps);
   children();
 }
}

C=120;  //cairo
d=1;  // cairo

n=20;
m=20;
scale=3;
inset=0.8;

tiles= flatten(Type4_tiles(C,d,n,m));
ftiles = inset_tiles(scale_tiles(centre_tiles(tiles),scale),inset);

$fn=100;
 grill(104,5)
   fill_tiles(ftiles);
