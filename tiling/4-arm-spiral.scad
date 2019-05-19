use <../lib/tile_fns.scad>

/* 4 square spiral arms

*/
function sq_spiral(n) =
   concat(
   [for (i=[1:n-1])
       [n-i,270]
   ],
   [[1,90]],
   [for (i=[1:n])
       [i,90]
   ],
   [[n,270],]
   );
n=60;  
p=sq_spiral(n);
ps =2*n+1;  
peri = repeat(p,4);
//peri_report(peri);
t=peri_to_tile(peri);
//echo(t);
dx=tile_offset([t],[0,0],[0,ps-3]);
dy=tile_offset([t],[0,0],[0,2*ps-3]);
echo(dx,dy);
tiles = tesselate_tiles(inset_group([t],0),15,15,dx,dy);
//echo(len(tiles));
scale(20)
fill_group(flatten(tiles),["red","green","blue","orange","black"]);
