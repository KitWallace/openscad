use <../lib/tile_fns-v19.scad>


/*
   Type 12 Rice 
   
   2a=d=c+e
   A=90
   2B+C=360
   C+E=180

   Parameter C
   
      Typical value C=60
      
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

function Type12_partial(C,b,e) =
    let(c=1)
    let(d=c+e)
    let(D=90+C/2)
    let(a= d/2)   
    [[b,180-C/2],[c,C],[d,D],[e,180-C],[a,90]];

function Type12(C) =
     let(x0=[[0.1,0.1],[1,0.1],[0.1,1]])
     let(XV=simplex_values(x0,[C]))
     let(x=simplex([C],XV))
     Type12_partial(C,x[0],x[1]);

function f(x,P) =
    let(b=x[0])
    let(e=x[1])
    let(C=P[0])
    let(p=Type12_partial(C,b,e))
    let(t=peri_to_tile(p,true))
    path_error(t);

function Type12_tiles(C,n,m) =
let(peri=Type12(C))
let(tile=peri_to_tile(peri))
let(assembly = [
  [[0,0]],
  [[0,0,1],[0,0]],
  [[0,1],[0,1]],
  [[0,0,1],[2,0]],
  [[0,2],[0,4]],
  [[0,3,1],[4,1]],
  [[0,0],[5,0]],
  [[0,0,1],[4,0]]      
  ])
  
let(unit = group_tiles([tile],assembly))
let(dx=tile_offset(unit,[7,3],[3,2,1]))
let(dy=tile_offset(unit,[0,3],[2,3]))
tesselate_tiles(unit,n,m,dx,dy);
