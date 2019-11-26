use <../lib/tile_fns.scad>
use <../lib/forms.scad>

C=120;  //cairo
d=1;  // cairo

n=20;
m=20;
scale=4;
inset=0.5;

tiles= R4_tiles(C,d,n,m);

$fn=100;
 light_circle(90,2)
  fill_tiles(inset_group(scale_tiles(tiles,scale),inset));

 
function R4(C,d) =
   let (p =[[1,90],[1,C],[d,90],[d,0]])
   let (t=peri_to_tile(p,true))
   tile_to_peri(t);

function R4_tiles(C,d,n,m) =    
let(peri=R4(C,d))
let(tile=peri_to_tile(peri))
let(assembly=[  
    [[0,0]],
    [[0,4],[0,4]],
    [[0,1],[0,0]],
    [[0,1],[1,0]]
    ])

let(unit=group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,1],[3,0]))
let(dy=tile_offset(unit,[0,2],[2,3]))
let(tiles= tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));
