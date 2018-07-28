peri = r_path(n=6,side=5,lp=90,ap=90);
peri_report(peri);
fill_tile(centre_tile(peri_to_tile(peri)));

function r_path(n,side,lp=20,ap=20) =
   let(min_l = side *(1 - lp/100))
   let(max_l = side *(1 + lp/100))
   let(ls = rands(min_l,max_l,n))
   let(angle = 180 - 360 /n)
   let(min_a =  angle *(1 - ap/100))
   let(max_a = angle *(1 + ap/100))
   let(as = rands(min_a,max_a,n))
   let (p1 =
    [for (i=[0:n-2])
        [ls[i], as[i]]
    ])
   let(p2 = tile_to_peri(peri_to_tile(p1,true)))  // close the polygon
   let(ln= p2[n-1][0])
   let(an= p2[n-1][1])
   let(an1= p2[n-2][1])
   isConvex(p2) && isSimple(p2) && isPolygon(p2)
              && (ln >= min_l) &&  (ln <= max_l)  
              && (an >= min_a) &&  (an <= max_a) 
              && (an1 >= min_a) &&  (an1 <= max_a) 
       ? p2
       : r_path(n,side,lp,ap)
  ;


// basic functions
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function depth(a) =
   len(a)== undef 
       ? 0
       : 1 + depth(a[0]);

function signx (x) =
     x==0 ? 1 : sign(x);

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

function subseq(v,start,end) =
    [for (i=[0:len(v)-1]) if(i>= start && i <= end ) v[i]];
        
function reverse(v) = 
     [for (i=[1:len(v)]) v[len(v)-i]];

function shift(v,shift=0) = 
   [for (i=[0:len(v)-1]) v[(i + shift + len(v))%len(v)]];  
       
function unitv(v)=  v/ norm(v);
   
function v_sum_r(v,n,k) =
      k > n ? zero(v[0]) : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

function v_min_r(v,m,i) =
     i < len(v)-1
        ? v[i] < m
           ?  v_min_r(v,v[i],i+1)
           :  v_min_r(v,m,i+1)
        : m ;
function v_min(v) = v_min_r(v,m=v[0],i=1);
 
function v_max_r(v,m,i) =
     i < len(v)-1
        ? v[i] > m
           ?  v_max_r(v,v[i],i+1)
           :  v_max_r(v,m,i+1)
        : m ;
function v_max(v) = v_max_r(v,m=v[0],i=1);
   
function avg(v) =v_sum(v,len(v)) / len(v);
    
function v_centre(v) =  avg(v);
         
function v_scale(v,scale) =
    let(m=m_scale(scale))
    [for (p=v) transform(p,m) ];

function v_rotate(v,angle) =
    let(m=m_rotate([0,0,angle]))
    [for (p=v) transform(p,m)];

function v_translate(v,d) =
    let(m=m_translate(d))
    [for (p=v) transform(p,m)];
        
function bounding_box(points) =
    [[max(slice(points,0))- min(slice(points,0)),min(slice(points,0)), max(slice(points,0)),

        min([for (p=points) p.x <0  ? -p.x:9999999]) ,
        max([for (p=points) p.x>0 ? p.x:0])   ], 
     [max(slice(points,1))- min(slice(points,1)),min(slice(points,1)), max(slice(points,1))]
    ];  
        
function 3d_to_2d(points)=
    [ for (p=points) [p.x,p.y]];
        
function 2d_to_3d(points)=
    [ for (p=points) [p.x,p.y,0]];


// general turtle commands
// recursion limits are a problem here - can this be written non-recursively or to exploit tail recusion
    
function turtle_path(steps,pos=[0,0,0],dir=0,i=0) =
   i == len(steps)
      ? [[pos,dir]]
      : let(step = steps[i], command=step[0])
        command=="F"
          ? let (distance = step[1])
            let (newpos = pos + distance* [cos(dir), sin(dir),0])
            concat([[pos,dir]],turtle_path(steps,newpos,dir,i+1)) 
          : command=="L" 
            ?  let (angle = step[1])
               turtle_path(steps,pos,(dir+angle) % 360,i+1)
            : command=="R"
               ? let (angle = step[1])
                 turtle_path(steps,pos,dir-angle,i+1)
               : turtle_path(steps,pos,dir,i+1)
     ;       

//  perimeter operations   
//  perimeter is  defined  either 
//     as a sequence of length/interior angle pairs, going anticlockwise 
//    or for an equilateral figure, just the list of angles, going anticlockwise 

function norm_peri(peri) =
     [for (p=peri)
        len(p)==undef
           ? [1,p]
           :[p.x,p.y] 
     ];
function scale_peri(scale,peri) =
   [for (p=peri)
        len(p)==undef
           ? [scale,p]
           :[scale * p[0],p[1]] 
   ];
   
function rotate_tile(t,a) = v_rotate(t,a);

function translate_tile(t,d) =
      [for (p=t) p+d];      
function centre_tile(t) =
    let(c = v_centre(t))
    translate_tile(t,-c);
  
function peri_to_turtle(peri) =
    flatten([for (p=peri)
        len(p)==undef
           ?  [["F",1],["L",p]]
           :  [["F",p.x],["L",p.y]]
    ]);

function peri_to_turtle_int(peri) =
    flatten([for (p=peri)
        len(p)==undef
           ?  [["F",1],["L",180-p]]
           :  [["F",p.x],["L",180-p.y]]
    ]);
 
function int_to_ext(peri) =
    [for (p=norm_peri(peri)) [p.x,180-p.y]];

function ext_to_int(peri) = int_to_ext(peri);
    

function isConvex(peri,i=0) =
   i<len(peri)
     ? peri[i].y > 0  && peri[i].y < 180  && peri[i].x > 0 && isConvex(peri,i+1)
     : true;

function total_internal(peri) =
     v_sum(slice(peri,1),len(peri));

function total_external(peri) =
     let (eperi = int_to_ext(peri))
     v_sum(slice(eperi,1),len(eperi));
      
function isPolygon(peri,eps=0.001) =
     abs(total_external(peri) - 360)< eps;
       
function peri_to_tile(peri,last=false) = 
    let (p =turtle_path(peri_to_turtle_int(peri)))  
    last 
       ? [for (i=[0:len(p)-1]) p[i][0]] 
       : [for (i=[0:len(p)-2]) p[i][0]]; 

function peri_end(peri) =
    let(t=peri_to_tile(peri,true))
    t[len(t)-1];
       
function peri_last(peri) =
    let(t=peri_to_tile(peri,true))
    let (d= norm(t[len(t)-1]))
    let (a=peri[len(peri)-1].y)
    [d,a];

function peri_error(peri) = 
    norm(peri_end(peri));

function CCW(p1, p2, p3) =
    (p3.y - p1.y) * (p2.x - p1.x) > (p2.y - p1.y) * (p3.x - p1.x);

function isIntersecting(p1, p2, p3, p4) =
   ( CCW(p1, p3, p4) != CCW(p2, p3, p4)) && (CCW(p1, p2, p3) != CCW(p1, p2, p4));
 
function isSimple (peri) =
    let(t = peri_to_tile(peri))
    let(v = flatten([for (i=[0:len(t)-2])
        if (i + 2 < len(t) - 2)
         flatten( [for (j=[i+2:len(t) -2])
              if( isIntersecting(t[i],t[(i+1)%len(t)],t[j],t[(j+1)%len(t)]))
               1])
          ]))
     v_sum(v,len(v)) == 0;

function isComplete(peri,eps=0.001) = abs (total_external(peri) - 360) < eps;
              
module peri_report(peri,name="Peri",eps=0.000001) {
  echo(" ");
  echo("Name",name);
  echo("Perimeter",peri);
  echo("Sides",len(peri));
  echo("Convex",isConvex(peri));
  echo("Complete",isPolygon(peri),total_external(peri));
  echo("Closed", peri_error(peri) < eps,peri_error(peri));
  echo("Simple", isSimple(peri));
};   
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
    

// tile to objects    
module fill_tile(tile,color="red") {
    color(color)
       polygon(3d_to_2d(tile)); 
};


