use <../lib/tile_fns-v19.scad>


/* Type 7 Kershner 1968
   b-c=d=e
   B+2E = 2C+D=360
   
   edge-to-edge
   
   parameter  C
      [129,159]  convex
      144.561  is equilateral  see http://web.archive.org/web/20091026142112/http://www.geocities.com/liviozuc/pagesp/nn0a.html
      anomoly at 167 - no solution
   
   solution by secant
   
*/

function secant(xn,xn1,P,eps=0.001,smax=2000,step=0) =
     let(fxn=f(xn,P))
     let(fxn1=f(xn1,P))
     let(x = xn - fxn*(xn - xn1)/ (fxn - fxn1))
     abs(f(x,P) - fxn) < eps
        ? x
        : step < smax
           ? secant(x,xn,P,eps,smax,step+1)
           : undef; 
 
function Type7_partial(B,C) =
    let (p = [[1,B],[1,C],[1,360-2*C],[1,0]])
    let (t= peri_to_tile(p,true))
    tile_to_peri(t);   
    
function f(x,v) = 
    let (p = Type7_partial(x,v[0]))
    let (Ex = 180 - p[0].y/2)
    let (E=p[3].y)
    E-Ex;

function Type7(C) =
    let(B=secant(90,180,[C]))
    shift(Type7_partial(B,C),-1);

function Type7_tiles(C,n,m) =
    
let(peri=Type7(C))
let(tile=mirror_tile(peri_to_tile(peri)))   
let(assembly=[  
    [[0,0]],
    [[0,0,1],[0,0]],
    [[0,2,1],[1,3]],
    [[0,0],[2,0]],
    [[0,1],[1,1]],
    [[0,0,1],[4,0]],
    [[0,1,1],[3,1]],
    [[0,0],[6,0]]
    ])


let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,3],[3,2]))
let(dy=tile_offset(unit,[4,3],[0,1]))
let(tiles= tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));

