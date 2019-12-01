use <../lib/tile_fns-v19.scad>

/*   Type 1 Reinhardt - variant  4
     a=e
     B + C = 180
     A + D + E = 360  
     
     solved by trig then secant
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

function Type1_4_partial(c,A,b,B,E) =
   let(C=180-B)
   let(D=360-A-E)
   let(a=1)
   let(e=1)
   let(AD= 2*a * sin(E/2))
   let(A1= (180-E)/2)
   let(D1=A1)
   let(D2=D-D1)
   let(AC= sqrt(b*b+c*c-2*b*c*cos(B)))
   let(A3= asin(c*sin(B)/AC))
   let(A2=A-A1-A3)
   let(d=AC*sin(A2)/sin(D2))  
   [[d,D],[e,E],[a,A],[b,B],[c,C]];


function f(x,P) =
      let(p=Type1_4_partial(x,P[0],P[1],P[2],P[3]))
      peri_error(p);

function Type1_4(A,b,B,E) =   
     let(P=[A,b,B,E])
     let(c=secant(0.1,2,P))
     let(p=Type1_4_partial(c,A,b,B,E))
     shift(p,-1);

function Type1_4_tiles(A,b,B,E,n,m) =
let(peri=Type1_4(A,b,B,E))
let(tile =peri_to_tile(peri))

let(assembly=[
    [[0,0]],
    [[0,0],[0,0]],
    [[0,3,1],[0,3]],
    [[0,0,1],[2,0]]
    ])
let(unit=group_tiles([tile],assembly))
let(dx=tile_offset(unit,[0,2],[2,2]))
let(dy=tile_offset(unit,[1,2],[3,2]))
tesselate_tiles(unit,n,m,dx,dy);

