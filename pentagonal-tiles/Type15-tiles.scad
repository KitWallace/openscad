use <../lib/tile_fns-v19.scad>


/*   Type 15  Mann/McLoud/VonDerau 2015

     a=c=e
     b=2a
     d=a+sqrt(2)/(sqrt(3)-1)
     A=150
     B=60
     C=135
     D=105
     E=90
     
     no parameters

*/
function Type15() =
   let(d=sqrt(2+sqrt(3)))
   [[d,105],[1,90],[1,150],[2,60],[1,135]];
   
function Type15_tiles(n,m) =
let(tile =peri_to_tile(Type15()))
let(assembly= [
    [[0,0]],
    [[0,4,1],[0,4]],
    [[0,0,1],[0,0]],
    [[0,4,1],[2,3]],
    [[0,0],[3,0]],
    [[0,2],[4,4]],
    [[0,4],[5,4]], 
    [[0,4],[6,2]],
    [[0,1,1],[6,1]],
    [[0,3,1],[8,4]],
    [[0,0],[9,0]],
    [[0,4,1],[10,4]]
    ])
    
let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,3],[1,2]))
let(dy=tile_offset(unit,[1,0],[11,0]))
tesselate_tiles(unit,n,m,dx,dy);