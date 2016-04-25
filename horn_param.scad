/*
    Creates a solid 'tube' 
    
    generate the path of the centre of the shape with function cf(cparams,t)
       where cparams is a scalar or vector to parameterise the function 

    generate the perimeter_points at each step using function pf(pparams,t,d)
      where pparams is a scalar or vector to parameterise the function 
 
*/

function m_translate(v) = [ [1, 0, 0, 0],
                            [0, 1, 0, 0],
                            [0, 0, 1, 0],
                            [v.x, v.y, v.z, 1  ] ];
                            
function m_rotate(v) =  [ [1,  0,         0,        0],
                          [0,  cos(v.x),  sin(v.x), 0],
                          [0, -sin(v.x),  cos(v.x), 0],
                          [0,  0,         0,        1] ]
                      * [ [ cos(v.y), 0,  -sin(v.y), 0],
                          [0,         1,  0,        0],
                          [ sin(v.y), 0,  cos(v.y), 0],
                          [0,         0,  0,        1] ]
                      * [ [ cos(v.z),  sin(v.z), 0, 0],
                          [-sin(v.z),  cos(v.z), 0, 0],
                          [ 0,         0,        1, 0],
                          [ 0,         0,        0, 1] ];
                            
function vec3(v) = [v.x, v.y, v.z];
function transform(v, m)  = vec3([v.x, v.y, v.z, 1] * m);

// matrix to orient from centre in direction normal
function orient_to(centre,normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
    * m_translate(centre);

//  vector product functions for point scaling
function hadamard(a,b) =
       len(a)==len(b)
           ?  [for (i=[0:len(a)-1]) a[i]*b[i]] 
           :  [];
        
function hadamardv(v,s) =
      [for (p = v) hadamard(p,s)];


// generate the points along the centre of the tube
// using global function cf(cparams,d)
// where cparams are parmeters to control the behaviour of cf
// and d is distance along centre line
function centre_points(p,step,min,max,scale) = 
    hadamardv([for (d=[min:step:max]) cf(p,d)],scale);
        
// generate points on the perimeter of the tube  
// using global function pf(pparms,d,i) 
// pparams are parmeters to control the behaviour of pf
// d is position along the centre line
// t is angle around perimeter 
function perimeter_points(pparams,d, sides) = 
    [for (i=[0:sides-1]) pf(pparams,d, i * 360 /sides)];

// generate all points on the tube surface  
function tube_points(pparams,loop,min,step,sides) = 
    [for (i=[0:len(loop)-1])
       let (m = orient_to(loop[i], loop[(i + 1) % len(loop)] - loop[i]) )
       let (d = min + i * step)
       for (p = perimeter_points(pparams,d,sides) )
          transform(p,m)
    ];
       
// generate the faces of the tube surface 
function tube_faces(segs, sides, open=true) = 
   open 
     ?  concat(
         [[for (j=[sides - 1:-1:0]) j ]],
         [for (i=[0:segs-3]) 
          for (j=[0:sides -1])  
             [ i * sides + j, 
               i * sides + (j + 1) % sides, 
              (i + 1) * sides + (j + 1) % sides, 
              (i + 1) * sides + j
             ]
        ] ,   
        [[for (j=[0:1:sides - 1]) (segs-2)*sides  + j]]
        )
     : [for (i=[0:segs]) 
        for (j=[0:sides -1])  
         [ i * sides + j, 
          i * sides + (j + 1) % sides, 
          ((i + 1) % segs) * sides + (j + 1) % sides, 
          ((i + 1) % segs) * sides + j
         ]   
       ]  
     ;
function sign(x) =  x > 0 ? +1 : -1;
function sq(a) = a*a;
        
module extrude_fun(cparams,pparams,step,min,max,sides,open=true,scale=[1,1,1])  {
// points along the centre line
    centre_points = centre_points(cparams,step,min,max,scale);
    echo("centre  points",centre_points);
 // points on the exterior of the tube 
    tube_points = tube_points(pparams,centre_points,min,step,sides);
//    echo("tube points",tube_points);
    tube_faces = tube_faces(len(centre_points),sides);
    polyhedron(points = tube_points, faces = tube_faces);
}; 

r=10;
h=50;
sides = 50;


// a simple column
function straightcolf(p,d) = [0,0,d];

// a curved column  need to tilt here to level base and avoid gliche in surface generation
function sincolf(p,d) = 
    let (a = 40)  // should be able to compute this
    transform([0,20*sin(120*d/p),d],m_rotate([a,0,0])); 

// select active centre function 
function cf(p,d) = sincolf(p,d);

//  dimininsh radius of circle proportional to height - min radius is p/10
function circlef(r,a,t) =
  (r * (1-a) + r/10) * [ cos(t),sin(t),0];

// parametric teardrop curve
function teardropf(r,a,t) =
  let (m=a*10)
  r* [cos(t),sin(t) * pow(sin(t/2),m),0];
 
 // lame curves
function lamef(r,a,t) =
   let(n=a*3+0.5)
   r * (1- a + 0.5) * [ pow(abs(cos(t)),2/n) * sign(cos(t)),
     pow(abs(sin(t)),2/n) * sign(sin(t)),
    0 ];   
    
// select active function here
function pf(p,d,t) = lamef(p,d/h,t);

difference(){
   extrude_fun(50,10,1,0,h,sides);
   translate([0,0,-0.02]) extrude_fun(50,7,1,0,h+1,sides);
}
