/*
    Creates a solid 'tube' 
    
    generate the path of the centre of the shape with function pf(t)

    generate the perimeter_points at each step using function lf(t,d)
  
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
              
// generate points on the circumference of the tube  
// using global function pf(d,i) 
// d is position along the centre line
// t is angle around perimeter 
function perimeter_points(d, sides) = 
    [for (i=[0:sides-1]) pf(d, i * 360 /sides)];

// generate the points along the centre of the tube
// using global function cf(d)
// where d is distance along centre line
function centre_points(step,min,max,scale) = 
    hadamardv([for (d=[min:step:max]) cf(d)],scale);

// generate all points on the tube surface  
function tube_points(loop,min,step,sides) = 
    [for (i=[0:len(loop)-1])
       let (m = orient_to(loop[i], loop[(i + 1) % len(loop)] - loop[i]) )
       let (d = min + i * step)
       for (p = perimeter_points(d,sides) )
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
        
module extrude_fun(step,min,max,sides,scale=[1,1,1])  {
// points along the centre line
    centre_points = centre_points(step,min,max,scale);
 //   echo("centre  points",centre_points);
 // points on the exterior of the tube 
    tube_points = tube_points(centre_points,min,step,sides);
//    echo("tube points",tube_points);
    tube_faces = tube_faces(len(centre_points),sides);
    polyhedron(points = tube_points, faces = tube_faces);
}; 

r=10;
h=50;
sides = 50;

// a simple column
function cf(d) = [0,0,d];

// cylinder with linear diminishing radius with sinusoidal x offset 
// vary amplitude and frequency 
// finishes with a radius of 1

function sinf(a,t) =
  (r * (1-a)+1.0 )* [1.5*sin(120*a) + cos(t), sin(t),0];

// the offset is linearly proportional to height
function linearf(a,t) =
  (r * (1-a) * [ 4*a + cos(t),sin(t),0] ) ;

// select active function here
function pf(d,t) =  sinf(d/h,t);

extrude_fun(0.2,0,h,sides);

