
// functions for the construction of polyhedra
// chris wallace
// see http://kitwallace.tumblr.com/tagged/polyhedra for info


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

function transform_points(list, matrix, i = 0) = 
    i < len(list) 
       ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1))
       : [];


//  convert from point indexes to point coordinates

function as_points(indexes,points,i=0) =
     i < len(indexes) 
        ?  concat([points[indexes[i]]], as_points(indexes,points,i+1))
        : [];

//  basic vector functions
function normal_r(face) =
     cross(face[1]-face[0],face[2]-face[0]);

function normal(face) =
     - normal_r(face) / norm(normal_r(face));

function centre(points) = 
      vsum(points) / len(points);

// sum a list of vectors
function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];

// add a scalar to a vector
function vadd(points,v,i=0) =
      i < len(points)
        ?  concat([points[i] + v], vadd(points,v,i+1))
        :  [];

function reverse_r(v,n) =
      n == 0 
        ? [v[0]]
        : concat([v[n]],reverse_r(v,n-1));

function reverse(v) = reverse_r(v, len(v)-1);

function project(pts,i=0) =
     i < len(pts)
        ? concat([[pts[i][0],pts[i][1]]], project(pts,i+1))
        : [];
        
function contains(n, list, i=0) =
     i < len(list) 
        ?  n == list[i]
           ?  true
           :  contains(n,list,i+1)
        : false;
     
function select_nsided_faces(faces,nsides,i=0) =
  len(nsides) == 0
     ?  faces
     :  i < len(faces)
         ?  contains(len(faces[i]), nsides)
             ? concat([faces[i]],  select_nsided_faces(faces,nsides,i+1))
             : select_nsided_faces(faces,nsides,i+1)
         : [];
         
function longest_edge(face,max=-1,i=0) =
       i < len(face)
          ?  norm(face[i] - face[(i+1)% len(face)]) > max
             ?  longest_edge(face, norm(face[i] - face[(i+1)% len(face)]),i+1)
             :  longest_edge(face, max,i+1)
          : max ;

function point_edges(point,edges,i=0) =
    i < len(edges) 
       ? point == edges[i][0] || point == edges[i][1]
         ? concat([edges[i]], point_edges(point,edges,i+1))
         : point_edges(point,edges,i+1)
       : [];

function select_nedged_points(points,edges,nedges,i=0) =
     i < len(points) 
         ?  len(point_edges(i,edges)) == nedges
             ? concat([i],  select_nedged_points(points,edges,nedges,i+1))
             : select_nedged_points(points,edges,nedges,i+1)
         : [];

function triangle(a,b) = norm(cross(a,b))/2;

function face_area_centre(face,centre,i=0) =
    i < len(face)
       ?  triangle(
                face[i] - centre,
                face[(i+1) % len(face)] - centre)
          + face_area_centre(face,centre,i+1)
       : 0 ;

function face_area(face) = face_area_centre(face,centre(face));

function face_areas(faces,points,i=0) =
   i < len(faces)
      ? concat([[i,  face_area(as_points(faces[i],points))]] ,
               face_areas(faces,points,i+1))
      : [] ;
 
function max_area(areas, max=[-1,-1], i=0) =
   i <len(areas)
      ? areas[i][1] > max[1]
         ?  max_area(areas,areas[i],i+1)
         :  max_area(areas,max,i+1)
      : max;

// check that all faces have a lhs orientation
function cosine_between(u, v) =(u * v) / (norm(u) * norm(v));

function lhs_faces(faces,points,i=0) =
     i < len(faces) 
        ?  cosine_between(normal(as_points(faces[i],points)),
                         centre(as_points(faces[i],points))) < 0
            ?  concat([reverse(faces[i])],lhs_faces(faces,points,i+1))
            :  concat([faces[i]],lhs_faces(faces,points,i+1))
        : [] ;

module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal[1], normal[0])]) //rotation
      rotate([0, atan2(sqrt(pow(normal[0], 2)+pow(normal[1], 2)),normal[2]), 0])
      children();
}

module orient_from(centre, normal) {   
      rotate([0, -atan2(sqrt(pow(normal[0], 2)+pow(normal[1], 2)),normal[2]), 0])
      rotate([0, 0, -atan2(normal[1], normal[0])]) //rotation
      translate(-centre)
      children();
}

module place_on_largest_face(faces,points) {
  assign (largest = max_area(face_areas(faces,points)))
  assign (lpoints = as_points(faces[largest[0]],points))
  assign (n = normal(lpoints),c = centre(lpoints))
  orient_from(c,-n)
  children();
}
              
module make_edge(edge, points, r) {
    assign(p0 = points[edge[0]], p1 = points[edge[1]])
    assign(v = p1 -p0 )
     orient_to(p0,v)
       cylinder(r=r, h=norm(v)); 
}

module make_edges(points, edges, r) {
   for (i =[0:len(edges)-1])
      make_edge(edges[i],points, r);
}

module make_vertices(points,r) { 
   for (i = [0:len(points)-1])
      translate(points[i]) sphere(r); 
}

module face_prism (face,prism_base_ratio,prism_scale,prism_height_ratio) {
    assign (n = normal(face), c= centre(face))
    assign (m = matrix_from(c,n))
    assign (tpts =  prism_base_ratio * transform_points(face,m))
    assign (max_length = longest_edge(face))
    assign (xy = project(tpts)) 
      linear_extrude(height=prism_height_ratio * max_length, scale=prism_scale) 
          polygon(points=xy);
}

module face_prisms_in(faces,points,prism_base_ratio,prism_scale,prism_height_ratio) {
    for (i=[0:len(faces) - 1]) 
       assign (f = as_points(faces[i],points)) 
       assign (n = normal(f), c = centre(f))
       orient_to(c,n) 
          translate([0,0,eps]) 
               mirror() rotate([0,180,0]) 
                   face_prism(f,prism_base_ratio,prism_scale,prism_height_ratio);
}

module face_prisms_out(faces,points,prism_base_ratio,prism_scale,prism_height_ratio) {
    for (i=[0:len(faces) - 1]) 
       assign (f = as_points(faces[i],points)) 
       assign (n = normal(f), c = centre(f))
       orient_to(c,n) 
          face_prism(f,prism_base_ratio,prism_scale,prism_height_ratio);
}

module ruler(n) {
   for (i=[0:n-1]) 
       translate([(i-n/2 +0.5)* 10,0,0]) cube([9.8,5,2], center=true);
}

module ground(x=0) {
   translate([0,0,-(50+x)]) cube(100,center=true);
}
