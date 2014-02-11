// loxodrome
// uses open tube code 
// orginal endless tube code by nop head
// requires openscad development snapshot 2014-01-14 e
//      http://www.openscad.org/downloads.html
// with concat enabled  in edit/preferences/features 

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
          tube_points(loop_points,section_points, i + 1))
       : []
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
     concat (
          [reverse(tube_end(facets,0))],  // reverse direction for this face
          loop_faces(segs,facets), 
          [tube_end(facets,segs)]);

function reverse_r(v,n) =
      n == 0 
        ? [v[0]]
        : concat([v[n]],reverse_r(v,n-1))
;
function reverse(v) = reverse_r(v, len(v)-1);

e = 2.718281828;
pi = 3.14159;
rad = 2 * pi / 360;

function sinh(x) = (1 - pow(e, -2 * x)) / (2 * pow(e, -x));
function cosh(x) = (1 + pow(e, -2 * x)) / (2 * pow(e, -x));
function tanh(x) = sinh(x) / cosh(x);
function cot(x) = 1 / tan(x);

/*
for ( x = [ -e: 0.1: e])
    echo (x, sinh(x), cosh(x), tanh(x));
*/

function  m(beta,long,long0) = cot(beta) * ( long - long0) * rad;

function lox (t,beta,long0) =
    [ cos(t) / cosh(m(beta,t,long0)),
      sin(t) / cosh(m(beta,t,long0)),
      tanh(m(beta,t,long0))
    ];

function f(t) =  [0,r *sin(t), r * cos(t)  ];

function loop_points(step, end, t = 0, beta,long0, r ) = 
    t <= end 
       ? concat(r*[lox(t,beta,long0)], loop_points(step, end, t + step, beta,long0, r )) 
       : [] ;

step=10;
r=10;
thickness=0.5;
long0 = 0;

section_points = circle_points(thickness, $fn=20);  // some values will break the polyhedron
// echo(section_points);
translate([0,0,r + thickness])
for (a= [0:90:270]) {
 rotate([0,0,a])
 assign(loop_points = loop_points(5, 500, -500, 70 ,long0, r))
// echo(loop_points);
 assign(tube_points = tube_points(loop_points,section_points),
// echo(tube_points);
       faces = loop_all_faces(len(loop_points)-2, len(section_points)))
// echo(faces);
       polyhedron(points = tube_points, faces = faces);
}
