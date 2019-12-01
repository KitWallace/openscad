use <../lib/tile_fns-v19.scad>

/*  Stein (1985)  
   
    2a=2c=d=e
    A=90
    B ~=145.34
    C ~=69.32
    D ~=124.66
    E ~=110.68
    2B+C=360
    C+E=180
    
    solution by equations
    
*/
function Type14() =
   let(b=sqrt((11*sqrt(57) -25)/8))
   let(A=90)
   let(B=180-asin((sqrt(57) -3 )/8))
   let(C=360-2*B)
   let(E=180-C)
   let(D= 540 - (A+B+C+E))
   let(p=[[b,B],[1,C],[2,D],[2,E],[1,90]])
   p ;

function Type14_tiles(n,m) =   
let(tile=peri_to_tile(Type14()))
let(assembly=[
    [[0,0]],
    [[0,0,1],[0,0]],
    [[0,1],[0,1]],
    [[0,0,1],[2,0]],
    [[0,2,1],[1,3]],
    [[0,0,1],[4,0]]
    ])
let(unit =  group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,4],[5,3,1]))
let(dy=tile_offset(unit,[0,2],[5,1]))
tesselate_tiles(unit,n,m,dx,dy);