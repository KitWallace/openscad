// basic functions

function zero(n) =
    n==1 ? 0 : [for (i=[0:n-1]) 0];
   
function slice(v,d,i=0) =
     i < len(v) ?  concat([v[i][d]], slice(v,d,i+1) ) : [] ;

function subseq(v,start,end) =
    [for (i=[0:len(v)-1]) if(i>= start && i <= end ) v[i]];
  
function v_sum_r(v,n,k) =
      k > n ? zero(len(v)) : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

function avg(v) =v_sum(v,len(v)) / len(v);

// sort table on column col
function quicksort1(arr,col=0) = 
  !(len(arr)>0) ? [] : 
      let(  pivot   = arr[floor(len(arr)/2)][col], 
            lesser  = [ for (y = arr) if (y[col]  < pivot) y ], 
            equal   = [ for (y = arr) if (y[col] == pivot) y ], 
            greater = [ for (y = arr) if (y[col]  > pivot) y ] 
      ) 
      concat( quicksort1(lesser), equal, quicksort1(greater) );   

/*
   Nelder-Mead downward Simplex method
   https://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method          
   P is  an array of parameter values for f()
   FUX is the Simplex : column 0 are the function values, column 1 the points  
   kmax is the maximum number of iterations 
   eps, alpha,gamma,rho and sigma are parameters of the method set as per Wikipedia
   k is the iteration number
            
   stopping condition is simple test on best value
 */
            
function simplex(P,FUX,kmax=100,eps=0.0000001,alpha=1,gamma=2,rho=0.5,sigma=0.5,k=0) =
   let(FX=quicksort1(FUX))
   let(N=len(FX))
   k < kmax && FX[0][0] >eps  
      ? let(x0 =avg(slice(subseq(FX,0,N-2),1)))
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
      ? undef
      : FX[0][1];

function simplex_values(X,P) =
     [for (i=[0:len(X)-1]) [f(X[i],P),X[i]]];
    
// test function 
function rosenbrock(x)=
   let(N=len(x))
   v_sum([for (i=[1:N-1])
         100 *( pow(x[i] - pow(x[i-1],2),2) + pow(1 -x[i-1],2))],N-1);

function f(x,P) = rosenbrock(x);
  
Init=[[0,0],[0,1],[1,0]]; 
P=[];
x = simplex(P,simplex_values(Init));
echo(x);

    
             
