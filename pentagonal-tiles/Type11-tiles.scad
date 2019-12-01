use <../lib/tile_fns-v19.scad>

B=150;    

/*  Type 11 Rice 1977
  
    2a+c=d=e
    A=90
    2B+C=360
    C+E=180
    
    parameter  B
      narrow band of B [140.. 158]

    typical value 150
    
    
    solution simplex
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


function Type11_partial(B,b,c)  =
   [[b,B],[c,360-2*B],[2+c,270-B],[2+c,2*B-180],[1,90]];
   
function f(x,V)=
    let (p= Type11_partial(V[0],x[0],x[1]))
    let(t=peri_to_tile(p,true))
    path_error(t);

function Type11_tiles(B,n,m) =
let(params=[B])
let(X0=[[2,2],[1,0.5],[0.5,1]])
let(XV0=simplex_values(X0,params))
let(X=simplex(params,XV0))
let(peri=R11_partial(params[0],X[0],X[1]))
let(tile=peri_to_tile(peri))
let(assembly=[
    [[0,0]],
    [[0,0,1],[0,0]],
    [[0,4,1],[1,4]],
    [[0,0],[2,0]],
    [[0,3],[3,2]],
    [[0,0,1],[4,0]],
    [[0,2,1],[5,2]],
    [[0,0],[6,0]]  
   ])
let(unit=group_tiles([tile],assembly))
let(dx=-tile_offset(unit,[0,3],[3,3]))
let(dy=-tile_offset(unit,[0,2],[7,3]))
tesselate_tiles(unit,n,m,dx,dy);
