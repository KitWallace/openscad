use <../lib/tile_fns-v19.scad>


/* Type 1 Reinhardt variant 2
    a=c 
    d=e
  
  typical vales:
    A=110;
    B=110;
    c=1.5;

      
function Type1_2(A,B,c) = 
    let(F=A+B-180)  
    let(b=1) 
    let(a= c/2/cos(F))
    [[b,B],[c,180-B],[b,B+F],[a,540-2*A-2*B],[a,A]];

function Type1_2_tiles(A,B,c,n,m) =
let(peri = Type1_2(A,B,c))
let(tile =peri_to_tile(peri))
let(assembly=[
    [[0,0]],
    [[0,4,1],[0,1]]
    ])

let(unit=group_tiles([tile],assembly))
let(dy=tile_offset(unit,[0,0],[0,2]))
let(dx=tile_offset(unit,[0,4],[1,2]))
tesselate_tiles(unit,n,m,dx,dy);
