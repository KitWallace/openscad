use <../lib/tile_fns.scad>

/*  Type 1 Reinhardt variant  3  

    a=c  
    A + B = 180
    C + D + E = 360
    
    solved by trig
    
*/

function Type1_3(A,c,D,d) =
   let(b=1)
   let(Ex = asin(d* sin(D)/b))
   let(Cx=180-D-Ex)
   let(e= b * sin (Cx) / sin(D))
   let(E=180-A +Ex)
   let(C = A+Cx)
   [[b,180-A],[c,C],[d,D],[e,E],[c,A]];

function Type1_3_tiles(A,c,D,d,n,m) =
let(peri = Type1_3(A,c,D,d))
let(tile =peri_to_tile(peri))
let(assembly=[
     [[0,0]],
     [[0,0,1],[0,0]],
     [[0,2,1],[1,2]],
     [[0,0],[2,0]]
    ])
let(unit=group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,4],[0,1]))
let(dy=tile_offset(unit,[0,3],[3,3]))
tesselate_tiles(unit,n,m,dx,dy);

