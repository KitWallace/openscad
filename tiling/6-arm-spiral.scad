use <../lib/tile_fns.scad>

function copy_tile_to_edges2(source,i,target,j,m,n) =
     [for (k=[0:n-1])
          copy_tile_to_edge(source,i,target,k*m+j)
     ] 
     ; 
     
function equi_spiral(n) = 
let (d1=1/tan(30))
let (d2=1/sin(60))
let (d3=1/tan(60))
     
concat(
  [for(i=[1:n])
     [d2+(2*(n-i)+1)*d1+d3,300]
  ],
  [[d2,120],[d2,60]],
   [for (i=[1:n])
     [d2+(2*i-1)*d1+d3,60]
  ],
  [[2*n*d1+d3,300]]
);
   
n=6;
nl=2*n+3;
ns=nl-2;
echo(n,nl,ns);
p2=equi_spiral(n);
echo(p2,len(p2));
peri = repeat(p2,6);
peri_report(peri);
t=peri_to_tile(peri);
echo(t);
dx=tile_offset([t],[0,0],[0,ns]);
dy=tile_offset([t],[0,0],[0,nl+ns]);
echo(dx,dy);
tiles = tesselate_tiles(inset_group([t],0),14,15,dx,dy);
echo(len(tiles));
scale(20)
fill_group(flatten(tiles),["red","green","blue","black"]);

