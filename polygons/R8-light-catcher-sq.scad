use <../lib/tile_fns.scad>
use <../lib/forms.scad>

n=10;m=10;
inset=0.3;
scale=4;

B=120;
tiles=R8_tiles(B,n,m);
//echo(tiles);
$fn=100;
light_square(90,2)
   fill_tiles(inset_group(scale_tiles(tiles,scale),inset));

function secant(xn,xn1,P,eps=0.001,smax=200,step=0) =
     let(fxn=f(xn,P))
     let(fxn1=f(xn1,P))
     let(x = xn - fxn*(xn - xn1)/ (fxn - fxn1))
     abs(f(x,P) - fxn) < eps
        ? x
        : step < smax
           ? secant(x,xn,P,eps,smax,step+1)
           : undef; 
                   
//R8  solved with secant
function R8_partial(B,D) =
    let( p= [[1,B],[1,360-2*B],[1,D],[1,(360-D)/2]])
    let (t= peri_to_tile(p,true))
    tile_to_peri(t);   

function f(D,V) =
    let(B=V[0])
    let (p=R8_partial(B,D))
    let (EE=(360-D)/2)
    let(E=p[3].y)
    E-EE;
    
function R8(B) =
    let(D=secant(0,180,[B]))
    R8_partial(B,D);
    
function R8_tiles(B,n,m) =
//  B = (90 , 180)  convex

let(peri=R8(B))
let(tile=peri_to_tile(peri))
let(assembly = [
   [[0,0]],
   [[0,1],[0,1]],
   [[0,1,1],[1,4]],
   [[0,1],[0,0]],
   [[0,1,1],[3,4]],
   [[0,4,1],[4,4]],
   [[0,0,1],[5,3]],
   [[0,3],[3,3]]
   ])  

let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,2],[7,0]))
let(dy=tile_offset(unit,[0,4],[6,1]))
let(tiles=tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));