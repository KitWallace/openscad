use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type6-tiles.scad>

scale=20;
inset=1;
n=1;
m=1;
B=80;
tiles =Type6_tiles(B,n,m);
echo(tiles);
ftiles=scale_tiles(flatten(tiles),scale);

for (i=[0:len(ftiles)-1]) {
    tile = ftiles[i];
    linear_extrude(height=30+i*0)
       difference() {
           fill_tile(tile);
           fill_tile(inset_tile(tile,inset));
       }
    linear_extrude(height=2)
       fill_tile(tile); 
}
translate([90,0,0])
rotate([0,180])
for (i=[0:len(ftiles)-1]) {
    tile = ftiles[i];
    translate([0,0,-2 + 0.0001])
      linear_extrude(height=4)
       fill_tile(inset_tile(tile,inset+0.2));
    linear_extrude(height=2)
       fill_tile(tile); 
}
