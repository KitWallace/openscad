use <../lib/tile_fns.scad>
use <../lib/forms.scad>

colors=["red","green","yellow","blue","lightblue","orange","purple","gray"];
n=20;m=20;
inset=0.2;
scale=2.5;
A=110;  //  91-116  convex , 44-90 concave
tiles = R13_tiles(A,n,m);
$fn=100;
light_circle(90,2)
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
                   
function R13_partial(A,b) =
    let (p = [[2,360-2*A],[1,90],[1,A],[b,0]])
    let (t= peri_to_tile(p,true))
    let (tp =tile_to_peri(t))  
    tp;
    
function f(x,v) = 
    let(p = R13_partial(v[0],x))
    p[3].y - 90;

function R13(A) =
     let(b=secant(0.1,2,[A]))
     let(peri=R13_partial(A,b))
     shift(peri,3);

function R13_tiles(A,n,m)=
let(peri=R13(A))
let(tile=peri_to_tile(peri))
let(assembly=[
    [[0]],
    [[0,0,1],[0,0]],
    [[0,3,1],[1,3]],
    [[0,0],[2,0]],
    [[0,4],[3,3]],
    [[0,0,1],[4,0]], 
    [[0,2],[4,2]],
    [[0,0,1],[6,0]]
    ])

let(unit=group_tiles([tile],assembly))

let(dx=-tile_offset(unit,[0,1],[2,4]))
let(dy=tile_offset(unit,[0,3],[6,4]))

let(tiles=tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));



