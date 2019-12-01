use <../lib/tile_fns.scad>

/* Type 9  Marjorie Rice

    b=c=d=e
    
    2A+C = D+2E = 360
    
    edge-to-edge
    
   parameter  a 
      (0, 0.94)    convex
      typical value 0.4
      
   solution by closure then simplex
   
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

function Type9_partial(a,A,B) =
     [[1,B],[1,360-2*A],[1,2*A-2*B],[1,180 + B-A],[a,A]];

function f(x,P) = 
    let(p = Type9_partial(P[0],x[0],x[1]))
    let(t=peri_to_tile(p,true))
    path_error(t);

function Type9(a) =
    let(X0= [[90,90],[120,90],[90,120]])
    let(XV=simplex_values(X0,[a]))     
    let(x=simplex([a],XV))
    Type9_partial(a,x[0],x[1]); 

function Type9_tiles(a,n,m) =
let(peri=Type9(a))   
let(tile=peri_to_tile(peri)) 
let (assembly=[
    [[0,0]],
    [[0,1,1],[0,4]],
    [[0,3],[0,3]],
    [[0,2,1],[0,2]],
    [[0,1],[2,0]],
    [[0,1,1],[4,4]],
    [[0,3,1],[4,3]],
    [[0,4],[6,1]]
    ])

let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,1],[2,1]))
let(dy=tile_offset(unit,[0,0],[7,1]))
tesselate_tiles(unit,n,m,dx,dy);
