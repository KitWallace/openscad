use <../lib/tile_fns-v19.scad>
use <../lib/forms.scad>
use <../pentagonal-tiles/Type5-tiles.scad>

d=0.5;
E=105;   // floret

n=10;
m=10;
scale=5;
inset=0.4;

tiles= Type5_tiles(d,E,n,m);
ftiles = centre_tiles(flatten(tiles));

$fn=100;
 light_circle(90,2)
  fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));
