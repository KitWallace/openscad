use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type9-tiles.scad>

n=10;m=10;
inset=0.5;
scale=5;
a=0.4; 
tiles=Type9_tiles(a,n,m);
ftiles=centre_tiles(flatten(tiles));

$fn=100;
light_circle(90,2)
   fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));
