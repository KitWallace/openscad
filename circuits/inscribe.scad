use <../lib/basics.scad>
use <../lib/poly.scad>
use <../lib/conway.scad>


/*
  given a slid and a sequecne of faces
   for each face 
    get adjacent faces in the cycle
    get its commn edges
    get its commn vertex  C
    get the edge midpoints  V0,V1
    interpolate an arc centered on C between V0 and V1  constructing a tube by hulling spheres
    inset the arc nrmal to the face to make a captive channel
    subtract these tubes from the solid
    
   assumes edges are connceted  - need to handle non-adjacent edges  

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
 
 function arc(cycle,k,faces,vertices) =
      let (face=faces[cycle[k]],
           face0=faces[cycle[(k-1+len(cycle))%len(cycle)]],
           face1=faces[cycle[(k+1)%len(cycle)]],
           e0 = common_edge(face,face0),
           e1= common_edge(face,face1),
           c = common(e0,e1)[0],
           p0= e0[0]== c ? e0[1] : e0[0],
           p1= e1[0]== c ? e1[1] : e1[0],
           vc=vertices[c],
           v0=vertices[p0],
           v1=vertices[p1],
           a=angle_between (v1-vc, v0-vc),
           v02= (vc+v0)/2,
           v12= (vc+v1)/2,
           normal=normal(as_points(face,vertices))
           
          )
      [vc,v02,v12,normal]
           ;
           
function arc_point(c,v0,v1,t) =
   let( p= v0* t + v1 * (1 - t),
        r1=norm(v0-c),
        r2=norm(v1-c),
        r= r1*t + r2*(1-t))
        c + unitv(p-c)*r
        ;
module make_arc(arc,r,inset=0.02,delta=0.01) {
    c=arc[0];
    v0=arc[1];
    v1=arc[2];
    n=arc[3];
    translate(n*inset)
      for (t=[0:delta:1-delta]) 
      hull() {
         translate(arc_point(c,v0,v1,t)) sphere(r);  
         translate(arc_point(c,v0,v1,t+delta)) sphere(r);  
     }  
 }
         
module cycle_path(cycle,faces,vertices,r,inset,delta) {
        for (i=[0:len(cycle)-1]) {
            arc= arc(cycle,i,faces,vertices);
            make_arc(arc,r,inset,delta);
        }   
};

solid=C();
             
faces = p_faces(solid);
vertices = p_vertices (solid);
 
cycle= [0,1,4,3,5,2]; 
$fn=20;
r=0.15;
inset=0.01;
delta=0.1;


*echo(arc(cycle,1,faces,vertices) );


*cycle_path(cycle,faces,vertices,r,inset,delta); 

difference ()  {
    show_solid(solid);
    cycle_path(cycle,faces,vertices,r,inset,delta);  
}    
  
