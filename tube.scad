// code by nop head
// requires openscad snapshot  eg.
//      http://files.openscad.org/OpenSCAD-2014.01.14-x86-32-Installer.exe
// with concat enabled  in edit/preferences/features 
// function parameters moved to global for generality
// tube must be closed with no self-intersections

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
                            
function disc(p0, p) = m_rotate([0, atan2(sqrt(pow(p[0], 2) + pow(p[1], 2)), p[2]), 0]) 
                     * m_rotate([0, 0, atan2(p[1], p[0])]) 
                     * m_translate(p0 + p);

function circle_points(r = 1, a = 0) = 
    a < 360 
       ? concat([[r * sin(a), r * cos(a), 0]], circle_points(r, a + 360 / $fn)) 
       : [] ;

function loop_points(step, t = 0) = 
    t < 360 
       ? concat([f(t)], loop_points(step, t + step)) 
       : [] ;

function transform_points(list, matrix, i = 0) = 
    i < len(list) 
       ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1))
       : [];

function tube_points(loop, i = 0) = 
    (i < len(loop) - 1)
     ?  concat(transform_points(circle_points, disc(loop[i], (loop[i + 1] - loop[i])/ 2)), tube_points(loop, i + 1)) 
     : transform_points(circle_points, disc(loop[i], (loop[0] - loop[i])/ 2)) ;

function tube_faces(segs, facets, s, i = 0) =
     i < facets  
       ?  concat([[s * facets + i, 
                   s * facets + (i + 1) % facets, 
                 ((s + 1) % segs) * facets + (i + 1) % facets, 
                 ((s + 1) % segs) * facets + i]
                ], 
                tube_faces(segs, facets, s, i + 1))
      : [];
                                                    
function loop_faces(segs, i = 0) = 
     i < segs 
        ? concat(tube_faces(segs, $fn, i), loop_faces(segs, i + 1)) 
        : [];
