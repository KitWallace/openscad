use <../lib/tile_fns-v19.scad>

/*
  Type 3 Reinhardt
  
  a=b
  d=c=e
  A=C=D=120
  
  parameter  B 
  
  typical values
    B=70;


*/
    
function Type3(B) =
    let(a=sin(120-B)/sin(60))
    let(b=sin(B-60)/sin(60))
    [[1,120],[1,B],[a,120],[a+b,120],[b,180-B]];

function Type3_tiles(B,n,m) =
let(peri=Type3(B))
let(tile=peri_to_tile(peri))
let(assembly = [
    [[0,0]],
    [[0,0],[0,1]],
    [[0,0],[1,1]]
    ])
let(unit = group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,3],[1,2,1]))  
let(dy = tile_offset(unit,[1,3],[2,2,1]))   
tesselate_tiles(unit,n,m,dx,dy);

