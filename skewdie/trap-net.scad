use <../lib/tile_fns-v19.scad>
use <../lib/tile_svg.scad>

function trapezium(B,b,C,c) =
     let (p = [[1,B],[b,C],[c,0]])
     let (t= peri_to_tile(p,true))
     tile_to_peri(t);
    
function skew_cube_net(B,b,C,c) =
     let (peri = trapezium(B,b,C,c))
     let (tile = peri_to_tile(peri))
     let (assembly = [
      [[0,0]],
      [[0,0],[0,0]],
      [[0,1],[0,1]],
      [[0,2],[0,2]],
      [[0,3],[0,3]],
      [[0,2],[1,2]],
      ])
     let(unit=group_tiles([tile],assembly))
     unit;
scale=50;
tiles = scale_tiles(skew_cube_net(100,1.1,60,0.9),scale);
echo(tiles);

fill_tiles(tiles,["red","green","blue","pink","orange","black","yellow"]);
    
faces_to_svg(tiles,0.1,0);
