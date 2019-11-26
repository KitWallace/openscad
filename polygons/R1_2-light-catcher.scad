use <../lib/tile_fns.scad>
use <../lib/forms.scad>

A=110;
B=110;
c=1.5;

colors=["red","green","blue","yellow"];
n=12;
m=15;
scale=4;
inset=0.5;

tiles=R1_2_tiles(A,B,c,n,m);
//echo(tiles);

$fn=100;
 light_circle(90,2)
  fill_tiles(inset_group(scale_tiles(tiles,scale),inset),colors);

// configuration 2  a=c d=e
      
function R1_2(A,B,c) = 
    let(F=A+B-180)  
    let(b=1) 
    let(a= c/2/cos(F))
    [[b,B],[c,180-B],[b,B+F],[a,540-2*A-2*B],[a,A]];

function R1_2_tiles(A,B,c,n,m) =
let(peri = R1_2(A,B,c))
let(tile =peri_to_tile(peri))
let(assembly=[
    [[0,0]],
    [[0,4,1],[0,1]]
    ])

let(unit=group_tiles([tile],assembly))
let(dy=tile_offset(unit,[0,0],[0,2]))
let(dx=tile_offset(unit,[0,4],[1,2]))
let(tiles= flatten(tesselate_tiles(unit,n,m,dx,dy)))
centre_group(tiles);
