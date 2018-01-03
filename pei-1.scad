// create a tube as a polyhedron 
// tube can be open or closed

// polyhedron constructor

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


function circle_points(r, sides,phase=45) = 
    let (delta = 360/sides)
    [for (i=[0:sides-1]) [r * sin(i*delta + phase), r *  cos(i*delta+phase), 0]];

function loop_points(step,min=0,max=360) = 
    [for (t=[min:step:max-step]) f(t)];

function transform_points(list, matrix, i = 0) = 
    i < len(list) 
       ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1))
       : [];

function tube_points(loop, circle_points,  i = 0) = 
    (i < len(loop) - 1)
     ?  concat(transform_points(circle_points, orient_to(loop[i], loop[i + 1] - loop[i] )), 
               tube_points(loop, circle_points, i + 1)) 
     : transform_points(circle_points, orient_to(loop[i], loop[0] - loop[i] )) ;

function loop_faces(segs, sides, open=false) = 
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


function path_segment(path,start,end) =
    let (l = len(path))
    let (s = max(floor(start * 360 / l),0),
         e = min(ceil(end * 360 / l),l - 1))
    [for (i=[s:e]) path[i]];


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

function map(t, min, max) =
      min + t* (max-min)/360;

function radians (deg) = deg* 3.14159/180;  
function degrees (rad) = rad*180/ 3.14159;  
   
    
//  create a knot from a path 

function path_knot(path,r,sides,kscale,phase=45,open=false)  =
  let(loop_points = scale(path,kscale))
  let(circle_points = circle_points(r,sides,phase))
  let(tube_points = tube_points(loop_points,circle_points))
  let(loop_faces = loop_faces(len(loop_points),sides,open))
  poly(name="Knot",
         vertices = tube_points,
         faces = loop_faces);
         
function f(t) = 
    let (r = 1/(1.3 + sin(7*t)))
    let (theta =degrees(radians(t)+ sin(7 *t )))
    [r * cos(theta),
     r*  sin(theta),
    r*r/5
    ];  
   
Scale=40;
Sides=20;  // Sides of rope - must be a divisor of 360
Phase = 45;  // phase angle for profile (maters for low Sides
Kscale=[1,1,1];  // x,y,z scaling
R=0.07;   // Rope diameter
Step=0.5 ;  // decrease for finer details
Open = false;   // true if knot is open or partial
Start=0; End=360;  // change for partial path
colours = ["red","green","blue","yellow","pink"];
Paths = [loop_points(Step,Start,End)];
scale(Scale)
for (k =[0:len(Paths) - 1]) {
   path = Paths[k];
   knot= path_knot(path,R,Sides,Kscale,Phase,Open);
 
   solid1=knot;  // apply transformations here
   color(colours[k]) 
      show_solid(solid1);
};
