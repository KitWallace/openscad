// generate designs with muliple interlocking rings

Ring_r = 3;  // Radius of Ring
wiggle=0.2;  // amplitude of wiggle in ring
n=3;         // Number of rings

Sides=24;  // number of sides of rope - must be a divisor of 360
Scale=5;   // overall scale
Step=2;    // step size in degrees 0.5 for final print
R=0.2;     // rope radius

Depth = 1;   // depth of recusion
Offset_ratio = 0.7;  // 

scale(Scale)
    links(n,Step,R,Sides,Ring_r,Depth,offset=Offset_ratio,centre=false); 

function f(t) =  // figure eight
// Ring_r, wiggle and n are global 
      [   Ring_r * cos(t) ,
          Ring_r * sin(t) ,
          wiggle * cos(n*t)
       ]; 
 
module links(n,step,r,sides,ring_r,depth=0,t=1,centre=true){
  if (depth>0) {
     a=360/n;
     a4=a/4;
//     echo(depth,n,a,aq);
     if(centre)   fun_knot(step,r,sides);
     for (i=[0 : n-1])
       rotate([0,0,i * a - a4])
        translate([ring_r * offset,0,0,])  
          rotate([0,0,a4])
             links(n,step,r,sides,ring_r,depth-1,t,centre);  
     }
  else fun_knot(step,r,sides);
  }


// create a tube as a polyhedron 
// tube must be closed 

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
                            
function orient_to(centre,normal, p) = m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
                     * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
                     * m_translate(centre);

function circle_points(r = 1, sides, a = 0) = 
    a <= 360 - 360 / sides
       ? concat([[r * sin(a), r * cos(a), 0]], circle_points(r, sides, a + 360 / sides)) 
       : [] ;

function loop_points(step, t = 0) = 
    t <= 360 -step
       ? concat([f(t)], loop_points(step, t + step)) 
       : [] ;

function transform_points(list, matrix, i = 0) = 
    i < len(list) 
       ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1))
       : [];

function tube_points(loop, circle_points,  i = 0) = 
    (i < len(loop) - 1)
     ?  concat(transform_points(circle_points, orient_to(loop[i], loop[i + 1] - loop[i] )), 
               tube_points(loop, circle_points, i + 1)) 
     : transform_points(circle_points, orient_to(loop[i], loop[0] - loop[i] )) ;

function tube_faces(segs, sides, s, i = 0) =
     i < sides  
       ?  concat([[s * sides + i, 
                   s * sides + (i + 1) % sides, 
                 ((s + 1) % segs) * sides + (i + 1) % sides, 
                 ((s + 1) % segs) * sides + i]
                ], 
                tube_faces(segs, sides, s, i + 1))
      : [];
                                                    
function loop_faces(segs, sides, i = 0) = 
     i < segs 
        ? concat(tube_faces(segs, sides, i), loop_faces(segs, sides, i + 1)) 
        : [];


//  create a knot from function
module fun_knot(step,r,sides)  {
    circle_points = circle_points(r,sides);
    loop_points = loop_points(step);
    tube_points = tube_points(loop_points,circle_points);
    loop_faces = loop_faces(len(loop_points),sides);
*    echo(circle_points);
*    echo(tube_points);
*    echo(loop_faces);
    polyhedron(points = tube_points, faces = loop_faces);
};

