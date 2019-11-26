use <../lib/tile_fns.scad>
use <../lib/forms.scad>

e=0.5;
colors=["Burlywood","salmon","powderblue","teal","peru","Sienna"];
n=10;
m=10;
inset=0.3;
scale=5;
tiles = R10_tiles(e,n,m);
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

function R10_partial(B,e) =
    let (p = [[e,180-B],[1,90],[1,B],[1-e,0]])
    let (t= peri_to_tile(p,true))
    tile_to_peri(t);   

function f(B,v) = 
    let(p = R10_partial(B,v[0]))
    let (EC = 180- B/2)
    p[3].y-EC;

function R10(e) =
   shift(R10_partial(secant(90,180,[e]),e),2);

function R10_tiles(e,n,m) =
let(peri=R10(e))
let(tile=peri_to_tile(peri))
let(assembly= [
     [[0,0]],
     [[0,0],[0,4]],
     [[0,0],[1,4]],
     [[0,0],[2,4]],
     [[0,3,1],[0,2]],
     [[0,3,1],[2,2]]
     ])
let(unit=group_tiles([tile],assembly))
let(dy=-tile_offset(unit,[4,2],[5,2]))
let(dx=-tile_offset(unit,[4,4],[5,4]))

let(tiles =tesselate_tiles(unit,n,m,dx,dy))
centre_group(flatten(tiles));
