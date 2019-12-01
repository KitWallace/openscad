use <../lib/tile_fns-v19.scad>
use <../lib/forms.scad>
use <../pentagonal-tiles/Type6-tiles.scad>

n=20;
m=20;
inset=0.5;
scale=4;
B=70;

tiles=Type6_tiles(B,n,m);
ftiles=centre_tiles(flatten(tiles));

$fn=100;
 light_circle(90,2)
   fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));

