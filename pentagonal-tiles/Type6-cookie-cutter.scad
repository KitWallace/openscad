use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type6-tiles.scad>

scale=40;
inset=0.5;
n=1;
m=1;
B=60;
tiles =Type6_tiles(B,n,m);
echo(tiles);
tile =scale_tiles(flatten(tiles),scale)[0];


    linear_extrude(height=6)
        difference(){
           fill_tile(tile);
           fill_tile(inset_tile(tile,inset));
        }
    linear_extrude(height=2)
       difference(){
           fill_tile(tile);
           fill_tile(inset_tile(tile,inset*8));
        } 


