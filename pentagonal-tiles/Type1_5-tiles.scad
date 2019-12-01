use <../lib/tile_fns.scad>

/* Reinhardt Type  1  variant 5
  d = c + e
  A = 90
  C + D = 180
  2B + C = 360
  B + E = 270
  
  solved by simplex 
  perimeter wrong angles greater than 360 (460)
   but tiling is working?
   
  
*/


function simplex(P,FUX,kmax=100,eps=0.000001,alpha=1,gamma=2,rho=0.5,sigma=0.5,k=0) =
   let(FX=quicksort1(FUX))
   let(N=len(FX))
   k < kmax && FX[0][0] >eps  
      ? let(x0 =v_avg(slice(subseq(FX,0,N-2),1)))
        let(xr = x0 +  alpha* (x0 - FX[N-1][1]))
        let(Fxr=f(xr,P))
        FX[0][0] <= Fxr && Fxr < FX[N-2][0]
           ?  let(FXp = concat(subseq(FX,0,N-2),[[Fxr,xr]]))
              simplex(P,FXp,kmax,eps,alpha,gamma,rho,sigma,k+1)
           :  Fxr < FX[0][0]              
                ?  let(xe = x0+gamma*(xr-x0))
                   let(Fxe=f(xe,P))
                   Fxe < Fxr
                   ? let(FXp = concat(subseq(FX,0,N-2),[[Fxe,xe]]))
                     simplex(P,FXp,kmax,eps,alpha,gamma,rho,sigma,k+1)
                   : let(FXp = concat(subseq(FX,0,N-2),[[Fxr,xr]]))
                     simplex(P,FXp,kmax,eps,alpha,gamma,rho,sigma,k+1)
                : let(xc=x0+rho*(FX[N-1][1] - x0))
                  let(Fxc=f(xc,P))
                  Fxc < FX[N-1][0]
                     ? let(FXp = concat(subseq(FX,0,N-2),[[Fxc,xc]]))
                        simplex(P,FXp,kmax,eps,alpha,gamma,rho,sigma,k+1) 
                     :  let (x1=FX[0][1])
                        let(FXp = concat([FX[0]],
                                     [for (i=[1:N-1]) 
                                      let (x= x1 + sigma*(FX[i][1]- x1))
                                      [f(x,P),x]
                                     ]
                                     ))
                        simplex(P,FXp,kmax,eps,alpha,gamma,rho,sigma,k+1) 
   : k==kmax
      ? FX
      : FX[0][1];

function simplex_values(X,P) =
     [for (i=[0:len(X)-1]) [f(X[i],P),X[i]]];
          
function Type1_5_partial(C,b,c,d) =
    [[1,90],[b,180 - C/2],[c,C],[d,180-C],[d-c,90-C/2]];
    
function f(x,P) = 
    let(p = Type1_5_partial(P[0],P[1],x[0],x[1]))
    peri_error(p);

function Type1_5(C,b) =
    let(Init= [[0.5,0.5],[1,0.5],[0.5,1]])
    let(XV=simplex_values(Init,[C,b]))
    let(x=simplex([C,b],XV))
    Type1_5_partial(C,b,x[0],x[1]); 

function Type1_5_tiles(C,b,n,m) =     
let(peri=Type1_5(C,b))

let(tile=peri_to_tile(peri))
let(assembly=[
     [[0,0]],
     [[0,0,1],[0,0]],
     [[0,4,1],[0,1]],
     [[0,0],[2,0]]
     ])
let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,4],[3,4]))
let(dy=tile_offset(unit,[0,2],[3,2]))
tesselate_tiles(unit,n,m,dx,dy);


