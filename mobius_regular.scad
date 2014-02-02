// generates Mobius strips
// based on code by nop head,  
// requires openscad snapshot with concat enabled 
// function parameters moved to global for generality

// a circular tube with a regular N-sided cross-section 
// which is rotated by Twists/N * 360 degrees over the circle
// allowance is required when connecting up the two ends of the tube 


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

function loop_points(step, t = 0) = 
    t < 360 
       ? concat([f(t)], loop_points(step, t + step)) 
       : [] ;

function transform_points(list, matrix, i = 0) = 
    i < len(list) ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1)) : [];


function tube_points(loop, i = 0) = 
    (i < len(loop) - 1)
     ?  concat(
            transform_points(
               cross_section_points(i * Step),
               orientate(loop[i], (loop[i + 1] - loop[i])/ 2, i *Step )
            ),
            tube_points(loop, i + 1)
        ) 
     : transform_points(
            cross_section_points(i * Step), 
            orientate(loop[i], (loop[0] - loop[i])/ 2, i * Step)
       )
;

// functions for a specific tube                 
function orientate(p0, p, i) =   // matrix to orientate the cross-section
                       m_rotate([0,0,Initial_angle + i/Facets * Twists])
                     * m_rotate([0, atan2(sqrt(pow(p[0], 2) + pow(p[1], 2)), p[2]), 0]) 
                     * m_rotate([0, 0, atan2(p[1], p[0])]) 
                     * m_translate(p0 + p)
;


function tube_faces(segs, facets, s, i = 0) =
     i < facets  
       ? s == segs - 1 &&  Twists % Facets !=0  // last segment partial Twist
           ?  concat([[s * facets + i, 
                       s * facets + (i + 1) % facets, 
                      (i + 1 + Twists % Facets ) % facets, 
                      (i + Twists % Facets  )% facets]
                 ], 
                tube_faces(segs, facets, s, i + 1))
           :  concat([[s * facets + i, 
                   s * facets + (i + 1) % facets, 
                 ((s + 1) % segs) * facets + (i + 1) % facets, 
                 ((s + 1) % segs) * facets + i]
                ], 
                tube_faces(segs, facets, s, i + 1))
                   
      : [];
                                                    
function loop_faces(segs, facets, i = 0) = 
     i < segs 
        ? concat(tube_faces(segs, facets, i), loop_faces(segs, facets, i + 1 )) 
        : [];

Twists = 1;
Radius=5;
Width=1;
Initial_angle = 0;
Facets= 4;  // sides of the cross-section 
Scale = 6;
Step = 0.5;

function cross_section_points(t, i = 0) = 
   i < Facets 
     ?  concat( [[ Width * cos( i / Facets * 360), 
                   Width * sin( i / Facets * 360),
                   0
                 ]],
               cross_section_points(t,i+1)
              )
     : []
;

function f(t) =  
   [ Radius*sin(t),
     Radius*cos(t),
     0
   ];

echo(cross_section_points(0));

loop_points = loop_points(Step);
tube_points = tube_points(loop_points);
loop_faces = loop_faces(len(loop_points),Facets);

scale(Scale) polyhedron(points = tube_points, faces = loop_faces);




