use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type8-tiles.scad>

B=120;
n=3;
m=4;

tiles=Type8_tiles(B,1,1);
tile=flatten(tiles)[0];
echo(tile);
scale=7;
inset=-0.05;
tabbed_tile= inset_tile(scale_tile(uniform_tabbed_tile(tile,0.5,70,0.04),scale),inset);

tess_tiles =
  tesselate_tiles([tabbed_tile],n,m,
     [11,0],[0,16]);
fill_tiles(tess_tiles);
