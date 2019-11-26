use <../lib/tile_fns.scad>
use <../lib/forms.scad>

C=144.561;
n=10;
m=10;
scale=4;
inset=0.4;

tiles= R7_tiles(C,n,m);
//echo(tiles);

$fn=100;
light_circle(90,2)
   fill_tiles(inset_group(scale_tiles(tiles,scale),inset));


function secant(xn,xn1,P,eps=0.001,smax=2000,step=0) =
     let(fxn=f(xn,P))
     let(fxn1=f(xn1,P))
     let(x = xn - fxn*(xn - xn1)/ (fxn - fxn1))
     abs(f(x,P) - fxn) < eps
        ? x
        : step < smax
           ? secant(x,xn,P,eps,smax,step+1)
           : undef; 
 
function R7_partial(B,C) =
    let (p = [[1,B],[1,C],[1,360-2*C],[1,0]])
    let (t= peri_to_tile(p,true))
    tile_to_peri(t);   
    
function f(x,v) = 
    let (p = R7_partial(x,v[0]))
    let (Ex = 180 - p[0].y/2)
    let (E=p[3].y)
    E-Ex;

function R7(C) =
    let(B=secant(90,180,[C]))
    shift(R7_partial(B,C),-1);

function R7_tiles(C,n,m) =
    
//  parameter C 
//     [129,159]  
//     144.561  is equilateral  see http://web.archive.org/web/20091026142112/http://www.geocities.com/liviozuc/pagesp/nn0a.html
// anomoly at 167 - no solution

let(peri=R7(C))
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

