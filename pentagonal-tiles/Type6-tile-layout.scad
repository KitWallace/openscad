use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type9-tiles.scad>

// alignment of outer tile boundary and inner tiles is manual and tedious but tile orientation is lost in the grouping

// this looks better than without the bounary because otherwise its only 1 thickness while inner edges are double thickness
n=2;
m=4;
inset=0.8;
scale=4;
a=0.4;

tiles=Type9_tiles(a,n,m);
ftiles=scale_tiles(flatten(tiles),scale);

gt = tiles_to_tile(ftiles);

 difference() {
    translate([4,0,0]) 
    rotate([0,0,-97.7])
      fill_tile(inset_tile(gt,-1.2));

    fill_tiles(inset_tiles(ftiles,inset));

 }
 
