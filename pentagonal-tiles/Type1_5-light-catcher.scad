use <../lib/tile_fns-v19.scad>
use <../lib/forms.scad>
use <../pentagonal-tiles/Type1_5-tiles.scad>

colors=["red","green","yellow","blue","lightblue","orange","purple","gray"];
n=20;
m=20;
inset=0.5;
scale=4;
C=80;
b=0.6;

tiles=Type1_5_tiles(C,b,n,m);
ftiles=centre_tiles(flatten(tiles));

$fn=100;
 light_circle(90,2)
   fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset),colors);

