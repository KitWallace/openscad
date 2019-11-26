use <../lib/tile_fns.scad>
use <../lib/forms.scad>
colors=["red","green","blue","yellow"];
n=20;
m=25;
scale=2;
inset=0.3;

tiles=R1_1_tiles(110,2.5,2.5,0.5,n,m);

$fn=100;
 light_circle(90,2)
  fill_tiles(inset_group(scale_tiles(tiles,scale),inset),colors);

 
function R1(A,b,B,c,d) =
   let (p =[[1,A],[b,B],[c,180-B],[d,0] ])
   let(t= peri_to_tile(p,true))
   tile_to_peri(t);
   
// R1_1  two pairs parallel

function R1_1_tiles(A,b,c,d,n,m) =
    
//  R1 -  soluable with closure
//  B + C = 180°
//  A + D + E = 360°

// R1 - unconstrained

let(peri =R1(A,b,180-A,c,d)) 
let(tile=peri_to_tile(peri))
let(assembly=[
     [[0,0]],
     [[0,1],[0,1]]
    ])

let(unit =group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,3],[1,3]))
let(dy=tile_offset(unit,[0,4],[1,4]))
let(tiles= tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));
