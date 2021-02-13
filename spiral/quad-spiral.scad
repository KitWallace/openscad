use <../lib/solvers.scad>
use <../lib/tile.scad>
use <../lib/svg.scad>
use <../lib/poly.scad>

/*
from
 Robert Fraternaur
 
   https://twitter.com/RobFathauerArt/status/1360248744021618692



*/
function secant(xn,xn1,C,n,s,eps=0.001,smax=200,step=0) =
     let(fxn=f(xn,C,n,s))
     let(fxn1=f(xn1,C,n,s))
     let(x = xn - fxn*(xn - xn1)/ (fxn - fxn1))
     abs(f(x,C,n,s) - fxn) < eps
        ? x
        : step < smax
           ? secant(x,xn,C,n,s,eps,smax,step+1)
           : undef; 

function make_quad(a,C,n) = 
let(
   c=1,
   A= (180 + C) /n, 
   B= 180 - C,
   D= 180 - A,
   tri_1 = triangle_SAS(a,D,c),
//echo (tri_1);
   l=tri_1[1][0],
   B1=tri_1[0][1],
   C1=tri_1[1][1],

   B2=B-B1,
   C2=C-C1,
//echo (B2,C2);
   tri_2=triangle_ASA(B2,l,C2),
//echo(tri_2);
   d=tri_2[0][0],
   b=tri_2[2][0])

   [[a,C],[b,A],[d,B],[c,D]];
;

function f(a,C,n,s) = 
let (peri=make_quad(a,C,n),
     b=peri[1][0],
     d=peri[2][0],
     c=peri[3][0],
     dr=b*s+a*pow(s,n+1)+c*pow(s,n))
     d-dr;

function spiral_tiles (t,s,inset,k) =
   k >0 
     ? let (
        t1=scale_tile(t,1/s),
        t2=copy_tile_to_edge(t1,2,t,1))
       concat([inset_tile(t,inset)],spiral_tiles(t2,s,inset/s,k-1))
     : [];

// parameters
C=165;
s=0.96;
n=5;
scale=1;
inset = 0.0;
ntiles=100;
colors=["darkred","red","firebrick","crimson","lightcoral"];

test=false;

// make quad
a= secant(1,0.1,C,n,s);
peri = make_quad(a,C,n);
t1= scale_tile(peri_to_tile(peri),scale);

//output
if (test) {
  peri_report(peri);
  fill_tile(t1);
}

else {
  tiles = spiral_tiles(t1,s,inset,ntiles);
  fill_tiles(tiles,colors);

  box=bounding_box_3d(flatten(tiles));

  svg = str(
    start_svg(box,"quad_spiral"),
    polygons_to_svg(tiles,colors),
    end_svg()
   );
    
  echo(svg);
}
