use <tile_fns.scad>

/* 
see Example C in Wallpaper Group in Wikipedia from chinese porcelain

this is called p4g or 4*2 

note that with only verticle tiles, the figure is the tile,the ground the tile rotated 90
if the rotated tile is also used, 
*/

chinese_peri= repeat([[7, 90], [1, 90], [1, 270], [1, 90], [1, 90], [1, 270], [1, 270], [7, 270], [1, 270], [1, 90], [1, 90], [1, 270], [1, 90], [1, 90]],2);

 d=10;
 chinese_tile = scale_tile(centre_tile(peri_to_tile(chinese_peri)),1/d);

 n=8;m=8;
 scale(20)
 for (i=[0:n])
      for (j=[0:m])
          translate([i,j,0]) {
              color("red") fill_tile(chinese_tile);
              color("red") translate([0.5,0.5,0]) fill_tile(chinese_tile);
              color("green") translate([0.5,0,0]) rotate([0,0,90]) fill_tile(chinese_tile);
              color("green") translate([0,0.5,0]) rotate([0,0,90]) fill_tile(chinese_tile);
          }
          
