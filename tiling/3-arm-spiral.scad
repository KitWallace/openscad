use <../lib/tile_fns.scad>


d2=1/sin(60);

function tri(n) =

  concat(
   [for (i=[0:n-1])
       [(n-i)*d2,i%2==0?300:240]
   ],
   [[d2,n%2==0?120:60]],
   
   [for (i=[0:n])
       [(i+1)*d2,(n+i)%2==0?60:120]
   ],
   [[(n+1)*d2,240]]
   );
   

n=10;
p=tri(n);
m=2*n+3;
side=m-3;

echo (m,side);
// echo(p,len(p));
peri = repeat(p,3);
peri_report(peri);
t=peri_to_tile(peri);
*scale(20) fill_tile(t);

t2=copy_tile_to_edge(t,0,t,side);
tg=[t,t2];
*scale(20) fill_group(tg,["lightsalmon","lavender","palegreen","lightblue"]);
//echo(tg);
dx=-tile_offset(tg,[1,2*m-1],[0,3*m-2]);
dy=tile_offset(tg,[1,m-1],[0,2*m-2]);
echo(dx,dy);
tiles = tesselate_tiles(tg,13,15,dx,dy);
//echo(len(tiles));
scale(20)
fill_group(flatten(tiles),["grey","palegreen","lightsalmon","red","green","blue"]);
