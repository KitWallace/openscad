use <../lib/basics.scad>
use <../lib/poly.scad>
use <../lib/conway.scad>


/*
  given a polyhedron  and a sequenee of  connected faces
   for each face 
    get adjacent faces in the cycle
    get its commn edges
    get its commn vertex  C
    get the edge midpoints  V0,V1
    interpolate an arc centered on C between V0 and V1  constructing a tube by hulling spheres
    inset the arc nrmal to the face to make a captive channel
    subtract these tubes from the solid
    
    need to check fr connectedness and closedness
    concatenate paths, reversing path if necesaary
    
*/

function face_edges(face) =
    [for (i=[0:len(face)-1])
        [face[i],face[(i+1)%len(face)]]
    ];
    
function common(list1,list2) =
   flatten([for (a=list1)
           flatten( [for( b=list2)
                  if (a==b) a
               ]
           ) ] );
                  
 function common_edge(face1,face2) =
      let (edges1 = face_edges(face1),
           edges2 = face_edges(reverse(face2)))
      common(edges1,edges2);
 
 function face_path(cycle,k,faces,vertices,inset,delta) =
      let (face=faces[cycle[k]],
           face0=faces[cycle[(k-1+len(cycle))%len(cycle)]],
           face1=faces[cycle[(k+1)%len(cycle)]],
           e0 = common_edge(face,face0),
           e1= common_edge(face,face1),
           c = common(e0,e1)[0])
           c != undef   // adjacent edges
       ? let( 
           p0= e0[0]== c ? e0[1] : e0[0],
           p1= e1[0]== c ? e1[1] : e1[0],
           vc=vertices[c],
           v0=vertices[p0],
           v1=vertices[p1],
           v02= (vc+v0)/2,
           v12= (vc+v1)/2,
           normal=normal(as_points(face,vertices))     
          )
           [for (t=[0:delta:1])
              arc_point(vc,v02,v12,t) - normal * inset
           ]
       :  let (
             e0v=  as_points(e0,vertices),
             e1v = as_points(e1,vertices),
             v02= (e0v[0]+e0v[1])/2,
             v12= (e1v[0]+e1v[1])/2,
             normal=normal(as_points(face,vertices)))
            [for (t=[0:delta:1])
              t*v02 +(1-t)* v12 - normal * inset
            ]
       ;
                       
function arc_point(c,v0,v1,t) =
   let( p= v0* t + v1 * (1 - t),
        r0=norm(v0-c),
        r1=norm(v1-c),
        r= r0* t + r1 * (1-t))
        c + unitv(p-c)*r ;
        
module make_tube(path,r) {
    for (i=[0:len(path) - 2]) 
      hull() {
         translate(path[i]) sphere(r);  
         translate(path[(i+1)]) sphere(r);  
     }  
 }
         
module cycle_path(cycle,faces,vertices,r,inset,delta) {
        for (i=[0:len(cycle)-1]) {
            path= face_path(cycle,i,faces,vertices,inset,delta);
//            echo(path);
            make_tube(path,r);
        }   
};

function numbers(n) =
   [for (i=[0:n-1]) str(i)];
       
solid=C();
             
faces = p_faces(solid);
vertices = p_vertices (solid);
 
$fn=10;
r=0.1;
inset=0;
delta=0.1;

difference() {
   p_render_text(solid,numbers(6),"Georgia",0.8,4,0.03);
   cycle_path([0,1,4,3,5,2],faces,vertices,r,inset,delta);  
}
  
