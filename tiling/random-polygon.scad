//  kit wallace random polygon
// number of sides 
n=5;
// average length of side
side=10;
// % randomness in length of side
length_random_pc=40;
// % randomness in interior angle
angle_random_pc=20;
// tolerance to rounding errors
eps=0;
//  angles 

function angle_between(u, v) = 
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     let (d = cross(u,v).z)
      d  > 0 ? a : 360- a;
               
// vector operations 
function zero(v) =
    len(v) == undef ? 0 : [for (i=[0:len(v)-1]) 0];
   
function slice(v,d,i=0) =
     i < len(v) ?  concat([v[i][d]], slice(v,d,i+1) ) : [] ;
   
function unitv(v)=  v/ norm(v);
   
function v_sum_r(v,n,k) =
      k < n ?  v[k] + v_sum_r(v,n,k+1) : zero(v[0]) ;

function v_sum(v) = v_sum_r(v,len(v),0);
  
function avg(v) =v_sum(v) / len(v);
    
function v_centre(v) =  avg(v);
  
function 3d_to_2d(points)=
    [ for (p=points) [p.x,p.y]];
        
function 2d_to_3d(points)=
    [ for (p=points) [p.x,p.y,0]];

//  perimeter operations   
//  perimeter is  defined as a sequence of length/interior angle pairs, going anticlockwise 

function peri_to_points(peri,pos=[0,0,0],dir=0,i=0) =
    i == len(peri)
      ? [pos]
      : let(side = peri[i])
        let (distance = side[0])
        let (newpos = pos + distance* [cos(dir), sin(dir),0])
        let (angle = side[1])
        let (newdir = dir + (180 - angle))
        concat([pos],peri_to_points(peri,newpos,newdir,i+1)) 
     ;  
        
function peri_to_tile(peri,last=false) = 
    let (p = peri_to_points(peri))  
    last 
       ? [for (i=[0:len(p)-1]) p[i]] 
       : [for (i=[0:len(p)-2]) p[i]]; 

function total_internal(peri) =
      v_sum(slice(peri,1));
       
function isPolygon(peri) =
       let (n = len(peri))
       abs(total_internal(peri) - (n - 2) * 180)<  0.01;
       
function isConvex(peri,i=0) =
   i < len(peri)
     ? peri[i][1] > 0  && peri[i][1] < 180  && peri[i][0] > 0 && isConvex(peri,i+1)
     : true;     
       
// tile operations
    
function tile_to_peri(points) =
    [for (i=[0:len(points)-1])
        let (a = angle_between(
          points[(i+1) % len(points)] - points[i],
          points[(i+2) % len(points)] -  points[(i+1) % len(points)]))
          
       [norm(points[(i+1) % len(points)] - points[i]),
       180-a
       ]
    ] ;
    
// tile to object    
module fill_tile(tile,color="red") {
    color(color)
       polygon(3d_to_2d(tile)); 
};

function random_peri(n,side,lp,ap) =
   let(rs = rands(-1,1,2*n))
   let(lr= side * lp/100 )
   let(angle = 180 - 360 /n)
   let(ar = angle * ap/100)
   let (p1 =
    [for (i=[0:n-2])
        [side + rs[i]*lr, 
         angle + rs[i+n]*ar]
    ])
   let(p2 = tile_to_peri(peri_to_tile(p1,true)))  // close the polygon
   let(ln= p2[n-1][0])
   let(an= p2[n-1][1])
   let(an1= p2[n-2][1])
   isConvex(p2) &&
   isPolygon(p2) &&
       abs (ln - side) < lr + eps  
       && abs (an - angle) < ar + eps  
       && abs (an1 - angle) < ar + eps  
       ? p2
       : random_peri(n,side,lp,ap)
  ;

// main
     
peri = random_peri(n=n,side=side,lp=length_random_pc,ap=angle_random_pc);
echo(peri);
tile= peri_to_tile(peri);
fill_tile(tile);
echo(tile);

