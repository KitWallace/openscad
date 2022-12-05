// tube example - a spring
// orginal endless tube code by nop head
// requires openscad snapshot  eg.
//      http://files.openscad.org/OpenSCAD-2014.01.14-x86-32-Installer.exe
// with concat enabled  in edit/preferences/features 


// radius of spring
Radius= 10;

// radius of wire 
Wire_radius=0.5;

// Pitch of spring - distance between coils
Pitch= 2;

//number of coils
Coils = 10;

// Spring Resolution - in degrees
Step=5;

// Wire resolution
$fn= 20;

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
                            
function orientate(p0, p) =               
              m_rotate([0, atan2(sqrt(pow(p[0], 2) + pow(p[1], 2)), p[2]), 0])  
            * m_rotate([0, 0, atan2(p[1], p[0])]) 
            * m_translate(p0);

function circle_points(r = 1, a = 0) = 
    a < 360
       ? concat([[r * sin(a),  r * cos(a),0]], circle_points(r, a + 360 / $fn)) 
       : [] ;

function loop_points(step, end , t = 0) = 
    t <= end 
       ? concat([f(t)], loop_points(step, end, t + step)) 
       : [] ;

function transform_points(list, matrix, i = 0) = 
    i < len(list) 
       ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1))
       : [];

function tube_points(loop_points, section_points, i=0) =
    i < len(loop_points)-1
       ? concat(
           transform_points(
                 section_points, 
                 orientate(loop_points[i],(loop_points[i + 1]- loop_points[i])/2)),
          tube_points(loop_points,section_points, i + 1)
        )
       : []    // in a closed loop, this segment connects to the start
;

function tube_faces(facets, s, i = 0) =  
     i < facets  
       ?  concat([[s * facets + i, 
                   s * facets + (i + 1) % facets, 
                  (s + 1) * facets + (i + 1) % facets, 
                  (s + 1) * facets + i]
                ], 
                tube_faces(facets, s, i + 1))
      : [];
          
function tube_end(facets, s, i = 0) =  
     i < facets  
       ?  concat( [s * facets + i], tube_end(facets, s, i+1))
       : [];  
 
                                       
function loop_faces(segs,facets, j = 0) = 
     j < segs
        ? concat(tube_faces(facets,  j), loop_faces(segs, facets, j + 1)) 
        : [];

function loop_all_faces(segs,facets) =
     concat ([reverse(tube_end(facets,0))], // direction changed here 
              loop_faces(segs,facets),
             [tube_end(facets,segs)]
            );

function reverse_r(v,n) =
      n == 0 
        ? [v[0]]
        : concat([v[n]],reverse_r(v,n-1))
;
function reverse(v) = reverse_r(v, len(v)-1);


function circle_points(r = 1, a = 0) = 
    a <= 360
       ? concat([[r * sin(a),  r * cos(a),0]], circle_points(r, a + 360 / $fn)) 
       : [] ;

function f(t) =  [Radius *sin(t),Radius * cos(t) ,Pitch * t/360 ];

function loop_points(step, end, t = 0) = 
    t <= end 
       ? concat([f(t)], loop_points(step, end, t + step )) 
       : [] ;

//section_points = circle_points(Wire_radius, $fn=20);
section_points = circle_points(Wire_radius, 360/$fn);
//echo(section_points);

loop_points = loop_points(Step ,360* Coils + Step);
// echo(loop_points);
tube_points = tube_points(loop_points,section_points);
// echo(tube_points);

faces = loop_all_faces(len(loop_points)-2, len(section_points));
// echo(faces);
polyhedron(points = tube_points, faces = faces);
