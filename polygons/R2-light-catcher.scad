use <../lib/tile_fns.scad>
use <../lib/forms.scad>
colors=["red","green","blue","yellow"];

b=1;
B=120;
C=140;
d=1;


n=10;
m=10;
scale=5;
inset=0.5;

tiles= R2_tiles(b,B,C,d,n,m);
echo(tiles);
$fn=100;
light_circle(90,2)
  fill_tiles(inset_group(scale_tiles(tiles,scale),inset),colors);

 
function R2(b,B,C,d) =
   let (p =[[b,B],[1,C],[d,180-B],[1,0]])
   let (t=peri_to_tile(p,true))
   tile_to_peri(t);

function R2_tiles(b,B,C,d,n,m) =    
let(peri=R2(b,B,C,d))
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
let(tiles= flatten(tesselate_tiles(unit,n,m,dx,dy)))
centre_group(tiles);


