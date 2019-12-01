use <../lib/tile_fns-v19.scad>


/*
    Type 13  Rice
    
    d=2a=2e
    B=E=90
    2A+D=360
    
    
    parameter A 
       91-116  convex , 44-90 concave
      eg  110

    solution secant
*/

function secant(xn,xn1,P,eps=0.001,smax=200,step=0) =
     let(fxn=f(xn,P))
     let(fxn1=f(xn1,P))
     let(x = xn - fxn*(xn - xn1)/ (fxn - fxn1))
     abs(f(x,P) - fxn) < eps
        ? x
        : step < smax
           ? secant(x,xn,P,eps,smax,step+1)
           : undef; 
                   
function Type13_partial(A,b) =
    let (p = [[2,360-2*A],[1,90],[1,A],[b,0]])
    let (t= peri_to_tile(p,true))
    let (tp =tile_to_peri(t))  
    tp;
    
function f(x,v) = 
    let(p = Type13_partial(v[0],x))
    p[3].y - 90;

function Type13(A) =
     let(b=secant(0.1,2,[A]))
     let(peri=Type13_partial(A,b))
     shift(peri,3);

function Type13_tiles(A,n,m)=
let(peri=Type13(A))
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
tesselate_tiles(unit,n,m,dx,dy);
