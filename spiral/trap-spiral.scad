use <../lib/basics.scad>
use <../lib/tile.scad>
use <../lib/svg.scad>
use <../lib/poly.scad>

/*from

 Robert Frathauer
 
 https://href.li/?https://twitter.com/RobFathauerArt/status/1362790000111230977
 
*/
function simplex(P,FUX,kmax=100,eps=0.0001,alpha=1,gamma=2,rho=0.5,sigma=0.5,k=0) =
   let(FX=quicksort1(FUX))
   let(N=len(FX))
   k < kmax && FX[0][0] >eps  
      ? let(x0 = l_avg(slice(subseq(FX,0,N-2),1)))
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
     [for (x=X) [f(x,P),x]];

function trap_partial(A,b,s,N) =
   let ( D= 360/N +180 - A)
   [[1,A],[b,180-A],[pow(s,N),180-D],[b*s,D]];

function f(x,P) = 
    let(p = trap_partial(x[0],x[1],P[0],P[1]))
    let(t=peri_to_tile(p,true))
    path_error(t);

function trap_peri(s,N,init) =   
    let(finit=simplex_values(init,[s,N]),
       x=simplex([s,N],finit))
     trap_partial(x[0],x[1],s,N);
     
function spiral_tiles (t,s,k) =
   k >0 
     ? let (
        t1=scale_tile(t,s),
        t2=copy_tile_to_edge(t1,1,t,3))
       concat([t],spiral_tiles(t2,s,k-1))
     : [];
     
   
s=1.05;
N=3;   
P=[s,N];
init=[[120,0.2],[130,0.6],[120,0.6]];
p= trap_peri(s,N,init);
peri_report(p);
t=peri_to_tile(p,false);
//fill_tile(t);

ntiles=100;
scale=1;
rotation= 180;
h=1;
//colors=["Fuchsia","MediumOrchid","Orchid","Violet","Plum","Thistle","Lavender"];
colors=["Red","green"];
tiles = spiral_tiles(rotate_points(scale_tile(t,scale),rotation),s,ntiles);
fill_tiles(tiles,colors);
*for (i = [0:len(tiles)]) {
       linear_extrude(height=h*i) fill_tile(tiles [i]);
}


  box=bounding_box_3d(flatten(tiles));
  echo(box);
  svg = str(
    start_svg(box,"quad_spiral"),
    polygons_to_svg(tiles,colors),
    end_svg()
   );
    
  echo(svg);


