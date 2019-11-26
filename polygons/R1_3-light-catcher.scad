use <../lib/tile_fns.scad>
use <../lib/forms.scad>

colors=["red","green","blue","yellow"];
n=25;
m=10;
scale=4;
inset=0.3;
A=60;
c=0.5;
D=130;
d=0.6;
tiles=R1_3_tiles(A,c,D,d,n,m);
//echo(tiles);

$fn=100;
 light_circle(90,2)
  fill_tiles(inset_group(scale_tiles(tiles,scale),inset),colors);

//  configuration 1 - 3  
//  a=c  
//  A + B = 180
//  C + D + E = 360

function R1_3(A,c,D,d) =
   let(b=1)
   let(Ex = asin(d* sin(D)/b))
   let(Cx=180-D-Ex)
   let(e= b * sin (Cx) / sin(D))
   let(E=180-A +Ex)
   let(C = A+Cx)
   [[b,180-A],[c,C],[d,D],[e,E],[c,A]];

function R1_3_tiles(A,c,D,d,n,m) =
let(peri = R1_3(A,c,D,d))
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
let(tiles= flatten(tesselate_tiles(unit,n,m,dx,dy)))
centre_group(tiles);
