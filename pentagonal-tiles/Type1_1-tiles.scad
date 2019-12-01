use <../lib/tile_fns-v19.scad>

/* Type 1
    Reinhardt 1918
    
    variant 1
    B+C=180
    A+D+E=360  (redundant)
    
    b and d parallel
 
    parameters:  A,b,c,d
    
    soluable with closure
*/

function Type1_1(A,b,B,c,d) =
   let (p =[[1,A],[b,B],[c,180-B],[d,0] ])
   let(t= peri_to_tile(p,true))
   tile_to_peri(t);
   
function Type1_1_tiles(A,b,c,d,n,m) =

let(peri =Type1_1(A,b,180-A,c,d)) 
let(tile=peri_to_tile(peri))
let(assembly=[
     [[0,0]],
     [[0,1],[0,1]]
    ])

let(unit =group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,3],[1,3]))
let(dy=tile_offset(unit,[0,4],[1,4]))
tesselate_tiles(unit,n,m,dx,dy);

