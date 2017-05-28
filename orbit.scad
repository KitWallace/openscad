// number of sides of rope - must be a divisor of 360
Sides=5;  
 // step size in degrees 
Step=2;  
 // rope radius
R=0.05;    
// overall scale
Scale=20; 
// depth of undulation 
B=0.1;
// link rotation  % of cycle  0.25 disjoint , 0 joint
p= 0.25;  

/* 1 + 5 loops, rotated at increments of 72 degress at an inclination of 60 degrees 
*/
colours=["red","green","pink","orange","purple","yellow"];

    scale(Scale) {
      rotate([0,0,-p*72])
              fun_knot(Step,R,Sides); 
       for (k =[0:4])
           color(colours[k]) 
              rotate([0,0,k * 72]) 
                rotate([60,0,0]) 
                   rotate([0,0,18])
                     fun_knot(Step,R,Sides);
   }

function f(t) =
   let (r= 1 + B * sin(5 *t))
   [ r*cos(t), r*sin(t), 0];            
            
// contributions  by nophead
// requires openscad development snapshot 
// with concat enabled  in edit/preferences/features 

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

function circle_points(r = 1, sides, phase=45, a = 0) = 
    a <= 360 - 360 / sides
       ? concat([[r * sin(a + phase), r * cos(a + phase), 0]], circle_points(r, sides, phase,  a + 360 / sides)) 
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

function curve_length(step,t=0) =
    t < 360
      ?  norm(f(t+step) - f(t)) + curve_length(step,t+step)
      :  0;

//  create a knot from function
module fun_knot(step,r,sides)  {
    circle_points = circle_points(r,sides);
    loop_points = loop_points(step);
    tube_points = tube_points(loop_points,circle_points);
    loop_faces = loop_faces(len(loop_points),sides);
    polyhedron(points = tube_points, faces = loop_faces);
};


