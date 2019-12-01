use <../lib/tile_fns-v19.scad>
use <../lib/forms.scad>
use <../pentagonal-tiles/Type13-tiles.scad>

n=20;
m=20;
inset=0.2;
scale=2.5;
A=110; 

tiles = Type13_tiles(A,n,m);
ftiles = centre_tiles(flatten(tiles));
$fn=100;
light_circle(90,2)
  fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));   
