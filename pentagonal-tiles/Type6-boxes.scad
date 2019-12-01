use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type6-tiles.scad>

scale=20;
inset=2;
n=1;
m=1;
B=80;
tiles =Type6_tiles(B,n,m);
echo(tiles);
ftiles=scale_tiles(flatten(tiles),scale);

for (i=[0:len(ftiles)-1]) {
    tile = ftiles[i];
    linear_extrude(height=10+i*5)
       difference() {
           fill_tile(tile);
           fill_tile(inset_tile(tile,inset));
       }
    linear_extrude(height=2)
       fill_tile(tile); 
}

