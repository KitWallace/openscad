use <../lib/tile_fns-v19.scad>

/* Type 2  Reinhardt  

   c=e
   B+D =180
   
   solution by closure
   
   parameters b,B,C,d
   
   Typical values
     b=1;
     B=120;
     C=140;
     d=1;

*/


function Type2(b,B,C,d) =
   let (p =[[b,B],[1,C],[d,180-B],[1,0]])
   let (t=peri_to_tile(p,true))
   tile_to_peri(t);

function Type2_tiles(b,B,C,d,n,m) =    
let(peri=Type2(b,B,C,d))
let(tile=peri_to_tile(peri))
let(assembly=[  
    [[0,0]],
    [[0,2,1],[0,1]],
    [[0,3,1],[0,0]],
    [[0,0],[1,3,1]]
    ])

let(unit=group_tiles([tile],assembly))

let(dx=tile_offset(unit,[0,4],[3,4]))
let(dy=tile_offset(unit,[2,0],[0,2]))
tesselate_tiles(unit,n,m,dx,dy);


