use <../lib/tile_fns.scad>
use <../lib/forms.scad>

B=70;
n=1;
m=1;

scale=7;
inset=0.001;
tiles=R6_tiles(B,1,1);
tab=sym_tab(0.5,70,0.1);
tile= inset_tile(scale_tile(tabbed_tile(tiles[0],tab),scale),-0.01);
tess_tiles =
  tesselate_tiles([tile],3,4,
     [9,0,0],[0,9,0]);
fill_tiles(tess_tiles);


// B = 1,29 concave, 30-90 convex, 91-141 concave
// converted OK
function R6(B) =
    let(a=2*sin(B/2)/sqrt(1+4*cos(B/2)*cos(B/2) - 4*cos(B/2)*cos(3*B/2)))
    let(gamma = asin(a*sin(3*B/2)/(2*sin(B/2))))
    let(C= 90 + gamma)    
    [[1,B],[1,C],[a,180-B],[a,2*B],[a,360-2*B-C]];

function R6_tiles(B,n,m)=
let(peri=R6(B))
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

let(tiles= tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));
