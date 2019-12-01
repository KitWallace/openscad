use <../lib/tile_fns-v19.scad>
use <../pentagonal-tiles/Type6-tiles.scad>



n=20;
m=20;
inset=1;
scale=6;
B=70;

tiles=Type6_tiles(B,n,m);
ftiles=centre_tiles(flatten(tiles));

$fn=50;
r=100;
depth=10;
thickness=2;

 difference() {
  intersection() {
   translate([0,0,-r+depth])
     difference(){
         sphere(r=r);
         sphere(r=r-thickness);
     }
    
   cylinder(r=45,h=20,center=true); 
 }    
  
      
 translate([0,0,-10])
   linear_extrude(height=50) 
    intersection() {
         fill_tiles(inset_tiles(scale_tiles(ftiles,scale),inset));
         circle(r=42);
    }
   
 }
