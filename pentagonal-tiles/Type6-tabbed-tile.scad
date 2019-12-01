use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type6-tiles.scad>

B=70;
n=3;
m=4;

tiles=Type6_tiles(B,1,1);
tile=flatten(tiles)[0];
echo(tile);
scale=7;
inset=0.001;
peri_report(tile_to_peri(tile));

tabbed_tile= inset_tile(scale_tile(uniform_tabbed_tile(tile,0.5,70,0.04),scale),inset);
peri_report(tabbed_tile);
//fill_tile(tabbed_tile);

tess_tiles =
  tesselate_tiles([tabbed_tile],n,m,
     [9,0],[0,9]);
fill_tiles(tess_tiles);
