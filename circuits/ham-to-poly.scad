huse <../lib/basics.scad>
use <../lib/poly.scad>
use <solid.scad>

/*
  given a polyhedron (defined in solid.scad)  and a circuit as sequence of face indexes
  
  construct a path : 
    for each face in the circuit
    get the previous and next faces
    get the common edges between the previous face and the next face
    get the intersection of the two edges  C
    get the two edge midpoints  V0,V1
    interpolate in increments to compute the points on an arc centered on C between V0 and V1  (or a straight line if edges are parallel)
    
  construct a cut by following the path and construct a sequence of pyramids form the centre to the path
  
  construct a tube by constructing a chain of spheres along the path.
  
  construct an object by removing the cut or the tube from the original polyhedron
*/

function face_edges(face) =
    [for (i=[0:len(face)-1])
        [face[i],face[(i+1)%len(face)]]
    ];
    
function union(list1,list2) =
   flatten([for (a=list1)
           flatten( [for( b=list2)
                  if (a==b) a
               ]
           ) ] );
                  
 function common_edge(face1,face2) =
      let (edges1 = face_edges(face1),
           edges2 = face_edges(reverse(face2)))
      union(edges1,edges2);
 
 function arc_point(c,v0,v1,t) =
   let( p=  v0 * (1 - t) + v1* t,
        r0=norm(v0-c),
        r1=norm(v1-c),
        r= r0* (1-t) + r1 * t)
        c + unitv(p-c)*r ;
 
 function 3D_line_intersection( line1, line2, prec=1e-6) =
//by Ronaldo
  let(
    p0 = line1[0],
    p1 = line1[1],
    q0 = line2[0],
    q1 = line2[1])
    
  assert(norm(p1-p0)>prec) // assert well defined lines
  assert(norm(q1-q0)>prec)
  let(d  = cross( p1-p0, q1-q0 )) // normal to lines if non zero
  norm(d) < prec // (nearly) coincident or parallel lines ?
  ? norm(cross( q1-p0, p1-p0 )) <=prec *norm(q1-p0)*norm(p1-p0)
    ? undef  // coincident lines
    : []     // disjoint parallel lines
  : let( d = d/norm(d) )
    abs(d*(p1-q1)) > prec // are the lines disjoint ?
    ? [] // disjoint lines
    : let( // computes the crossing points
        crxq = cross(d, q1-q0),
        crxp = cross(d, p1-p0),
        u = crxq*(q0-p0)/(crxq*(p1-p0)),
        v = crxp*(p0-q0)/(crxp*(q1-q0))
      )
      [p0 + u*(p1-p0), q0 + v*(q1-q0)]; 
                    
function most_distant(c,e) =
    norm(e[0] - c) > norm(e[1] -c)
       ? e[0]
       : e[1];
 
function edge_normal(e1,e2) =
   let (v = cross(e1[1]-e1[0], e2[1]- e2[0]))
   v / norm(v);
   
 function face_path(cycle,k,faces,vertices,delta,inset=0) =
      let (face=faces[cycle[k]],
           face0=faces[cycle[(k-1+len(cycle))%len(cycle)]],
           face1=faces[cycle[(k+1)%len(cycle)]],
           e0 = common_edge(face,face0),
           e1=  common_edge(face,face1),
           e0v=  as_points(e0,vertices),
           e1v = as_points(e1,vertices),
           normal=normal(as_points(face,vertices)),     // simplifiy
           c= 3D_line_intersection(e0v,e1v)[0])
           c != undef 
       ? let( 
           p0= most_distant (c,e0v),
           p1= most_distant (c,e1v),
           v02= (e0v[0] + e0v[1])/2,
           v12= (e1v[0] + e1v[1])/2
           )
           [for (t=[inset*2:delta:1-inset*2])
              arc_point(c,v02,v12,t) - inset*normal
           ]
       :  let (
             v02= (e0v[0]+e0v[1])/2,
             v12= (e1v[0]+e1v[1])/2,
             normal=normal(as_points(face,vertices)))
            [for (t=[inset:delta:1-inset])
              v02 *(1-t)+ v12*t  - inset*normal
            ]
       ;
           
                       
function  cycle_path(cycle,faces,vertices,delta,inset) =
    [for (i=[0:len(cycle)-1]) 
         face_path(cycle,i,faces,vertices,delta,inset)
    ];
       
module make_tube(path,r) {
    for (i=[0:len(path) - 1]) 
      hull() {
         translate(path[i]) sphere(r);  
         translate(path[(i+1)%len(path)]) sphere(r);  
     }  
 }
 
module make_cut(path,r) {
    for (i=[0:len(path) - 1]) 
      hull() {
         hull() {sphere(r); translate(path[i]) sphere(r); }; 
         hull() { sphere(r); translate(path[(i+1)%len(path)]) sphere(r);};  
     }  
 }
     
function join_paths(paths,path=[],i=0) =
   i>= len(paths)
      ? path 
      : join_paths(paths, concat(path,paths[i]) ,i+1);
 
 function cycle_to_path(cycle,solid,delta,inset) =
      let (paths= cycle_path(cycle,p_faces(solid),p_vertices(solid),delta,inset)) 
      join_paths(paths);


function to_strings(numbers) =
   [for (n=numbers) str(n)];
 
function numbers(n) =
   to_strings([1:n]);
 
function cycle_faces(cycle) =
   let (l =  [for (i=[0:len(cycle)-1] ) [cycle[i],i+1]],
        sl= quicksort(l)
        )
   [for (e = sl) e[1]];      

solid=Z();
 
$fn=4;
r=0.01;
delta=0.05; 
inset=0; 
cycle1=[7, 10, 1, 3, 9, 4, 11, 6, 5, 2, 8, 0];
   
path1= cycle_to_path(cycle1,solid,delta,inset);   
   


scale(40) {
  *  make_cut(path1,r);
  * make_tube(path1,0.11,$fn=10);
  * p_render_text(solid,to_strings(cycle_faces(cycle1)),"Georgia",0.8,4,0.02);
 
difference() {
   * p_render_text(solid,to_strings(cycle_faces(cycle1)),"Georgia",0.8,4,0.02);

     show_solid(solid);
*    make_tube(path1,r=0.12,$fn=10);
     make_cut(path1,r);
    }
}

