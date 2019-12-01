use <../lib/tile_fns.scad>

/*
  Type 4
  Reinhardt - 1918 
  
  b=c
  d=e
  B=D=90
  
  free variables : C,d
  Cairo tiling 
     C=120
     d=1
     
  solved with closure

*/

function Type4(C,d) =
   let (p =[[1,90],[1,C],[d,90],[d,0]])
   let (t=peri_to_tile(p,true))
   tile_to_peri(t);

function Type4_tiles(C=120,d=1,n=10,m=10) =    
let(peri=Type4(C,d))
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
tesselate_tiles(unit,n,m,dx,dy);
