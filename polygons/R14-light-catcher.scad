use <../lib/tile_fns.scad>
use <../lib/forms.scad>

colors=["red","green","yellow","blue","lightblue","orange","purple","gray"];
n=10;m=10;
inset=0.5;
scale=2.5;

$fn=100;
tiles=R14_tiles(n,m);
// echo(tiles);
light_circle(90,2)
   fill_tiles(inset_group(scale_tiles(tiles,scale),inset));


//  Stein (1985)  
function R14() =
   let(b=sqrt((11*sqrt(57) -25)/8))
   let(A=90)
   let(B=180-asin((sqrt(57) -3 )/8))
   let(C=360-2*B)
   let(E=180-C)
   let(D= 540 - (A+B+C+E))
   let(p=[[b,B],[1,C],[2,D],[2,E],[1,90]])
   p ;

function R14_tiles(n,m) =   
let(tile=peri_to_tile(R14()))
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

let(tiles=flatten(tesselate_tiles(unit,n,m,dx,dy)))
centre_group(tiles);