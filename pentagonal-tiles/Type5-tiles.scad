use <../lib/tile_fns-v19.scad>

/* Type 5 - Reinhardt 

   a=b
   d=e
   A=60
   D=120
   
   solution by closure
   
   parameters  d, E 
   
   typical values d=0.6; E=105
   floret  d=0.5; E=105

*/

function Type5(d,E) =
   let (p =[[d,120],[d,E],[1,60],[1,0]])
   let (t= peri_to_tile(p,true))
   tile_to_peri(t);

function Type5_tiles(d,E,n,m) =   
let(peri=Type5(d,E))
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
tesselate_tiles(unit,n,m,dx,dy);


