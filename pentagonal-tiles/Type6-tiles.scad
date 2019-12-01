use <../lib/tile_fns-v19.scad>


/* Type 6 
   Kershner 1968
   
   a=d=e
   b=c
   B+D=180
   2B=E
   
   parameters : B
   
     B = 1,29 concave, 30-90 convex, 91-141 concave

   solution by trig
   
*/

function Type6(B) =
    let(a=2*sin(B/2)/sqrt(1+4*cos(B/2)*cos(B/2) - 4*cos(B/2)*cos(3*B/2)))
    let(gamma = asin(a*sin(3*B/2)/(2*sin(B/2))))
    let(C= 90 + gamma)    
    [[1,B],[1,C],[a,180-B],[a,2*B],[a,360-2*B-C]];

function Type6_tiles(B,n,m)=
let(peri=Type6(B))
let(tile=peri_to_tile(peri))

let(assembly = [
    [[0,0]],
    [[0,1],[0,1]],
    [[0,1],[1,0]],
    [[0,0],[2,0]]
    ])
let(unit = group_tiles([tile],assembly))

let(dy=tile_offset(unit,[0,0],[3,1]))
let(dx=tile_offset(unit,[0,4],[1,4]))

tesselate_tiles(unit,n,m,dx,dy);
