/* 
A script to implement the Conway operations on Polyhedra.  

By Kit Wallace kit.wallace@gmail.com

with thanks to George Hart whose javascript version http://www.georgehart.com/virtual-polyhedra/conway_notation.html was the inspiration for this work.

Code licensed under the Creative Commons - Attribution - Share Alike license.

The project is being documented in my blog 
   http://kitwallace.tumblr.com/tagged/conway  for the conway operators
and  http://kitwallace.tumblr.com/tagged/net  for work on net generation
Done :
    poly object constructor 
    poly accessors and renderers  (as 3d object, description, full print, face and vertex analyses)
    
    primitives T(),C(),O(),D(),I(),Y(n),P(n),A(n)
        all centered and normalized to a mid-scribed radius of 1 
        
   conway/hart operators 
       kis(obj,ratio, nsides)
       ambo(obj)
       meta(obj,ratio)
       ortho(obj,ratio)
       trunc(obj,ratio, nsides) 
       dual(obj)    
       snub(obj,height)
       expand(obj,height), rexpand () to apply recursively 
       reflect(obj)
       gyro(obj)   
       propellor(obj,ratio)
       join(obj)  == dual(ambo(obj)
       bevel(obj) == trunc(ambo(obj))
       chamfer(obj,ratio)
       whirl(obj,ratio)
       tt(obj)   convert triangular faces into 4 triangles
       
   additional operators
       transform(obj,matrix)    matrix transformation of vertices
       inset_kis(obj,ratio,height,fn)
       modulate(obj)  with global spherical function fmod()
       shell(obj,outer_inset_ratio,inner_inset_ratio,
            ,outer_inset,inner_inset,height,min_edge_length)
       place(obj)  on largest face -use before shell
       crop(obj,minz,maxz) - then render with wire frame
    orientation, centering and resizing
       p_inscribed_resize_points()  - resize to a given average face centre
       p_midscribed_resize_points() - resize to a given average edge centre
       p_circumscribed_resize_points() - resize to a given average vertex
       orient(obj)  - ensure all faces have lhs order (only convex )
         needed for some imported solids eg Georges solids and Johnson
             and occasionally for David's 
    
    canonicalization
       plane(obj,itr) - planarization using reciprocals of centres
       canon(obj,itr) - canonicalization using edge tangents
       
    net generation and rendering
       p_create_net(obj)
       p_render_net(obj,net)
          
to do
       canon still fails if face is extreme - use plane first
       last updated 4 May 2015 22:00
 
requires version of OpenSCAD  with concat, list comprehension and let()

*/
// seed polyhedra
function T()= 
    p_resize(poly(name= "T",
       vertices= [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]],
       faces= [[2,1,0],[3,2,0],[1,3,0],[2,3,1]]
    ));
function C() = 
   p_resize(poly(name= "C",
       vertices= [
[ 0.5,  0.5,  0.5],
[ 0.5,  0.5, -0.5],
[ 0.5, -0.5,  0.5],
[ 0.5, -0.5, -0.5],
[-0.5,  0.5,  0.5],
[-0.5,  0.5, -0.5],
[-0.5, -0.5,  0.5],
[-0.5, -0.5, -0.5]],
      faces=
 [
[ 4 , 5, 1, 0],
[ 2 , 6, 4, 0],
[ 1 , 3, 2, 0],
[ 6 , 2, 3, 7],
[ 5 , 4, 6, 7],
[ 3 , 1, 5, 7]]
   ));

function O() = 
  let (C0 = 0.7071067811865475244008443621048)
  p_resize(poly(name="O",
         vertices=[
[0.0, 0.0,  C0],
[0.0, 0.0, -C0],
[ C0, 0.0, 0.0],
[-C0, 0.0, 0.0],
[0.0,  C0, 0.0],
[0.0, -C0, 0.0]],
        faces= [
[ 4 , 2, 0],
[ 3 , 4, 0],
[ 5 , 3, 0],
[ 2 , 5, 0],
[ 5 , 2, 1],
[ 3 , 5, 1],
[ 4 , 3, 1],
[ 2 , 4, 1]]   
    ));
function D() = 
  let (C0 = 0.809016994374947424102293417183)
  let (C1 =1.30901699437494742410229341718)

  p_resize(poly(name="D",
         vertices=[
[ 0.0,  0.5,   C1],
[ 0.0,  0.5,  -C1],
[ 0.0, -0.5,   C1],
[ 0.0, -0.5,  -C1],
[  C1,  0.0,  0.5],
[  C1,  0.0, -0.5],
[ -C1,  0.0,  0.5],
[ -C1,  0.0, -0.5],
[ 0.5,   C1,  0.0],
[ 0.5,  -C1,  0.0],
[-0.5,   C1,  0.0],
[-0.5,  -C1,  0.0],
[  C0,   C0,   C0],
[  C0,   C0,  -C0],
[  C0,  -C0,   C0],
[  C0,  -C0,  -C0],
[ -C0,   C0,   C0],
[ -C0,   C0,  -C0],
[ -C0,  -C0,   C0],
[ -C0,  -C0,  -C0]],
         faces=[
[ 12 ,  4, 14,  2,  0],
[ 16 , 10,  8, 12,  0],
[  2 , 18,  6, 16,  0],
[ 17 , 10, 16,  6,  7],
[ 19 ,  3,  1, 17,  7],
[  6 , 18, 11, 19,  7],
[ 15 ,  3, 19, 11,  9],
[ 14 ,  4,  5, 15,  9],
[ 11 , 18,  2, 14,  9],
[  8 , 10, 17,  1, 13],
[  5 ,  4, 12,  8, 13],
[  1 ,  3, 15,  5, 13]]
   ));
   
function I() = 
  let(C0 = 0.809016994374947424102293417183)
  p_resize(poly(name= "I",
         vertices= [
[ 0.5,  0.0,   C0],
[ 0.5,  0.0,  -C0],
[-0.5,  0.0,   C0],
[-0.5,  0.0,  -C0],
[  C0,  0.5,  0.0],
[  C0, -0.5,  0.0],
[ -C0,  0.5,  0.0],
[ -C0, -0.5,  0.0],
[ 0.0,   C0,  0.5],
[ 0.0,   C0, -0.5],
[ 0.0,  -C0,  0.5],
[ 0.0,  -C0, -0.5]],
        faces=[
[ 10 ,  2,  0],
[  5 , 10,  0],
[  4 ,  5,  0],
[  8 ,  4,  0],
[  2 ,  8,  0],
[  6 ,  8,  2],
[  7 ,  6,  2],
[ 10 ,  7,  2],
[ 11 ,  7, 10],
[  5 , 11, 10],
[  1 , 11,  5],
[  4 ,  1,  5],
[  9 ,  1,  4],
[  8 ,  9,  4],
[  6 ,  9,  8],
[  3 ,  9,  6],
[  7 ,  3,  6],
[ 11 ,  3,  7],
[  1 ,  3, 11],
[  9 ,  3,  1]]
));


function Y(n,h=1) =
// pyramids
   p_resize(poly(name= str("Y",n) ,
      vertices=
      concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),0]
        ],
        [[0,0,h]]
      ),
      faces=concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,n]
        ],
        [[for (i=[0:n-1]) i]]
      )
     ));

function P(n,h=1) =
// prisms
   p_resize(poly(name=str("P",n) ,
      vertices=concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),-h/2]
        ],
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),h/2]
        ]
      ),
      faces=concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,i+n,(i+1)%n + n]
        ],
        [[for (i=[0:n-1]) i]], 
        [[for (i=[n-1:-1:0]) i+n]]
      )
     ));
        
function A(n,h=1) =
// antiprisms
   p_resize(poly(name=str("A",n) ,
      vertices=concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),-h/2]
        ],
        [for (i=[0:n-1])
            [cos((i+1/2)*360/n),sin((i+1/2)*360/n),h/2]
        ]
      ),
      faces=concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,i+n]
        ],
        [for (i=[0:n-1])
            [(i+1)%n,i+n,(i+1)%n + n]
        ],
        
        [[for (i=[0:n-1]) i]], 
        [[for (i=[n-1:-1:0]) i+n]]
      )
     ));

// basic list comprehension functions

function depth(a) =
   len(a)== undef 
       ? 0
       : 1+depth(a[0]);
        
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function dflatten(l,d=2) =
// hack to flattened mixed list and list of lists
   flatten([for (a = l) depth(a) > d ? dflatten(a, d) : [a]]);
    
function reverse(l) = 
     [for (i=[1:len(l)]) l[len(l)-i]];

function shift(l,shift=0) = 
     [for (i=[0:len(l)-1]) l[(i + shift)%len(l)]];  
         
//  functions for creating the matrices for transforming a single point

function m_translate(v) = [ [1, 0, 0, 0],
                            [0, 1, 0, 0],
                            [0, 0, 1, 0],
                            [v.x, v.y, v.z, 1  ] ];

function m_scale(v) =    [ [v.x, 0, 0, 0],
                            [0, v.y, 0, 0],
                            [0, 0, v.z, 0],
                            [0, 0, 0, 1  ] ];
                            
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
function m_transform(v, m)  = vec3([v.x, v.y, v.z, 1] * m);

function m_rotate_to(normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal.y, normal.x)]);  
    
function m_rotate_from(normal) = 
      m_rotate([0, 0, -atan2(normal.y, normal.x)]) 
    * m_rotate([0, -atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]);  
    
function m_to(centre,normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal.y, normal.x)]) 
    * m_translate(centre);   
   
function m_from(centre,normal) = 
      m_translate(-centre)
    * m_rotate([0, 0, -atan2(normal.y, normal.x)]) 
    * m_rotate([0, -atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]); 


function m_rotate_about_line(a,v1,v2) =
      m_from(v1,v2-v1)*m_rotate([0,0,a])*m_to(v1,v2-v1);
      
// modules to orient objects for rendering
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

// vector functions
function unitv(v)=  v/ norm(v);

function signx (x) =
     x==0 ? 1 : sign(x);
     
function angle_between(u, v, normal) = 
// protection against inaccurate computation
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     normal == undef
        ? a 
        : signx(normal * cross(u,v)) * a;
     
function vadd(points,v,i=0) =
      i < len(points)
        ?  concat([points[i] + v], vadd(points,v,i+1))
        :  [];

function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];
          
function norm2(v) = v.x*v.x+ v.y*v.y + v.z*v.z;

function reciprocal(v) = v/norm2(v);
           
function ssum(list,i=0) =  
      i < len(list)
        ?  (list[i] + ssum(list,i+1))
        :  0;

function vcontains(val,list) =
     search([val],list)[0] != [];
   
function index_of(key, list) =
      search([key],list)[0]  ;

function value_of(key, list) =
      list[search([key],list)[0]][1]  ;

// dictionary shorthand assuming present
function find(key,array) =  array[search([key],array)[0]];

//sort a key value dictionary
function quicksort_kv(kvs) = 
//  kv[0] is the value to sort on,  kv[1] is the object sorted
 len(kvs)>0
     ? let( 
         pivot   = kvs[floor(len(kvs)/2)][0], 
         lesser  = [ for (y = kvs) if (y[0]  < pivot) y ], 
         equal   = [ for (y = kvs) if (y[0] == pivot) y ], 
         greater = [ for (y = kvs) if (y[0]  > pivot) y ] )
          concat( quicksort_kv(lesser), equal, quicksort_kv(greater))
      : [];
  
function count(val, list) =  // number of occurances of val in list
   ssum([for(v= list) v== val ? 1 :0]);
    
function distinct(list,dlist=[],i=0) =  // return only distinct items of d 
      i==len(list)
         ? dlist
         : search(list[i],dlist) != []
             ? distinct(list,dlist,i+1)
             : distinct(list,concat(dlist,list[i]),i+1)
      ;

// queue functions 
function head(queue) = 
           len(queue) > 0
               ? queue[len(queue)-1]
               : undef; 
function enque(queue,item) = dflatten(concat(item,queue),1);         
function deque(queue) =
 // remove the last entry in the queue
    len(queue) > 1
        ? [for (i=[0:len(queue)-2]) queue[i]]
        : [];


// points functions
        
function as_points(indexes,points) =
    [for (i=[0:len(indexes)-1])
          points[indexes[i]]
    ]; 

function centre(points) = 
      vsum(points) / len(points);
    
function vnorm(points) =
     [for (p=points) norm(p)];
      
function average_norm(points) =
       ssum(vnorm(points)) / len(points);

function transform_points(points, matrix) = 
    [for (p=points) m_transform(p, matrix) ] ;
   
// vertex functions
    
function vertex_faces(v,faces) =   // return the faces containing v
     [ for (f=faces) if(v!=[] && search(v,f)) f ];
    
function ordered_vertex_faces(v,vfaces,cface=[],k=0)  =
   k==0
       ? let (nface=vfaces[0])
           concat([nface],ordered_vertex_faces(v,vfaces,nface,k+1))
       : k < len(vfaces)
           ?  let(i = index_of(v,cface))
              let(j= (i-1+len(cface))%len(cface))
              let(edge=[v,cface[j]])
              let(nface=face_with_edge(edge,vfaces))
                 concat([nface],ordered_vertex_faces(v,vfaces,nface,k+1 ))  
           : []
;       
      
function ordered_vertex_edges(v,vfaces,face,k=0)  =
   let(cface=(k==0)? vfaces[0] : face)
   k < len(vfaces)
           ?  let(i = index_of(v,cface))
              let(j= (i-1+len(cface))%len(cface))
              let(edge=[v,cface[j]])
              let(nface=face_with_edge(edge,vfaces))
                 concat([edge],ordered_vertex_edges(v,vfaces,nface,k+1 ))  
           : []
;     
     

                   
// edge functions
          
function distinct_edge(e) = 
     e[0]< e[1]
           ? e
           : reverse(e);
          
function ordered_face_edges(f) =
 // edges are ordered anticlockwise
    [for (j=[0:len(f)-1])
        [f[j],f[(j+1)%len(f)]]
    ];

function all_edges(faces) =
   [for (f = faces)
       for (j=[0:len(f)-1])
          let(p=f[j],q=f[(j+1)%len(f)])
             [p,q] 
   ];

function distinct_face_edges(f) =
    [for (j=[0:len(f)-1])
       let(p=f[j],q=f[(j+1)%len(f)])
          distinct_edge([p,q])
    ];
    
function distinct_edges(faces) =
   [for (f = faces)
       for (j=[0:len(f)-1])
          let(p=f[j],q=f[(j+1)%len(f)])
             if(p<q) [p,q]  // no duplicates
   ];
      
function check_euler(obj) =
     //  E = V + F -2    
    len(p_vertices(obj)) + len(p_faces(obj)) - 2
           ==  len(distinct_edges(obj[2]));

function edge_length(edge,points) =    
    let (points = as_points(edge,points))
    norm(points[0]-points[1]) ;
             
function edge_lengths(edges,points) =
   [ for (edge = edges) 
     edge_length(edge,points)
   ];
 
function tangent(v1,v2) =
   let (d=v2-v1)
   v1 - v2 * (d*v1)/norm2(d);
 
function edge_distance(v1,v2) = sqrt(norm2(tangent(v1,v2)));
 
function face_with_edge(edge,faces) =
     flatten(
        [for (f = faces) 
           if (vcontains(edge,ordered_face_edges(f)))
            f
        ]);
           
function dihedral_angle(edge,faces,points)=
    let(f0 = face_with_edge(edge,faces),
        f1 = face_with_edge(reverse(edge),faces),
        p0 = as_points(f0,points),
        p1 = as_points(f1,points),
        n0 = normal(p0),
        n1 = normal(p1),
        angle =  angle_between(n0,n1),
        dot=(centre(p0)-centre(p1))*n1,
        dihedral = dot < 0 ? 180-angle  : 180 +  angle  
        )
     dihedral;     
   
    
function dihedral_angle_faces(f0,f1,faces,points)=
    let(p0 = as_points(faces[f0],points),
        p1 = as_points(faces[f1],points),
        n0 = normal(p0),
        n1 = normal(p1),
        angle =  angle_between(n0,n1),
        dot=(centre(p0)-centre(p1))*n1,
        dihedral = dot < 0 ? 180-angle  : 180 +  angle  
        )
     dihedral; 

//face functions
function selected_face(face,fn) = 
     fn == [] || search(len(face),fn) != [] ;

function orthogonal(v0,v1,v2) =  cross(v1-v0,v2-v1);

function normal(face) =
     let (n=orthogonal(face[0],face[1],face[2]))
     - n / norm(n);

function triangle(a,b) = norm(cross(a,b))/2;

function face_area(face) =
     ssum([for (i=[0:len(face)-1])
           triangle(face[i], face[(i+1)%len(face)]) ]);
     
function face_areas(obj) =
   [for (f=p_faces(obj))
       let(face_points = as_points(f,p_vertices(obj)))
       let(centre=centre(face_points))
          face_area(vadd(face_points,-centre))
   ];

function face_areas_index(obj) =
   [for (face=p_faces(obj))
       let(face_points = as_points(face,p_vertices(obj)))
       let(centre=centre(face_points))
          [face,face_area(vadd(face_points,-centre))]
   ];

function max_area(areas, max=[undef,0], i=0) =
   i <len(areas)
      ? areas[i][1] > max[1]
         ?  max_area(areas,areas[i],i+1)
         :  max_area(areas,max,i+1)
      : max[0];

function average_face_normal(fp) =
     let(fl=len(fp))
     let(normals=
           [for(i=[0:fl-1])
            orthogonal(fp[i],fp[(i+1)%fl],fp[(i+2)%fl])
           ]
          )
     vsum(normals)/len(normals);
    
function average_normal(fp) =
     let(fl=len(fp))
     let(unitns=
           [for(i=[0:fl-1])
            let(n=orthogonal(fp[i],fp[(i+1)%fl],fp[(i+2)%fl]))
            let(normn=norm(n))
              normn==0 ? [] : n/normn
           ]
          )
     vsum(unitns)/len(unitns);
     
function average_edge_distance(fp) =
     let(fl=len(fp))
     ssum( [for (i=[0:fl-1])
                edge_distance(fp[i],fp[(i+1)%fl])
             ])/ fl;
    
function face_sides(faces) =
    [for (f=faces) len(f)];
        
function face_coplanarity(face) =
       norm(cross(cross(face[1]-face[0],face[2]-face[1]),
                  cross(face[2]-face[1],face[3]-face[2])
            ));


function face_edges(face,points) =
     [for (edge=ordered_face_edges(face)) 
           edge_length(edge,points)
     ];
         
function min_edge_length(face,points) =
    min(face_edges(face,points));
   
function face_irregularity(face,points) =
    let (lengths=face_edges(face,points))
    max(lengths)/ min(lengths);

function face_analysis(faces) =
  let (edge_counts=face_sides(faces))
  [for (sides=distinct(edge_counts))
        [sides,count(sides,edge_counts)]
   ];

function vertex_face_list(vertices,faces) =
    [for (i=[0:len(vertices)-1])
     let (vf= vertex_faces(i,faces))
     len(vf)];
    
function vertex_analysis(vertices,faces) =
  let (face_counts=vertex_face_list(vertices,faces))
  [for (vo = distinct(face_counts))
        [vo,count(vo,face_counts)]
   ];
// ensure that all faces have a lhs orientation
function cosine_between(u, v) =(u * v) / (norm(u) * norm(v));

function lhs_faces(faces,vertices) =
    [for (face = faces)
     let(points = as_points(face,vertices))
        cosine_between(normal(points), centre(points)) < 0
        ?  reverse(face)  :  face
    ];
  
// poly functions
//  constructor
function poly(name,vertices,faces,debug=[],partial=false) = 
    [name,vertices,faces,debug,partial];
    
// accessors
function p_name(obj) = obj[0];
function p_vertices(obj) = obj[1];
function p_faces(obj) = obj[2];
function p_debug(obj)=obj[3];
function p_partial(obj)=obj[4];
function p_edges(obj) = 
       p_partial(obj)
           ? all_edges(p_faces(obj))
           : distinct_edges(p_faces(obj));
function p_description(obj) =
    str(p_name(obj),
         ", ",str(len(p_vertices(obj)), " Vertices " ),
         vertex_analysis(p_vertices(obj), p_faces(obj)),
         ", ",str(len(p_faces(obj))," Faces "),
         face_analysis(p_faces(obj)),
         " ",str(len(p_non_planar_faces(obj))," not planar"),
          ", ",str(len(p_edges(obj))," Edges ")
     ); 
     
function p_faces_as_points(obj) =
    [for (f = p_faces(obj))
        as_points(f,p_vertices(obj))
    ];
    
function p_non_planar_faces(obj,tolerance=0.001) =
     [for (face = p_faces(obj))
         if (len(face) >3)
             let (points = as_points(face,p_vertices(obj)))
             let (error=face_coplanarity(points))
             if (error>tolerance) 
                 [tolerance,face]
     ];

function p_dihedral_angles(obj) =
     [for (edge=p_edges(obj))
         dihedral_angle(edge, p_faces(obj),p_vertices(obj))
     ];     
function p_irregular_faces(obj,tolerance=0.01) =
     [for (face = p_faces(obj))
         let(ir=face_irregularity(face,p_vertices(obj)))
         if(abs(ir-1)>tolerance)
               [ir,face]
      ];
             
function p_vertices_to_faces(obj)=
    [for (vi = [0:len(p_vertices(obj))-1])    // each old vertex creates a new face, with 
       let (vf=vertex_faces(vi,p_faces(obj)))   // vertex faces in left-hand order    
       [for (of = ordered_vertex_faces(vi,vf))
              index_of(of,p_faces(obj))    
       ]
    ];
       
module show_points(points,r=0.1) {
    for (point=points)
        if (point != [])   // ignore null points
           translate(point) sphere(r);
};

module show_edge(edge, r) {
    p0 = edge[0]; 
    p1 = edge[1];
    v = p1 -p0 ;
      orient_to(p0,v)
         cylinder(r1=r,r2=r, h=norm(v)); 
};

module show_edges(edges,points,r=0.1) {
    for (edge = edges)
        show_edge(as_points(edge, points), r); 
};

    
variedcolors=["green","blue","red","yellow","teal",
        ,"purple","orange",
        "paleGreen","slateblue","greenyellow",    
];

compcolors= [[252,141,89],[255,255,191],[145,191,219]];
twocolors= ["red","green"];
 
module show_directed_edge(e,r=1) {
     translate(e[0]) {
         sphere(r*1.5);
         translate((e[1]-e[0])*0.8) sphere(r);
     }
}

module show_face(s,t=thickness,edge=false) {
// render (convex) face by hulling spheres placed at the vertices
    hull()
    for (i=[0:len(s) -1])
       translate(s[i]) sphere(t/2);     
    if(edge) show_directed_edge([s[0],s[1]]);
} 

module show_faces(faces,t=thickness,edge=false,colors=["yellow"]) {
   for (i=[0:len(faces)-1]) {
      face=faces[i];
      color(colors[i%len(colors)])
      show_face(face,t=thickness,edge=edge);
   }
}
 
module p_show_faces(obj,t=thickness,edge=false) {
   pf=p_faces(obj);
   pv=p_vertices(obj);
   for (i=[0:len(pf)-1]) {
      face=as_points(pf[i],pv);
      color(colors[i%len(colors)])
      show_face(face,t=thickness,edge=edge);
   }
}      
module p_render(obj,show_vertices=false,show_edges=false,show_faces=true, rv=0.04, re=0.02) {
     if(show_faces) 
          polyhedron(p_vertices(obj),p_faces(obj),convexity=10);
     if(show_vertices) 
         show_points(p_vertices(obj),rv);
     if(show_edges)
         show_edges(p_edges(obj),p_vertices(obj),re);
};

module p_describe(obj){
    echo(p_description(obj));
}

module p_print(obj) {
    p_describe(obj);
    echo("Vertices " ,p_vertices(obj));
    echo("Faces ", p_faces(obj));
    edges=p_edges(obj);
    echo(str(len(edges),"Edges ",edges));
    non_planar=p_non_planar_faces(obj);
    echo(str(len(non_planar)," faces are not planar", non_planar));
    debug=p_debug(obj);
    if(debug!=[]) echo("Debug",debug);
};

// centering and resizing
        
function centre_points(points) = 
     vadd(points, - centre(points));
        
function p_inscribed_resize(obj,radius=1) =
    let(pv=centre_points(p_vertices(obj)))
    let (centres= [for (f=p_faces(obj))
                       norm(centre(as_points(f,pv)))
                      ])
    let (average = ssum(centres) / len(centres))
    poly(name=p_name(obj),
         vertices = pv * radius /average,
         faces=p_faces(obj),
         debug=centres
         );

function p_midscribed_resize(obj,radius=1) =
    let(pv=centre_points(p_vertices(obj)))
    let(centres= [for (e=p_edges(obj))
                  let (ep = as_points(e,pv))
                  norm((ep[0]+ep[1])/2)
                  ])
    let (average = ssum(centres) / len(centres))
    poly(name=p_name(obj),
         vertices = pv * radius /average,
         faces=p_faces(obj),
         debug=centres
         );

function p_circumscribed_resize(obj,radius=1) =
    let(pv=centre_points(p_vertices(obj)))
    let(average=average_norm(pv))
    poly(name=p_name(obj),
         vertices=pv * radius /average,
         faces=p_faces(obj),
         debug=average
    );
 
function p_resize(obj,radius=1) =
    p_circumscribed_resize(obj,radius);

// canonicalization

function rdual(obj) =
    let(np=p_vertices(obj))
    poly(name=p_name(obj),
           vertices =
                [ for (f=p_faces(obj))
                  let (c=centre(as_points(f,np)))
                     reciprocal(c)
                ]
           ,
           faces= p_vertices_to_faces(obj)  
           );
          
function plane(obj,n=5) = 
    n > 0 
       ? plane(rdual(rdual(obj)),n-1)   
       : p_resize(poly(name=str("P",p_name(obj)),
              vertices=p_vertices(obj),
              faces=p_faces(obj)
             ));

function ndual(obj) =
      let(np=p_vertices(obj))
      poly(name=p_name(obj),
           vertices = 
                [ for (f=p_faces(obj))
                  let (fp=as_points(f,np),
                       c=centre(fp),
                       n=average_normal(fp),
                       cdotn = c*n,
                       ed=average_edge_distance(fp))
                  reciprocal(n*cdotn) * (1+ed)/2
                ]
           ,  
           faces= p_vertices_to_faces(obj)        
           );
                
function canon(obj,n=5) = 
    n > 0 
       ? canon(ndual(ndual(obj)),n-1)   
       : p_resize(poly(name=str("K",p_name(obj)),
              vertices=p_vertices(obj),
              faces=p_faces(obj)
             ));   
             
function dual(obj) =
    poly(name=str("d",p_name(obj)),
         vertices = 
              [for (f = p_faces(obj))
               let(fp=as_points(f,p_vertices(obj)))
                 centre(fp)  
              ],
         faces= p_vertices_to_faces(obj)        
        )
;  // end dual
              
// Conway operators 
/*  where necessary, new vertices are first created and stored in an associative array, keyed by whatever is appropriate to identify the new vertex - this could be an old vertex id, a face, an edge or something more complicated.  This array is then used to create an associative array of key and vertex ids for use in face construction, and to generate the new vertices themselves. 
*/

function vertex_ids(entries,offset=0,i=0) = 
// to get position of new vertices 
    len(entries) > 0
          ?[for (i=[0:len(entries)-1]) 
             [entries[i][0],i+offset]
           ]
          :[]
          ;
   
function vertex_values(entries)= 
    [for (e = entries) e[1]];
 
function vertex(key,entries) =   // key is an array 
    entries[search([key],entries)[0]][1];
    
// operators
    
function kis(obj,height=0.1, fn=[]) =
// kis each n-face is divided into n triangles which extend to the face centre
// existimg vertices retained
              
   let(pf=p_faces(obj),
       pv=p_vertices(obj))
   let(newv=   // new centroid vertices    
        [for (f=pf)
         if (selected_face(f,fn))                      
             let(fp=as_points(f,pv))
             [f,centre(fp) + normal(fp) * height]    // centroid + a bit of normal
        ]) 
   let(newids=vertex_ids(newv,len(pv)))
   let(newf=
       flatten(
         [for (face=pf)   
            selected_face(face,fn)                     
         //replace face with triangles
              ? let(centre=vertex(face,newids))
                [for (j=[0:len(face)-1])           
                 let(a=face[j],
                     b=face[(j+1)%len(face)])    
                  [a,b,centre]
                ]
              : [face]                              // original face
         ]) 
        )         
  
   poly(name=str("k",p_name(obj)),
       vertices= concat(pv, vertex_values(newv)) , 
       faces=newf
   )
; // end kis

function gyro(obj, ratio=0.3333, height=0.2) = 
// retain original vertices, add face centres and directed edge points 
//  each N-face becomes N pentagons
    let(pf=p_faces(obj),
        pv=p_vertices(obj),
        pe=p_edges(obj))
    let(newv= 
          concat(
           [for (face=pf)  // centres
            let(fp=as_points(face,pv))
             [face,centre(fp) + normal(fp) * height]    // centroid + a bit of normal
           ] ,
           flatten(      //  2 points per edge
              [for (edge = pe)                 
               let (ep = as_points(edge,pv))
                   [ [ edge,  ep[0]+ ratio*(ep[1]-ep[0])],
                     [ reverse(edge),  ep[1]+ ratio*(ep[0]-ep[1])]
                   ]
               ]         
           ) 
          ))
    let(newids=vertex_ids(newv,len(pv)))
    let(newf=
         flatten(                        // new faces are pentagons 
         [for (face=pf)   
             [for (j=[0:len(face)-1])
                let (a=face[j],
                     b=face[(j+1)%len(face)],
                     z=face[(j-1+len(face))%len(face)],
                     eab=vertex([a,b],newids),
                     eza=vertex([z,a],newids),
                     eaz=vertex([a,z],newids),
                     centre=vertex(face,newids))                   
                [a,eab,centre,eza,eaz]  
            ]
         ]
       )) 
               
    poly(name=str("g",p_name(obj)),
      vertices=  concat(pv, vertex_values(newv)),
      faces= newf
      )
; // end gyro

            
function meta(obj,height=0.1) =
// each face is replaced with 2n triangles based on edge midpoint and centre
    let(pe=p_edges(obj),
        pf=p_faces(obj),
        pv=p_vertices(obj))
    let (newv =concat(
           [for (face = pf)               // new centre vertices
            let (fp=as_points(face,pv))
             [face,centre(fp) + normal(fp)*height]                                
           ],
           [for (edge=pe)
            let (ep = as_points(edge,pv))
            [edge,(ep[0]+ep[1])/2]
           ]))
     let(newids=vertex_ids(newv,len(pv)))
          
     let(newf =
          flatten(
          [for (face=pf) 
             let(centre=vertex(face,newids))  
             flatten(
              [for (j=[0:len(face)-1])    //  replace face with 2n triangle 
               let (a=face[j],
                    b=face[(j+1)%len(face)],
                    mid=vertex(distinct_edge([a,b]),newids))
                 [ [ mid, centre, a],
                    [b,centre, mid] ]  
                 ] )
         ])
      )   
               
     poly(name=str("m",p_name(obj)),
          vertices= concat(pv,vertex_values(newv)),                
          faces=newf
      ) 
 ; //end meta

function pyra(obj,height=0.1) =   
// very like meta but different triangles
    let(pe=p_edges(obj),
        pf=p_faces(obj),
        pv=p_vertices(obj))
    let(newv=concat(
          [for (face = pf)               // new centre vertices
            let(fp=as_points(face,pv))
            [face,centre(fp) + normal(fp)*height]                                  
          ],
         [for (edge=pe)               // new midpoints
          let (ep = as_points(edge,pv))
            [edge,(ep[0]+ep[1])/2]
         ]))
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=flatten(
         [ for (face=pf) 
           let(centre=vertex(face,newids))  
           flatten( [for (j=[0:len(face)-1]) 
             let(a=face[j],
                 b=face[(j+1)%len(face)], 
                 z=face[(j-1+len(face))%len(face)],        
                 midab = vertex(distinct_edge([a,b]),newids),
                 midza = vertex(distinct_edge([z,a]),newids))             
             [[midza,a,midab], [midza,midab,centre]]         
             ])
          ] ))
              
     poly(name=str("y",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )
;   // end pyra 
                                 
function ortho(obj,height=0.2) =  
// very like meta but divided into quadrilaterals
    let (pe=p_edges(obj),
         pf=p_faces(obj),
         pv=p_vertices(obj))

     let(newv=concat(
          [for (face = pf)               // new centre vertices
            let(fp=as_points(face,pv))
            [face,centre(fp) + normal(fp)*height]                                  
          ],
         [for (edge=pe)               // new midpoints
          let (ep = as_points(edge,pv))
            [edge,(ep[0]+ep[1])/2]
         ]))
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=
         flatten(
         [ for (face=pf)   
           let(centre=vertex(face,newids))  
            [for (j=[0:len(face)-1])    
             let(a=face[j],
                 b=face[(j+1)%len(face)],
                 z=face[(j-1+len(face))%len(face)],
                     midab= vertex(distinct_edge([a,b]),newids),
                     midza= vertex(distinct_edge([z,a]),newids))                 
             [centre,midza,a,midab]                    
                
             ]
          ] ))
      
     poly(name=str("o",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )
; // end ortho
       
function trunc(obj,ratio=0.25,fn=[]) =
    let (pv=p_vertices(obj),
         pf=p_faces(obj))
               
    let (newv = 
        flatten(
         [for (i=[0:len(pv)-1]) 
          let(v = pv[i])
          let(vf = vertex_faces(i,pf))
          selected_face(vf,fn)        // should drop the _face 
            ? let(oe = ordered_vertex_edges(i,vf))     
              [for (edge=oe)
               let(opv=pv[edge[1]])
                [edge,  v + (opv - v)*ratio]
              ]
            : [[[i],v]]
         ]))
     let (newids = vertex_ids(newv))   
     let (newf = 
          concat(    // truncated faces
             [for (face=pf)
              flatten(
              [for (j=[0:len(face)-1])
               let (a=face[j])
               let (nv=vertex([a],newids)) 
               nv != undef
               ?  nv   // not truncated, just renumbered
               :  let(b=face[(j+1)%len(face)],
                      z=face[(j-1+len(face))%len(face)],
                      eab=[a,b],
                      eaz=[a,z],
                      vab=vertex(eab,newids),
                      vaz=vertex(eaz,newids))
                 [vaz,vab]
 
              ])
             ],
          [for (i=[0:len(pv)-1])   //  truncated  vertexes
           let(vf = vertex_faces(i,pf))
           if (selected_face(vf,fn))
              let(oe = ordered_vertex_edges(i,vf))     
              [for (edge=oe)
               vertex(edge,newids)
             ]
          ] ) )    

     poly(name=str("t",p_name(obj)),
          vertices= vertex_values(newv),
          faces=newf
         )
; // end trunc

function propellor(obj,ratio=0.333) =
    let (pf=p_faces(obj),
         pv=p_vertices(obj),
         pe=p_edges(obj))
    let(newv=
         flatten(      //  2 points per edge
              [for (edge = pe)                 
               let (ep = as_points(edge,pv))
                   [ [ edge,  ep[0]+ ratio*(ep[1]-ep[0])],
                     [ reverse(edge),  ep[1]+ ratio*(ep[0]-ep[1])]
                   ]
               ]         
           ) 
         )
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=
         concat(    
            [for (face=pf)   // rotated face
               [ for (j=[0:len(face)-1])
                 let( a=face[j],
                      b=face[(j+1)%len(face)],
                      eab=[a,b],
                      vab=vertex(eab,newids))
                 vab
               ]  
            ]
            ,
            flatten(
             [for (face=pf)   
               [for (j=[0:len(face)-1])
                 let (a=face[j],
                      b=face[(j+1)%len(face)],
                      z=face[(j-1+len(face))%len(face)],          
                      eab=vertex([a,b],newids),
                      eba=vertex([b,a],newids),
                      eza=vertex([z,a],newids))   
                 [a,eba,eab,eza]
               ]
             ])            
           )
       )        
     poly(name=str("p",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )         
; // end propellor
     
function chamfer(obj,ratio=0.333) =
    let (pf=p_faces(obj),
         pv=p_vertices(obj))  
    let(newv=              
          flatten(         //  face inset
          [for(face=pf)
           let(fp=as_points(face,pv),
               c=centre(fp))
            [for (j=[0:len(face)-1])
               [[face,face[j]], fp[j] + ratio*(c - fp[j])]
            ]
          ])
        )
            
   let(newids=vertex_ids(newv,len(pv)))
   let(newf =   
         concat(    
            [for (face=pf)      // rotated faces
              [ for (v=face)
                  vertex([face,v],newids)  
              ]  
            ] ,
            flatten(         // chamfered pentagons
             [for (face=pf)   
               [
                 for (j=[0:len(face)-1])
                 let (
                      a=face[j],
                      b=face[(j+1)%len(face)])
                 if(a<b)     // dont duplicate
                 let (edge= [a,b],
                      oppface=face_with_edge([b,a],pf), 
                      oppa=vertex([oppface,a],newids),
                      oppb=vertex([oppface,b],newids),
                      thisa=vertex([face,a],newids),
                      thisb=vertex([face,b],newids))
                      [a,oppa,oppb, b,thisb,thisa]
               ]
             ])            
           ))  
    poly(name=str("c",p_name(obj)),
      vertices=
        concat( 
          [for (v = pv)  (1.0-ratio)*v],             // original        
           vertex_values(newv)
         ),
      faces=newf
    ); 
// end chamfer                   
              
              
function ambo(obj) =
  let (pf=p_faces(obj),
       pv=p_vertices(obj),
       pe=p_edges(obj))
  
          
  let(newv=
       [for (edge = pe)                 
        let (ep = as_points(edge,pv))
            [edge, (ep[0]+ep[1])/2 ] 
        ])
       
  let(newids=vertex_ids(newv))

  let(newf = 
       concat(
         [for (face = pf)
            [for (edge = distinct_face_edges(face))   // old faces become the same with the new vertices
              vertex(edge,newids)
            ]
         ]     
         ,        
        [for (vi = [0:len(pv)-1])        // each old vertex creates a new face, with 
           let (vf= vertex_faces(vi,pf)) // the old edges in left-hand order as vertices
           [for (ve = ordered_vertex_edges(vi,vf))
              vertex(distinct_edge(ve), newids)             
           ]
         ] 
          )) 
           
           
  poly(name=str("a",p_name(obj)),
       vertices = vertex_values(newv),  
       faces =  newf
       )
;// end ambo    
       
function snub(obj,height=0.5) = 
   let(pf=p_faces(obj),   
       pv=p_vertices(obj)  )       
       
   let(newv =
          flatten(
             [for (face = pf)   
              let (r = -90 / len(face),
                  fp = as_points(face,pv),
                  c = centre(fp),
                  n = normal(fp),
                  m =  m_from(c,n) 
                      * m_rotate([0,0,r]) 
                      * m_translate([0,0,height]) 
                      * m_to(c,n))
               [for (i=[0:len(face)-1]) 
                  [[face,face[i]], m_transform(fp[i],m)]
              ]
            ]))
   
   let(newids=vertex_ids(newv))
   let(newf =
         concat(
             [for (face = pf)   
               [for (v = face) 
                  vertex([face,v],newids)
               ]
              ],
               // vertex faces 
             [for (i=[0:len(pv)-1])   
              let (vf=vertex_faces(i,pf))     // vertex faces in left-hand order 
                 [for (of = ordered_vertex_faces(i,vf))
                   vertex([of,i],newids)
                  ] 
             ]
             ,   //  two edge triangles 
             flatten( 
               [for (face=pf)
                flatten( 
                 [for (edge=ordered_face_edges(face))
                  let (oppface=face_with_edge(reverse(edge),pf),
                        e00=vertex([face,edge[0]],newids),
                        e01=vertex([face,edge[1]],newids),                
                        e10=vertex([oppface,edge[0]],newids),                 
                        e11=vertex([oppface,edge[1]],newids) )
                   if (edge[0]<edge[1])
                      [
                         [e00,e10,e11],
                         [e01,e00,e11]
                      ] 
                   ])
                ])     
          ))      
            
   poly(name=str("s",p_name(obj)),
       vertices= vertex_values(newv),
       faces=newf
       )
; // end snub
   
function expand(obj,height=0.5) =                    
   let(pf=p_faces(obj),           
       pv=p_vertices(obj))        
   let(newv=
           flatten(
            [for (face = pf)     //move the whole face outwards
             let (fp = as_points(face,pv),
                  c = centre(fp),
                  n = normal(fp),
                  m =  m_from(c,n)
                      *  m_translate([0,0,height]) 
                      * m_to(c,n))
             [for (i=[0:len(face)-1]) 
                  [[face,face[i]], m_transform(fp[i],m)]
             ]
             ]))
   let(newids=vertex_ids(newv))
   let(newf =
          concat(
             [for (face = pf)     // expanded faces
               [for (v = face) 
                  vertex([face,v],newids)
               ]
              ],
                 // vertex faces 
              [for (i=[0:len(pv)-1])   
               let (vf=vertex_faces(i,pf))   
                  [for(of=ordered_vertex_faces(i,vf))
                     vertex([of,i],newids)
                  ]
                 ]
               ,       //edge faces                 
               flatten([for (face=pf)
                  [for (edge=ordered_face_edges(face))
                   let (oppface=face_with_edge(reverse(edge),pf),
                        e00=vertex([face,edge[0]],newids),
                        e01=vertex([face,edge[1]],newids),                 
                        e10=vertex([oppface,edge[0]],newids),                
                        e11=vertex([oppface,edge[1]],newids)) 
                   if (edge[0]<edge[1])   // no duplicates
                      [e00,e10,e11,e01] 
                   ]
                ] )           
              ))
                   
   poly(name=str("e",p_name(obj)),
       vertices= vertex_values(newv),
       faces=newf
      )
         
; // end expand

function rexpand(s,height,n=0) =
// used to round edges 
    n == 0
         ? s
         : rexpand(expand(s,height),height*2,n-1)
;
                   
function whirl(obj, ratio=0.3333, height=0.2) = 
// retain original vertices, add directed edge points  and rotated inset points
//  each edge  becomes 2 hexagons
    let(pf=p_faces(obj),
        pv=p_vertices(obj),
        pe=p_edges(obj))
    let(newv= 
          concat(          
           flatten([for (face=pf)  // centres
            let (fp=as_points(face,pv))
            let (c = centre(fp))
            [for (i=[0:len(face)-1])
             let (f = face[i])
             let (ep = [fp[i],fp[(i+1) % len(face)]])
             let (mid =  ep[0]+ ratio*(ep[1]-ep[0])) 
              [[face,f], mid + ratio * (c - mid)]
           ]]) ,
           flatten(      //  2 points per edge
              [for (edge = pe)                 
               let (ep = as_points(edge,pv))
                   [ [ edge,  ep[0]+ ratio*(ep[1]-ep[0])],
                     [ reverse(edge),  ep[1]+ ratio*(ep[0]-ep[1])]
                   ]
               ]         
           ) 
          ))
    let(newids=vertex_ids(newv,len(pv)))
    let(newf=concat(
         flatten(                        // new faces are pentagons 
         [for (face=pf)   
             [for (j=[0:len(face)-1])
                let (a=face[j],
                     b=face[(j+1)%len(face)],
                     c=face[(j+2)%len(face)],
                     eab=vertex([a,b],newids),
                     eba=vertex([b,a],newids),
                     ebc=vertex([b,c],newids),
                     mida=vertex([face,a],newids),                   
                     midb=vertex([face,b],newids))                   
                [eab,eba,b,ebc,midb,mida]  
            ]
         ]
       )
     ,
        [for (face=pf)   
             [for (j=[0:len(face)-1])
                let (a=face[j])
                vertex([face,a],newids)                  
             ]
         ]            
        )) 
               
    poly(name=str("w",p_name(obj)),
      vertices=  concat(pv, vertex_values(newv)),
      faces= newf,
      debug=newv
      )
; // end whirl
             
            
function reflect(obj) =
    poly(name=str("r",p_name(obj)),
        vertices =
          [for (p = p_vertices(obj))
              [p.x,-p.y,p.z]
          ],
        faces=  // reverse the winding order 
          [ for (face =p_faces(obj))
              reverse(face)
          ]
    )
;  // end reflect

function ident(obj) =
          // identity operation 
    obj
;  // end nop 
          
function join(obj) =
    let(name=p_name(obj))
    let(p = dual(ambo(obj)))
    poly(name=str("j",name),
         vertices =p_vertices(p),         
         faces= p_faces(p)
    )
;  // end join 
          
function bevel(obj) =
    let(name=p_name(obj))
    let(p = trunc(ambo(obj)))
    poly(name=str("b",name),
         vertices =p_vertices(p),         
         faces= p_faces(p)
    )
;  // end bevel

function random(obj,offset=0.1) =
    poly(name=str("x",p_name(obj)),
         vertices =
          [for (v = p_vertices(obj))
             v + rands(0,offset,3)
          ],
        faces= p_faces(obj)
     )
; 

function qt(obj) =
// triangulate quadrilateral faces
// use shortest diagonal so triangles are most nearly equilateral
  let (pf=p_faces(obj),
       pv=p_vertices(obj))
           
  poly(name=str("u",p_name(obj)),
       vertices=pv,          
       faces= flatten(
           [for (f = pf)
            len(f) == 4
              ?  norm(f[0]-f[2]) < norm(f[1]-f[3])
                   ? [ [f[0],f[1],f[2]], [f[0],f[2],f[3]] ]  
                   : [ [f[1],f[2],f[3]], [f[1],f[3],f[0]] ]         
              :  [f]
           ])
       )
;// end qt
        
function pt(obj) =
// triangulate pentagonal faces
  let (pf=p_faces(obj),
       pv=p_vertices(obj))
           
  poly(name=str("u",p_name(obj)),
       vertices=pv,          
       faces= flatten(
           [for (f = pf)
            len(f) == 5
              ?  [[f[0],f[1],f[4]], [f[1],f[2],f[4]], [f[4],f[2],f[3]]]
              :  [f]
           ])
       )
;// end pt
                 
function tt(obj) =
// replace triangular faces with 4 triangles  
// requires  all faces to be triangular
  let (pf=p_faces(obj),
       pv=p_vertices(obj),
       pe=p_edges(obj))
  
  let (newv=  // edge mid points 
       [for (edge=pe)
          let (ep = as_points(edge,pv))
             [edge, (ep[0]+ep[1])/2]
        ])
  let(newids=vertex_ids(newv,len(pv)))
  let(newf =
          flatten(
          [for (i =[0:len(pf)-1])
            let(face = pf[i])
            let(innerface = 
                    [vertex(distinct_edge([face[0],face[1]]),newids),
                     vertex(distinct_edge([face[1],face[2]]),newids),
                     vertex(distinct_edge([face[2],face[0]]),newids)
                    ])
           
            concat(
                  [innerface],
                  [for (j=[0:2]) 
                     [face[j],
                      innerface[j],
                      innerface[(j-1 +len(face))%len(face)]
                     ]  
                  ])         
           ]))

  poly(name=str("u",p_name(obj)),
       vertices=
           concat(pv, vertex_values(newv)),  
       faces= newf
       )
;// end tt

function inset_kis(obj,ratio=0.5,height=-0.1, fn=[]) = 
 // as kis but pyramids inset in the face 
    let (pe=p_edges(obj),
         pf=p_faces(obj),
         pv=p_vertices(obj))
     
    let(newv =
         flatten(  
          [for (face = pf)               // new centre vertices
            let(fp=as_points(face,pv))
            if (selected_face(face,fn))
               let(c=centre(fp))
               let(ec = c+ normal(fp)*height)     // centroid + a bit of normal  
               concat(  
                      [[face,ec]],      // face centre
                      [ for (j=[0:len(face)-1])
                         [[face,face[j]], fp[j] + ratio*(c-fp[j])]
                      ]
                     )
           ]))
   let(newids=vertex_ids(newv,len(pv)))
   let(newf =
          flatten([for (i = [0:len(pf)-1])   
            let(face = pf[i])
            selected_face(face,fn)
              ? flatten(
                 [for (j=[0:len(face)-1])   //  replace face with n quads and n triangles 
                  let (a=face[j],
                       centre=vertex(face,newids),
                       mida=vertex([face,a],newids),
                       b=face[(j+1)%len(face)],
                       midb=vertex([face,b],newids)) 
                   [ [a,b,midb,mida]  ,   [centre,mida,midb] ]         
                 ] )
              : [ face ]
         ] ))       
   
    poly(name=str("x",p_name(obj)),
      vertices=  concat(pv, vertex_values(newv)) ,
      faces= newf
    )
;   // end inset_kis
               
function transform(obj,matrix) =
   poly(
       name=str("T",p_name(obj)),
       vertices=transform_points(p_vertices(obj),matrix),
       faces=p_faces(obj));

function place(obj,face_i) =
// on largest face for printing
   let (face= face_i == undef ? max_area(face_areas_index(obj)) : p_faces(obj)[face_i])
   let (points =as_points(face,p_vertices(obj)))
   let (n = normal(points), c=centre(points))
   let (m=m_from(c,-n))
   transform(obj,m)
;

function orient(obj) =
// ensure faces have lhs order
    poly(name=str("O",p_name(obj)),
         vertices= p_vertices(obj),
         faces = lhs_faces(p_faces(obj),p_vertices(obj))
    );
 
function invert(obj,p) =
// invert vertices 
    poly(name=str("I",p_name(obj)),
         vertices= 
            [ for (v =p_vertices(obj))
              let (n=norm(v))
              v /  pow(n,p)  
            ],
         faces = p_faces(obj)
    );

function shell(obj,outer_inset_ratio=0.2, outer_inset, inner_inset_ratio, inner_inset,thickness=0.2,fn=[],min_edge_length=0.01,nocut=0) = 
// upper and lower inset can be specified by ratio or absolute distance
   let(inner_inset_ratio= inner_inset_ratio == undef ? outer_inset_ratio : inner_inset_ratio,
       pf=p_faces(obj),           
       pv=p_vertices(obj))
   let(inv=   // corresponding points on inner surface
       [for (i =[0:len(pv)-1])
        let(v = pv[i])
        let(norms =
            [for (f=vertex_faces(i,pf))
             let (fp=as_points(f,pv))
                normal(fp)
            ])
        let(av_norm = -vsum(norms)/len(norms))
            v + thickness*unitv(av_norm)
        ])
                 
   let (newv =   
 // the inset points on outer and inner surfaces
 // outer inset points keyed by face, v, inner points by face,-v-1
         flatten(
           [ for (face = pf)
             if(selected_face(face,fn)
                && min_edge_length(face,pv) > min_edge_length)
                 let(fp=as_points(face,pv),
                     ofp=as_points(face,inv),
                     c=centre(fp),
                     oc=centre(ofp))
                 flatten(
                    [for (i=[0:len(face)-1])
                     let(v=face[i],
                         p = fp[i],
                         p1= fp[(i+1)%len(face)],
                         p0=fp[(i-1 + len(face))%len(face)],
                         sa = angle_between(p0-p,p1-p),
                         bv = (unitv(p1-p)+unitv(p0-p))/2,
                         op= ofp[i],
                         ip = outer_inset ==  undef 
                             ? p + (c-p)*outer_inset_ratio 
                             : p + outer_inset/sin(sa) * bv ,
                         oip = inner_inset == undef 
                             ? op + (oc-op)*inner_inset_ratio 
                             : op + inner_inset/sin(sa) * bv)
                     [ [[face,v],ip],[[face,-v-1],oip]]
                    ])
             ])          
           )
   let(newids=vertex_ids(newv,2*len(pv)))
   let(newf =
         flatten(
          [ for (i = [0:len(pf)-1])   
            let(face = pf[i])
            flatten(
              selected_face(face,fn)
                && min_edge_length(face,pv) > min_edge_length
                && i  >= nocut    
              
                ? [for (j=[0:len(face)-1])   //  replace N-face with 3*N quads 
                  let (a=face[j],
                       inseta = vertex([face,a],newids),
                       oinseta= vertex([face,-a-1],newids),
                       b=face[(j+1)%len(face)],
                       insetb= vertex([face,b],newids),
                       oinsetb=vertex([face,-b-1],newids),
                       oa=len(pv) + a,
                       ob=len(pv) + b) 
                  
                     [
                       [a,b,insetb,inseta]  // outer face
                      ,[inseta,insetb,oinsetb,oinseta]  //wall
                      ,[oa,oinseta,oinsetb,ob]  // inner face
                     ] 
                   ] 
                :  [[face],  //outer face
                    [reverse([  //inner face
                           for (j=[0:len(face)-1])
                           len(pv) +face[j]
                         ])
                    ]
                   ]    
               )
         ] ))    
                           
   poly(name=str("S",p_name(obj)),
       vertices=  concat(pv, inv, vertex_values(newv)) ,    
       faces= newf,
       debug=newv       
       )
; // end shell  
                           

// modulation  
                           
function modulate_points(points) =
   [for(p=points)
       let(s=xyz_to_spherical(p),
           fs=fmod(s[0],s[1],s[2]))
       spherical_to_xyz(fs[0],fs[1],fs[2])
   ];

function xyz_to_spherical(p) =
    [ norm(p), acos(p.z/ norm(p)), atan2(p.x,p.y)] ;

function spherical_to_xyz(r,theta,phi) =
    [ r * sin(theta) * cos(phi),
      r * sin(theta) * sin(phi),
      r * cos(theta)];

function fstar(r,theta,phi)=
      [r*(1.0 + 0.5*pow((cos(3*phi)),2)), theta ,phi];  
   
function fegg(r,theta,phi) = 
     [r*(1.0+ 0.5*pow(1.1*(cos(1*theta)),3)), theta,phi];

function fberry(r,theta,phi) =
     [r*(1.0 - 0.5*pow(0.8*(cos(theta+60)),2)),theta,phi];       

function fcushion(r,theta,phi) =
     [r*(1.0 - 0.5*pow(0.9*cos(theta),2)), theta, phi];
          
function fbauble(r,theta,phi) = 
     [r*(1- 0.5*sin(theta*2) + 0.1* sin(theta)*sqrt(abs(cos(theta*2))))
          / (sin(theta)), theta,phi] ;

function fellipsoid(r,theta,phi,e) = [r*(1.0+pow(e*cos(theta),2)),theta,phi] ;
  
function fsuperegg(r,theta,phi,n,e=1) =
       [ r* (pow(
               pow(abs(cos(theta)),n) 
           + e*pow(abs(sin(theta)),n)
            ,-1/n))
         ,theta,phi];
         
function fsupersuperegg(r,theta,phi,nt,et=1,np=2,ep=1) =
       [ r* (pow(
               pow(abs(cos(theta)),nt) 
           + et*pow(abs(sin(theta)),nt)
            ,-1/nt))
            
         * (pow(
               pow(abs(cos(phi)),np) 
           + ep*pow(abs(sin(phi)),np)
            ,-1/np))
         ,theta,phi];
 
function modulate(obj) =
    poly(name=str("S",p_name(obj)),
         vertices=modulate_points(p_vertices(obj)),         
         faces= 
          [ for (face =p_faces(obj))
              reverse(face)
          ]
    )
;  // end modulate

// object trimming

module ground(z=200) {
   translate([0,0,-z]) cube(z*2,center=true);
} 

module sky(z=200) {
   rotate([0,180,0]) ground(z);
}

// animation shaping
function ramp(t,dwell) =
// to shape the animation to give a dwell at begining and end
   t < dwell 
       ? 0
       : t > 1 - dwell 
         ? 1
         :  ( t-dwell) /(1 - 2 * dwell);

function updown(t,dwell) =
    let(ramp=(1 - 2 * dwell)/2)
    t < dwell ? 0 :
        t < 0.5 ?( t-dwell)/ramp :
           t < 0.5 +dwell ? 1 :
              1 - (t - ramp - 2*dwell)/ramp;
  

/*
//  superegg_tktI  - Goldberg (3,3)  
function fmod(r,theta,phi) = fsuperegg(r,theta,phi,2.5,1.3333);
s= modulate(plane(trunc(plane(kis(trunc(I()))))));
echo(p_description(s));                    
t=shell(s,thickness=0.15,outer_inset_ratio=0.35,inner_inset_ratio=0.2,fn=[6]);              
scale(20)  p_render(t,false,false,true);

*/

/*
s=shell(plane(trunc(plane(kis(plane(trunc(D())), fn=[10])), fn=[10])));
// s=trunc(plane(kis(T)),fn=[3]);
p_describe(s);
scale(10) p_render(s,false,false,true);
*/

/*
s=place(canon(plane(propellor(D()),10),10));
p_describe(s);
scale(20) p_render(shell(s,outer_inset=0.15,fn=[],thickness=0.2));

*/

/*
s=plane(whirl(plane(trunc(I()))));
p_print(s);
scale(10) p_render(shell(s,fn=[6]),false,false,true);


*/
/*
s=transform(plane(chamfer(plane(chamfer(D())))),m_translate([0,0,0.3])*m_scale([1,1.5,2]));
t=shell(s,fn=[0]);
p_print(t);
scale(20) difference() {
    translate([0,0,-0.5]) p_render(t,false,false,true,re=0.08,rv=0.08);
    ground();
}
*/
/*
o = Y(5);
scale(30) p_render(o);
p_print(o);

echo (distinct(p_dihedral_angles(o)));

*/
/*
               
function (congruent(face1,face2)  
  // rotation  if face1 is congruent to face2  else  undef
    
function identify_faces(vertices,faces)
  // for each face - flatten the face, orient the face so face[0] is at origin, face[1] lies along the +x axis
 
function identify_angles(vertices,faces,net)   
  // for each edge in the net, compute the dihedral angle 
  // compute the distinct dihedral angles 
  // augment the list of edges with the dihedral angle
*/ 
   
function face_index_with_edge(edge,faces) =   
        [for (i=[0:len(faces)-1]) 
         let (ei=index_of(edge,ordered_face_edges(faces[i])))
         if (ei != [])
            [i,ei]
        ][0];
           
function adjacent_face_edges(i,faces,side)  = 
// return [side, adj-face, adj_side] 
      let(face=faces[i],
          ofe= ordered_face_edges(face))
      [for (j=[0:len(face)-1])
         let(ei=(j-side+len(face))%len(face),
             edge=ofe[j],
             opedge=reverse(edge),
             opface_side=face_index_with_edge(opedge,faces))
        flatten([ei,opface_side])
      ] ;

function p_create_net(obj) =
// sort to get faces in nside order and start with largest
// queue entries comprise [face,side]
     let (faces=p_faces(obj),
          points=p_vertices(obj),
          kv_faces = quicksort_kv(
               [for (i=[0:len(faces)-1])
                     [face_area(as_points(faces[i],points)),i]
               ]), 
          start = head(kv_faces)[1],
          queue= [[start,0]],  
          included = [start],
          net= []) 
     create_net(faces,points,queue,included,net);

function create_net(faces,points,queue,included,net,i=0) =
     len(queue) == 0 
          ? net
          :  let(next=head(queue),
                 root=next[0],
                 side=next[1],
                 adjacent_face_edges = adjacent_face_edges(root,faces,side),
               // structured as  [ side,face_index,face_side ]
                 new_face_edges= 
                  [for (i = [0:len(adjacent_face_edges)-1])
                   let (face_edge=adjacent_face_edges[i],
                        adjacent_face=face_edge[1])
                   if (!vcontains(adjacent_face,included)) 
                       face_edge
                   ])
//             true ? adjacent_face_edges :    
             len(new_face_edges) > 0 
                 ? let (keyed_face_edges = 
                         [ for (i=[0:len(new_face_edges)-1])
                           let(fe=new_face_edges[i])
                           [face_area(as_points(faces[[fe[1]]],points)),fe]],
                       sorted_face_edges=
                           [ for (kfe=quicksort_kv(keyed_face_edges))
                             kfe[1]
                           ],                        
                        adjacent_faces= 
                            [for (fe = sorted_face_edges) fe[1]],
                        includedx = flatten(concat(included, adjacent_faces)),
                        queuex=enque(deque(queue), 
                               [for (fe=sorted_face_edges) [[fe[1],fe[2]]]]),
                        subtree= concat([root],
                               [[for (face_edge = sorted_face_edges)
                                let (adjacent_face= face_edge[1],
                                     angle=dihedral_angle_faces(root,adjacent_face,faces,points))
                                flatten(concat(face_edge,angle))
                               ]]),
                        netx=concat(net,[subtree]))
                   create_net(faces,points,queuex,includedx,netx,i+1)
                :  create_net(faces,points,deque(queue),included,net,i+1) ;
    
function face_transform(face,m) =
     [ for (v = face) m_transform(v,m) ];

function rotate_about_edge(a,face,edge) =
     let (v1 = face[edge], v2= face[(edge+1) %len(face)])
     let (m = m_rotate_about_line(a,v1,v2))
     face_transform(face,m);
                         
function face_edge(face,side) =
    [face[side], face[(side+1) %len(face)]];

function line(edge) = edge[1]-edge[0];
   
function place_face(a,base,base_side,face,face_side=0) =
//  face is the face whose face_side is to be placed on the base_side of base at angle a
//  face is on xy plane with side 0 along x axis
//  note the face_side edge is reversed when placed on the matching base side
     let (base_normal= normal(base),
          base_edgev=face_edge(base,base_side),
          base_corner=base_edgev[0],
          face_edgev=face_edge(face,face_side), 
          mb = m_rotate_to(base_normal),
          b_face= face_transform(face,mb),  // rotate face so plane is parallel to base
          b_face_corner = face_edge(b_face,face_side)[1],
          offset = base_corner - b_face_corner,
          mc = m_translate(offset),      
          c_face= face_transform(b_face,mc), // translate so face-edge[1] coincides with base_edge[0]
          c_face_edgev= reverse(face_edge(c_face,face_side)),      
          line_face=line(c_face_edgev),
          line_base=line(base_edgev),
          angle = angle_between(line_face,line_base,base_normal),  // compute angle between edges
          md =  m_rotate_about_line(angle, base_corner, base_corner +base_normal), 
          d_face= face_transform(c_face,md),  //rotate about base_edge[0] normal to the plane of base
          e_face = rotate_about_edge(a,d_face,face_side) //rotate a degrees about this edge
          )
      shift(e_face,shift=face_side);  // rotatee the sides so the edge is side 0

// rendering  
   
module p_net_render(t,net,complete,scale=10,edge=false,colors=["yellow"]) {
    start=net[0][0];
    faces = faces_to_origin(t,scale);    
    net_faces = dflatten(net_render(net,faces,complete,start));
    mirror([0,0,1])
        show_faces(net_faces,t=thickness,edge=edge,colors=colors);
}
 
function net_render(net,faces,complete,root,current) =
   let (tree= find(root,net))
   tree == undef 
      ? []
      :
       let(
          adjacents=tree[1],
          root_face = 
              current == undef 
              ? faces[root]
              : current)
       concat ( 
              current==undef ? [root_face] : [],              // first face 
              len(adjacents) > 0
              ? [for (adjacent = adjacents)
                 let (root_side=adjacent[0],
                      face_index=adjacent[1],
                      face_side=adjacent[2],
                      dihedral=adjacent[3],
                      angle = (180-dihedral)*complete,
                      face= faces[face_index] 
                      )
                  let (tface=place_face(angle,root_face,root_side,face,face_side))
                  concat([tface],net_render(net,faces,complete,face_index,tface))
                ]
              : []   
           ); 
            
function face_to_origin(face,scale) =
   let(
       aface= face_transform(face,m_scale([scale,scale,scale])), 
       bface = face_transform(aface, m_rotate_from(normal(aface))),
       cface=face_transform(bface,m_translate(-bface[1])),
       angle = atan2(cface[0][1],cface[0][0]),    
       dface=face_transform(cface,m_rotate([0,0,-angle]))
       )
       dface;
     
function faces_to_origin(obj,scale) =
// place face with vertex 1 at the origin, vertex 0 alomg the x axis
// and in the XY plane
    let(faces=p_faces(obj), vertices=p_vertices(obj))
    [for (i=[0:len(faces)-1])
       let(face=faces[i])
       let (points = as_points(face,vertices))
       face_to_origin(points,scale)
    ];

// t=plane(join(D()),20);
// t=canon(plane(snub(C()),20),20);
// t=place(O());
// t=trunc(T());
// t=place(A(3,0.5));
// t = plane(kis(T()));
// t=C();
// t=orient(rhombic_enneacontahedron() );
// t= plane(expand(D()));
// t=canon(plane(join(plane(trunc(I()))),20),20);
// t=canon(plane(trunc(I())));
// t=D();
// t=chamfer(C(),0.3);
// t=random(T(),1.0);
// echo(t);
// translate([0,0,30]) scale(5) p_render(t);
// t = canon(plane(snub(D())),30);
// t=StewartsG3();
// t=kis(O(),1.15);

// t=D();

t=random(kis(C(),-0.2),0.3);

p_describe(t);
echo(p_dihedral_angles(t));
$fn=5;
thickness=0.1;
length=10;
              
$t=0.3;
complete=updown($t,0.05); 
    
net = p_create_net(t);
echo("net", net);
// p_net_render(t,net,complete);
p_net_render(t,net,0,colors=variedcolors);
p_net_render(t,net,1,colors=["gray"]);
// translate ([20,0,0]) scale(10) p_render(place(t));

