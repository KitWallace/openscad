
// contributions  by nophead  and oskar

// create a tube as a polyhedron 
// tube must be closed 
// poly functions

// poly constructor

function poly(name,vertices,faces,debug=[],partial=false) = 
    [name,vertices,faces,debug,partial];

function p_name(obj) = obj[0];
function p_vertices(obj) = obj[1];
function p_faces(obj) = obj[2];
  
module show_solid(obj) {
    polyhedron(p_vertices(obj),p_faces(obj),convexity=10);
};

// utility functions  
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

// solid from path
function circle_points(r = 1, sides, phase, a = 0) = 
    a < 360 
       ? concat([[r * sin(a+phase), r * cos(a+phase), 0]], circle_points(r, sides, phase, a + 360 / sides)) 
       : [] ;

function loop_points(step, t = 0) = 
    t < 360 
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

//  path with hulls

module hulled_path(path,r) {
    for (i = [0 : 1 : len(path) - 1 ]) {
        hull() {
            translate(path[i]) sphere(r);
            translate(path[(i + 1) % len(path)]) sphere(r);
        }
    }
};

// smoothed path by interpolate between points 

weight = [-1, 9, 9, -1] / 16;

function interpolate(path,n,i) =
        path[(i + n - 1) %n] * weight[0] +
        path[i]             * weight[1] +
        path[(i + 1) %n]    * weight[2] +
        path[(i + 2) %n]    * weight[3] ;

function subdivide(path,i=0) = 
    i < len(path) 
     ? concat([path[i]], 
              [interpolate(path,len(path),i)],
              subdivide(path, i+1))
     : [];

function smooth(path,n) =
    n == 0
     ?  path
     :  smooth(subdivide(path),n-1);

function scale(path,scale,i=0) =
    i < len(path)
      ?  concat( 
           [[path[i][0]*scale[0],path[i][1]*scale[1],path[i][2]*scale[2]]], 
           scale(path,scale,i+1)
         )
      :  [];

function curve_length(step,t=0) =
    t < 360
      ?  norm(f(t+step) - f(t)) + curve_length(step,t+step)
      :  0;
      
//  create a knot from a path 

function path_knot(path,r,sides,kscale,phase=45)  =
  let(loop_points = scale(path,kscale))
  let(circle_points = circle_points(r,sides,phase))
  let(tube_points = tube_points(loop_points,circle_points))
  let(loop_faces = loop_faces(len(loop_points),sides))
  poly(name="Knot",
         vertices = tube_points,
         faces = loop_faces);
   
// main 

 // render_type function-1
 
 
Scale=20;
Sides=4;  // Sides of rope - must be a divisor of 360
Kscale=[1,1,0.5];  // x,y,z scaling
N=5;
height=0.3;


function f(t,h=height,cycles=N) =
   [ cos(t), sin(t), h*sin(cycles*t)];

R=0.1;   // Rope diameter
Step=1 ;  // decrease for finer details
colours = ["red","green","blue","yellow","pink","black","orange"];
path = loop_points(Step);
knot= path_knot(path,R,Sides,Kscale);
d=0.5;

theta=360/N;
delta=180/N;
scale(Scale)
for (k =[0:N-1]) {
    color(colours[k]) 
     translate([d * cos (k*theta), d * sin(k*theta),0])
        rotate([0,0,delta + k * theta])  
           show_solid(knot);
};
