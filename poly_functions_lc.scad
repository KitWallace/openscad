// functions for the construction of polyhedra
// chris wallace
// see http://kitwallace.tumblr.com/tagged/polyhedra for info
// many thanks to nophead 

//  functions for creating the matrices for transforming a single point

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
                            
function matrix_to(p0, p) = 
                       m_rotate([0, atan2(sqrt(pow(p[0], 2) + pow(p[1], 2)), p[2]), 0]) 
                     * m_rotate([0, 0, atan2(p[1], p[0])]) 
                     * m_translate(p0);

function matrix_from(p0, p) = 
                      m_translate(-p0)
                      * m_rotate([0, 0, -atan2(p[1], p[0])]) 
                      * m_rotate([0, -atan2(sqrt(pow(p[0], 2) + pow(p[1], 2)), p[2]), 0]); 


function transform_points(list, matrix) = 
    [for (p = list) transform(p, matrix) ];


// basic functions 
function vsum(list,i=0) =
  i < len(list)
     ? list[i] + vsum(list,i+1)
     : [0,0,0];

function ssum(list,i=0) =  
      i < len(list)
        ?  (list[i] + ssum(list,i+1))
        :  0;

function vadd(points,v) =
      [ for (p = points)  p + v];

function reverse(v) =
  let(max=len(v) -1)
  [ for (i = [0:max])  v[max - i] ];

function project(v,dims) =
    [ for (p = v) [for (d = dims) p[d]] ] ;

function dim(v,dim) =
    [ for (p = v) p[dim] ] ;

function contains(list, n, i=0) =
     i < len(list) 
        ?  n == list[i]
           ?  true
           :  contains(list,n, i+1)
        : false;

// points 

//  convert from point indexes to point coordinates
function as_points(indexes,points) =
     [for (i=indexes) points[i] ];

function centre(points) = 
      vsum(points) / len(points);

function average_radius(points) =
    ssum([for (p=points) norm(p)]) / len(points);

// normalize the points to have origin at 0,0,0 
function centre_points(points) = 
     vadd(points, - centre(points));

//scale to average radius = radius
function normalize(points,radius) =
    points * radius /average_radius(points);

function bbox(points) = [
   [min(dim(points,0)), max(dim(points,0))],
   [min(dim(points,1)), max(dim(points,1))],
   [min(dim(points,2)), max(dim(points,2))]
];

// edges 

function edge_lengths(face) =
     [for (i = [0:len(face)-1])
          norm(face[i] - face[(i+1)% len(face)])
     ];  

function longest_edge(face) =
     max(edge_lengths(face));

function point_edges(point,edges) =
     [ for (edge = edges) 
        if (contains(edge,p)) edge
     ];

function select_nedged_points(points,edges,nedges) =
    [ for (p = points) 
        if (len(point_edges(p,edges)) == nedges)
           p
    ];


// faces 

function normal_r(face) =
     cross(face[1]-face[0],face[2]-face[0]);

function normal(face) =
     - normal_r(face) / norm(normal_r(face));

function triangle(a,b) = norm(cross(a,b))/2;

function face_triangles(face,centre) =
     [ for (i = [0:len(face)-1])
           triangle(
                face[i] - centre,
                face[(i+1) % len(face)] - centre
           )
     ];

function face_area(face) = ssum(face_triangles(face,centre(face)));

function largest_face(faces,points,i=0,max=0,max_face=-1) = 
    i < len(faces)
       ?  face_area(as_points(faces[i],points)) > max
           ? largest_face(faces,points,i+1,face_area(as_points(faces[i],points)),faces[i])
           : largest_face(faces,points,i+1,max,max_face)
       : max_face;


function select_large_faces(faces, points, size ) =
   [ for (face=faces) 
     if (face_area(as_points(face,points)) > size)
         face
   ];

function select_nsided_faces(faces,nsides) =
    len(nsides) == 0
      ?faces
      : [ for (face = faces) 
          if (contains(nsides,len(face)))
          face
        ];

// check that all faces have a lhs orientation
function cosine_between(u, v) =(u * v) / (norm(u) * norm(v));

function lhs_faces(faces,points) =
    [for (face = faces)
        (cosine_between(normal(as_points(face,points)),
                           centre(as_points(face,points))
                          ) < 0)
        ? reverse(face)
        : face
     ];

function fs(p) = f(p[0],p[1],p[2]);

function modulate_point(p) =
    spherical_to_xyz(fs(xyz_to_spherical(p)));


function modulate_points(points) =
      [ for (p = points) modulate_point(p) ];

function xyz_to_spherical(p) =
    [ norm(p), acos(p.z/ norm(p)), atan2(p.x,p.y)] ;

function spherical_to_xyz_full(r,theta,phi) =
    [ r * sin(theta) * cos(phi),
      r * sin(theta) * sin(phi),
      r * cos(theta)];

function spherical_to_xyz(s) =
     spherical_to_xyz_full(s[0],s[1],s[2]);
      
function lower(char) =
    contains("abcdefghijklmnopqrstuvwxyz",char) ;

function char_layer(char) =
    lower(char) 
         ? str(char,"_")
         : char;
