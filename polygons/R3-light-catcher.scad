use <../lib/tile_fns.scad>
use <../lib/forms.scad>

B=70;
n=15;
m=15;
inset=0.5;
scale=4;
tiles= R3_tiles(B,n,m);

$fn=100;
  light_circle(90,2)
    fill_tiles(inset_group(scale_tiles(tiles,scale),inset));


    
function R3(B) =
    let(a=sin(120-B)/sin(60))
    let(b=sin(B-60)/sin(60))
    [[1,120],[1,B],[a,120],[a+b,120],[b,180-B]];

function R3_tiles(B,n,m) =
let(peri=R3(B))
let(tile=peri_to_tile(peri))
let(assembly = [
    [[0,0]],
    [[0,0],[0,1]],
    [[0,0],[1,1]]
    ])
let(unit = group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,3],[1,2,1]))  
let(dy = tile_offset(unit,[1,3],[2,2,1]))   
let(tiles=tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));
