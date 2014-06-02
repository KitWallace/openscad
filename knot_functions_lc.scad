// contributions  by nophead, oskar, kintel
// requires openscad development snapshot >= 2015-05-30

// create a tube as a polyhedron 
// tube must be closed 

function flatten(list) = [ for (i = list, v = i) v ]; 

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
 
function transform_points(list, matrix) = 
    [for (p = list) transform(p, matrix) ];  
                         
function orient_to(centre,normal, p) =
          m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
        * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
        * m_translate(centre);

function circle_points(r = 1, sides) = 
   let (step=360/sides)
   [for (a =[0:360/sides:360-360/sides])
       [r * sin(a), r * cos(a), 0]
    ];

function loop_points(step) = 
    [for (t=[0:step:360-step]) f(t) ];

function tube_points(loop, circle_points) = 
    let (n = len(loop))
    flatten([for (i=[0:n - 1])
        transform_points(circle_points, 
                         orient_to(loop[i], loop[(i + 1) % n] - loop[i] ))
    ]);

function tube_faces(segs, sides, s) =
    [for (i=[0:sides-1])
        [s * sides + i, 
         s * sides + (i + 1) % sides, 
         ((s + 1) % segs) * sides + (i + 1) % sides, 
         ((s + 1) % segs) * sides + i
        ]
    ];
                                                    
function loop_faces(segs, sides) = 
    flatten([for (s=[0:segs-1])
        tube_faces(segs, sides,s)
    ]);


// interpolate between points in a path

weight = [-1, 9, 9, -1] / 16;

function interpolate(points,n,i) =
        points[(i + n - 1) %n] * weight[0] +
        points[i]              * weight[1] +
        points[(i + 1) %n]     * weight[2] +
        points[(i + 2) %n]     * weight[3] ;

function subdivide(points,i=0) = 
   flatten([for (i=[0:len(points)-1])
      [points[i], interpolate(points,len(points),i)]
    ]);

function smooth(points,n) =
   n == 0
      ?  points
      :  smooth(subdivide(points),n-1);

function scale(points,scale,i=0) =
    [for (p=points)
        [p[0]*scale[0],p[1]*scale[1],p[2]*scale[2]]
    ];
