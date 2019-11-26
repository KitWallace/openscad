use <../lib/tile_fns.scad>
use <../lib/forms.scad>

//d=0.6;E=105;
d=0.5;E=105;   // floret

n=10;
m=10;
scale=5;
inset=0.4;

tiles= R5_tiles(d,E,n,m);

$fn=100;
 light_circle(90,2)
  fill_tiles(inset_group(scale_tiles(tiles,scale),inset));

function R5(d,E) =
   let (p =[[d,120],[d,E],[1,60],[1,0]])
   let (t= peri_to_tile(p,true))
   tile_to_peri(t);

function R5_tiles(d,E,n,m) =   
let(peri=R5(d,E))
let(assembly=[  
    [[0,0]],
    [[0,3],[0,2]],
    [[0,3],[1,2]],
    [[0,3],[2,2]],
    [[0,3],[3,2]],
    [[0,3],[4,2]]
    ])

let(tile=peri_to_tile(peri))
let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,0],[2,1]))
let(dy=tile_offset(unit,[0,1],[4,0]))
let(tiles= tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));


