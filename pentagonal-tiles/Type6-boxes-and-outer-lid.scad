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

gt = tiles_to_tile(ftiles);

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

//lid
translate([70,0,6])

rotate([0,180])
{
   linear_extrude(height=6) 
      difference() {
          fill_tile(inset_tile(gt,-2));
          fill_tile(inset_tile(gt,-0.1));
      }
   translate([0,0,4])
      linear_extrude(height=2)
         fill_tile(inset_tile(gt,-2));
}   
