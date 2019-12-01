use <../lib/tile_fns-v19.scad>

/*

  Type 10  James 1975
     a = b = c + e
     A = 90
     B + E = 180
     B + 2C = 360
  
    
    solutiuon by secant
  
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

function Type10_partial(B,e) =
    let (p = [[e,180-B],[1,90],[1,B],[1-e,0]])
    let (t= peri_to_tile(p,true))
    tile_to_peri(t);   

function f(B,v) = 
    let(p = Type10_partial(B,v[0]))
    let (EC = 180- B/2)
    p[3].y-EC;

function Type10(e) =
   shift(Type10_partial(secant(90,180,[e]),e),2);

function Type10_tiles(e,n,m) =
let(peri=Type10(e))
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
tesselate_tiles(unit,n,m,dx,dy);
