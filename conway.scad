/* 
A project by Chris Wallace to implement the Conway operations on Polyhedra.  
The project is being documented in my blog 
   http://kitwallace.tumblr.com/tagged/conway


Done :
    poly object constructor 
    poly accessors and renderers  (as 3d,description, print
    )
    primitives T,C,O,D,I,Y(n),P(n),A(n)
  
    operators 
       transform(obj,matrix)    matrix transformation of vertices
       kis(obj,ratio, nsides)
       ambo(obj)
       meta(obj,ratio)
       ortho(obj,ratio)
       trunc(obj,ratio, nsides) 
       dual(obj)    
       snub(obj,height)
       expand(obj,height)
       reflect(obj)
       
       gyro(obj)   
       propellor(obj,ratio)
       join(obj)  == dual(ambo(obj)
       bevel(obj) == trunc(ambo(obj))
       chamfer(obj,ratio)
       insetkis(obj,ratio,height,fn)
       modulate(obj)  with global spherical function fmod()
       shell(obj,inset,height)
       
    canonicalization
       planar(obj,itr) -    planarization using reciprocals of centres
       canon(obj,itr) -     canonicalization using edge tangents
       normalize() centre and scale
    
    other 
       fun_knot to construct polyhedra from a function fknot()
       
to do
       whirl
       canon still fails on occasion 
       normalize removed from plane,canon - recursion problem ?
   
      last updated 10 Feb 2015 16:30
 
requires version of OpenSCAD  with concat, list comprehension and let()

*/


// basic list comprehension functions

function flatten(l) = [ for (a = l) for (b = a) b ] ;
    
function reverse(l) = 
     [for (i=[1:len(l)]) l[len(l)-i]];
   
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
function transform_points(ps,m) =
   [for (p=ps) transform(p,m)];
       
function m_to(centre,normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
    * m_translate(centre);   
   
function m_from(centre,normal) = 
      m_translate(-centre)
    * m_rotate([0, 0, -atan2(normal[1], normal[0])]) 
    * m_rotate([0, -atan2(sqrt(pow(normal[0], 2) + pow(normal[1], 2)), normal[2]), 0]); 

// modules to orient objects
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal[1], normal[0])]) //rotation
      rotate([0, atan2(sqrt(pow(normal[0], 2)+pow(normal[1], 2)),normal[2]), 0])
      children();
}

// vector functions

function vadd(points,v,i=0) =
      i < len(points)
        ?  concat([points[i] + v], vadd(points,v,i+1))
        :  [];

function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];

function hadamard(a,b) =
       len(a)==len(b)
           ?  [for (i=[0:len(a)-1]) a[i]*b[i]] 
           :  [];
           
function norm2(v) = v.x*v.x+ v.y*v.y + v.z*v.z;

function reciprocal(v) = v/norm2(v);
           
function ssum(list,i=0) =  
      i < len(list)
        ?  (list[i] + ssum(list,i+1))
        :  0;
   
function max(v, max=-9999999999999999,i=0) =
    i < len(v) 
        ?  v[i] > max 
            ?  max(v, v[i], i+1 )
            :  max(v, max, i+1 ) 
        : max;

function min(v, min=9999999999999999,i=0) =
    i < len(v) 
        ?  v[i] < min 
            ?  min(v, v[i], i+1 )
            :  min(v, min, i+1 ) 
        : min;

function vcontains(val,list) =
     search([val],list)[0] != [];
   
function index_of(val, list) =
      search([val],list)[0]  ;
       
function count(val, list) =  // number of occurances of val in list
   ssum([for(v= list) v== val ? 1 :0]);
    
function distinct(list,dlist=[],i=0) =  // return only distinct items of d 
      i==len(list)
         ? dlist
         : search(list[i],dlist) != []
             ? distinct(list,dlist,i+1)
             : distinct(list,concat(dlist,list[i]),i+1)
      ;

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
    [for (p=points) transform(p, matrix) ] ;
   
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
     
function face_with_edge(edge,faces) =
     flatten(
        [for (f = faces) 
           if (vcontains(edge,ordered_face_edges(f))) f
        ]);
                   
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
 
function distinct_face_edges(f) =
    [for (j=[0:len(f)-1])
       let(p=f[j],q=f[(j+1)%len(f)])
          distinct_edge([p,q])
    ];
    
function distinct_edges(faces) =
   [for (i=[0:len(faces)-1])
       let( f=faces[i])
       for (j=[0:len(f)-1])
          let(p=f[j],q=f[(j+1)%len(f)])
             if(p<q) [p,q]  // no duplicates
   ];
      
function check_euler(obj) =
     //  E = V + F -2    
    len(poly_vertices(obj)) + len(poly_faces(obj)) - 2
           ==  len(distinct_edges(obj[2]));
         
function edge_lengths(edges,points) =
 [ for (edge = edges) 
   let (points = as_points(edge,points))
        norm(points[0]-points[1])
 ];
 
function tangent(v1,v2) =
   let (d=v2-v1)
   v1 - v2 * (d*v1)/norm2(d);
 
function edge_distance(v1,v2) = sqrt(norm2(tangent(v1,v2)));
 
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
   [for (f=poly_faces(obj))
       let(face_points = as_points(f,poly_vertices(obj)))
       let(centre=centre(face_points))
          face_area(vadd(face_points,-centre))
   ];

function average_normal(fp) =
     let(fl=len(fp))
     let(unitns=
           [for(i=[0:fl-1])
            let(n=orthogonal(fp[i],fp[(i+1)%fl],fp[(i+2)%fl]))
            let(normn=norm(n))
              normn==0? [] : n/normn
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
    
function face_irregularity(face,points) =
    let (edges=ordered_face_edges(face))
    let (lengths=edge_lengths(edges,points))
    max(lengths)/ min(lengths);

function face_analysis(faces) =
  let (edge_counts=face_sides(faces))
  [for (sides=distinct(edge_counts))
        [sides,count(sides,edge_counts)]
   ];

function fev(faces) =
    let(face_counts=face_analysis(faces))
    let(fn=ssum([for (f = face_counts) f[1]]))
    let(en=ssum([for (f=face_counts) f[0]*f[1]])/2)
    let( vn= en - fn +2)
    [fn,en,vn,face_counts]
;
    
// poly functions
//  constructor
function poly(name,vertices,faces,debug=[]) = 
    [name,vertices,faces,debug];
    
// accessors
function poly_name(obj) = obj[0];
function poly_vertices(obj) = obj[1];
function poly_faces(obj) = obj[2];
function poly_debug(obj)=obj[3];
function poly_edges(obj) = distinct_edges(poly_faces(obj));
function poly_description(obj) =
      str(poly_name(obj),
         ", ",str(len(poly_vertices(obj)), " Vertices" ),
         ", ",str(len(poly_faces(obj))," Faces "),
         face_analysis(poly_faces(obj)),
         " ",str(len(poly_non_planar_faces(obj))," not planar"),
          ", ",str(len(poly_edges(obj))," Edges ")
     ); 
function poly_faces_as_points(obj) =
    [for (f = poly_faces(obj))
        as_points(f,poly_vertices(obj))
    ];
    
function poly_non_planar_faces(obj,tolerance=0.001) =
     [for (face = poly_faces(obj))
         if (len(face) >3)
             let (points = as_points(face,poly_vertices(obj)))
             let (error=face_coplanarity(points))
             if (error>tolerance) 
                 [tolerance,face]
     ];
             
function poly_irregular_faces(obj,tolerance=0.01) =
     [for (face = poly_faces(obj))
         let(ir=face_irregularity(face,poly_vertices(obj)))
         if(abs(ir-1)>tolerance)
               [ir,face]
      ];
             
function poly_vertices_to_faces(obj)=
    [for (vi = [0:len(poly_vertices(obj))-1])    // each old vertex creates a new face, with 
       let (vf=vertex_faces(vi,poly_faces(obj)))   // vertex faces in left-hand order    
       [for (of = ordered_vertex_faces(vi,vf))
              index_of(of,poly_faces(obj))    
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
        
module poly_render(obj,show_vertices=true,show_edges=true,show_faces=true, rv=0.04, re=0.02) {
     if(show_faces) 
          polyhedron(poly_vertices(obj),poly_faces(obj),convexity=10);
     if(show_vertices) 
         show_points(poly_vertices(obj),rv);
     if(show_edges)
       show_edges(poly_edges(obj),poly_vertices(obj),re);
};

module poly_print(obj) {
    echo(poly_name(obj));
    echo(str(len(poly_vertices(obj)), " Vertices " ,poly_vertices(obj)));
    echo(str(len(poly_faces(obj))," Faces ", poly_faces(obj)));
    echo("face analysis",face_analysis(poly_faces(obj)));
    edges=poly_edges(obj);
    echo(str(len(edges)," Edges ",edges));
    non_planar=poly_non_planar_faces(obj);
    echo(str(len(non_planar)," faces are not planar", non_planar));
    debug=poly_debug(obj);
    if(debug!=[]) echo("Debug",debug);
};

function poly_scale(obj,scale) =
   poly(name=str("scale",poly_name(obj)),
        vertices =
           [for (v = poly_vertices(obj))
                hadamard(v,scale)
           ],
       faces = poly_faces(obj)
    );
    
                    
// primitive solids
C0 = 0.809016994374947424102293417183;
C1 = 1.30901699437494742410229341718;
C2 = 0.7071067811865475244008443621048;
T= poly(name= "T",
       vertices= [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]],
       faces= [[2,1,0],[3,2,0],[1,3,0],[2,3,1]]
    );
C = poly(name= "C",
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
   );

O = poly(name="O",
         vertices=[
[0.0, 0.0,  C2],
[0.0, 0.0, -C2],
[ C2, 0.0, 0.0],
[-C2, 0.0, 0.0],
[0.0,  C2, 0.0],
[0.0, -C2, 0.0]],
        faces= [
[ 4 , 2, 0],
[ 3 , 4, 0],
[ 5 , 3, 0],
[ 2 , 5, 0],
[ 5 , 2, 1],
[ 3 , 5, 1],
[ 4 , 3, 1],
[ 2 , 4, 1]]   
    );
D = poly(name="D",
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
   );
   
I = poly(name= "I",
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
);

function Y(n,h=1) =
   poly(name= str("Y",n) ,
      vertices=
      normalize(concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),0]
        ],
        [[0,0,h]]
      )),
      faces=concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,n]
        ],
        [[for (i=[0:n-1]) i]]
      )
     );

function P(n,h=1) =
   poly(name=str("P",n) ,
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
     );
        
function A(n,h=1) =
   poly(name=str("A",n) ,
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
     );
// normalization amd canonicalisation
        
function centre_points(points) = 
     vadd(points, - centre(points));

function sphericalize(points,radius=1) =
   [for (p = points)
       p* radius/ norm(p)
   ];

function poly_sphericalize(obj,radius=1) =
    poly(name=str("n",poly_name(obj)),
         vertices=sphericalize(poly_vertices(obj),radius),
         faces=poly_faces(obj)
   );
   
//scale to average radius = radius
function normalize(points,radius=1) =
    let(ps=centre_points(points),
        an=average_norm(ps))
    ps * radius /an;

function poly_normalize(obj,radius=1) =
    poly(name=str("n",poly_name(obj)),
         vertices=normalize(poly_vertices(obj),radius),
         faces=poly_faces(obj)
   );
      
function rdual(obj) =
    let(np=poly_vertices(obj))
    poly(name=poly_name(obj),
           vertices =
                [ for (f=poly_faces(obj))
                  let (c=centre(as_points(f,np)))
                     reciprocal(c)
                ]
           ,
           faces= poly_vertices_to_faces(obj)  
           );
          
function plane(obj,n=5) = 
    n > 0 
       ? plane(rdual(rdual(obj)),n-1)   
       : poly(name=str("P",poly_name(obj)),
              vertices=poly_vertices(obj),
              faces=poly_faces(obj)
             );

function ndual(obj) =
      let(np=poly_vertices(obj))
      poly(name=poly_name(obj),
           vertices =
                [ for (f=poly_faces(obj))
                  let (fp=as_points(f,np),
                       c=centre(fp),
                       n=average_normal(fp),
                       dotn = c*n,
                       ed=average_edge_distance(fp))
                  abs(cdotn) <0.0000001
                   ?   reciprocal(c)        // fallback to centre
                   :   reciprocal(n*cdotn) * (1+ed)/2
                ]
           ,
           faces= poly_vertices_to_faces(obj)        
           );
                
function canon(obj,n=1) = 
    n > 0 
       ? canon(ndual(ndual(obj)),n-1)   
       : poly(name=str("K",poly_name(obj)),
              vertices=poly_vertices(obj),
              faces=poly_faces(obj)
             );   

function dual(obj) =
    poly(name=str("d",poly_name(obj)),
         vertices = 
              [for (f = poly_faces(obj))
               let(fp=as_points(f,poly_vertices(obj)))
                 centre(fp)  
              ],
         faces= poly_vertices_to_faces(obj)        
        )
;  // end dual
              
// Conway operators 
/*  where necessary, new vertices are first created and stored in an associative array, keyed by whatever is appropriate to identify the new vertex - this could be an old vertex id, a face, an edgeor something more complicated.  This array is then used to create an associative array of key and vertex ids for use in face construction, and to generate the new vertices themselves
*/

function vertex_ids(entries,offset=0,i=0) = 
// to get position of new vertices 
    [for (i=[0:len(entries)-1]) 
          [entries[i][0],i+offset]
    ];
          
function vertex_values(entries)= 
    [for (e = entries) e[1]];
 
function vertex(key,entries) =   // key is an array 
    entries[search([key],entries)[0]][1];
    
// operators
    
function kis(obj,height=0.1, fn=[]) =
// kis each n-face is divided into n triangles which extend to the face centre
// existimg vertices retained
              
   let(pf=poly_faces(obj),
       pv=poly_vertices(obj))
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
  
   poly(name=str("k",poly_name(obj)),
       vertices= concat(pv, vertex_values(newv)) , 
       faces=newf
   )
; // end kis


function gyro(obj, ratio=0.3333, height=0.2) = 
// retain original vertices, add face centres and directed edge points 
//  each N-face becomes N pentagons
    let(pf=poly_faces(obj),
        pv=poly_vertices(obj),
        pe=poly_edges(obj))
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
               
    poly(name=str("g",poly_name(obj)),
      vertices=  concat(pv, vertex_values(newv)),
      faces= newf
      )
; // end gyro

            
function meta(obj,height=0.1) =
// each face is replaced with 2n triangles based on edge midpoint and centre
    let(pe=poly_edges(obj),
        pf=poly_faces(obj),
        pv=poly_vertices(obj))
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
                 [ [ mid, centre, a], [b,centre, mid] ]  
                 ] )
         ])
      )   
               
     poly(name=str("m",poly_name(obj)),
          vertices= concat(pv,vertex_values(newv)),                
          faces=newf
      ) 
 ; //end meta

function pyra(obj,height=0.1) =   
// very like meta but different triangles
    let(pe=poly_edges(obj),
        pf=poly_faces(obj),
        pv=poly_vertices(obj))
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
           flatten( [for (j=[0:len(f)-1]) 
             let(a=face[j],
                 b=face[(j+1)%len(face)], 
                 z=face[(j-1+len(face))%len(face)],        
                 midab = vertex(distinct_edge([a,b]),newids),
                 midza = vertex(distinct_edge([z,a]),newids))             
             [[midza,a,midab], [midza,midab,centre]]         
             ])
          ] ))
              
     poly(name=str("y",poly_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )
;   // end pyra 
                                 
function ortho(obj,height=0.2) =  
// very like meta but divided into quadrilaterals
    let (pe=poly_edges(obj),
         pf=poly_faces(obj),
         pv=poly_vertices(obj))

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
      
     poly(name=str("o",poly_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )
; // end ortho
       
function trunc(obj,ratio=0.25,fn=[]) =
    let (pv=poly_vertices(obj),
         pf=poly_faces(obj))
               
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

     poly(name=str("t",poly_name(obj)),
          vertices= vertex_values(newv),
          faces=newf,
          debug=newids
         )
; // end trunc

function propellor(obj,ratio=0.333) =
    let (pf=poly_faces(obj),
         pv=poly_vertices(obj),
         pe=poly_edges(obj))
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
     poly(name=str("p",poly_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )         
; // end propellor
     
function chamfer(obj,ratio=0.333) =
    let (pf=poly_faces(obj),
         pv=poly_vertices(obj))  
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
    poly(name=str("c",poly_name(obj)),
      vertices=
        concat( 
          [for (v = pv)  (1.0-ratio)*v],             // original        
           vertex_values(newv)
         ),
      faces=newf
    ); 
// end chamfer                   
              
              
function ambo(obj) =
  let (pf=poly_faces(obj),
       pv=poly_vertices(obj),
       pe=poly_edges(obj))
  
          
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
           
           
  poly(name=str("a",poly_name(obj)),
       vertices = vertex_values(newv),  
       faces =  newf
       )
;// end ambo    
       
function snub(obj,height=0.5) = 
   let(pf=poly_faces(obj),   
       pv=poly_vertices(obj)  )       
       
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
               [for (i=[0:len(f)-1]) 
                  [[face,face[i]], transform(fp[i],m)]
              ]
            ]))
   
   let(newids=vertex_ids(newv))
   let(newf =
         concat(
             [for (face = pf)   
               [for (v = f) 
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
            
   poly(name=str("s",poly_name(obj)),
       vertices= vertex_values(newv),
       faces=newf
       )
; // end snub
   
function expand(obj,height=0.5) =                    
   let(pf=poly_faces(obj),           
       pv=poly_vertices(obj))        
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
                  [[face,face[i]], transform(fp[i],m)]
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
                   
   poly(name=str("e",poly_name(obj)),
       vertices= vertex_values(newv),
       faces=newf
      )
         
; // end expand
                
function reflect(obj) =
    poly(name=str("r",poly_name(obj)),
        vertices =
          [for (p = poly_vertices(obj))
              [p.x,-p.y,p.z]
          ],
        faces=  // reverse the winding order 
          [ for (face =poly_faces(obj))
              reverse(face)
          ]
    )
;  // end reflect
          
function join(obj) =
    let(name=poly_name(obj))
    let(p = dual(ambo(obj)))
    poly(name=str("j",name),
         vertices =poly_vertices(p),         
         faces= poly_faces(p)
    )
;  // end join 
          
function bevel(obj) =
    let(name=poly_name(obj))
    let(p = trunc(ambo(obj)))
    poly(name=str("b",name),
         vertices =poly_vertices(p),         
         faces= poly_faces(p)
    )
;  // end bevel

function random(obj,offset=0.1) =
    poly(name=str("x",poly_name(obj)),
         vertices =
          [for (v = poly_vertices(obj))
             v + rands(0,offset,3)
          ],
        faces= poly_faces(obj)
     )
; 

function qt(obj) =
// triangulate quadrilateral faces
  let (pf=poly_faces(obj),
       pv=poly_vertices(obj),
       pe=poly_edges(obj))
           
  poly(name=str("u",poly_name(obj)),
       vertices=pv,          
       faces= flatten(
           [for (f = pf)
            len(f) == 4
              ? [ [f[1],f[2],f[3]], [f[1],f[3],f[0]]]          
              :  f 
           ])
       )
;// end qt
           
function tt(obj) =
// triangulate triangular faces - works if all faces are triangular
  let (pf=poly_faces(obj),
       pv=poly_vertices(obj),
       pe=poly_edges(obj))
  
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

  poly(name=str("u",poly_name(obj)),
       vertices=
           concat(pv, vertex_values(newv)),  
       faces= newf
       )
;// end tt

function inset_kis(obj,ratio=0.5,height=-0.1, fn=[]) = 
 // as kis but pyramids inset in the face 
    let (pe=poly_edges(obj),
         pf=poly_faces(obj),
         pv=poly_vertices(obj))
     
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
   
    poly(name=str("x",poly_name(obj)),
      vertices=  concat(pv, vertex_values(newv)) ,
      faces= newf
    )
;   // end inset_kis
               
function ptransform(obj,matrix) =
   poly(
       name=str("T",poly_name(obj)),
       vertices=transform_points(poly_vertices(obj),matrix),
       faces=poly_faces(obj));
              
//modulation

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
  
function fsuperegg(r,theta,phi,n,e) =
      [ r* (pow(
               pow(abs(cos(theta)),n) 
           + e*pow(abs(sin(theta)),n)
            ,-1/n))
         ,theta,phi];
 
function modulate(obj) =
    poly(name=str("S",poly_name(obj)),
         vertices=modulate_points(poly_vertices(obj)),         
         faces= 
          [ for (face =poly_faces(obj))
              reverse(face)
          ]
    )
;  // end modulate

function face_def(f,pv) =
     let(def= [for (fv = f) if(pv[fv] != []) 1 ])
     len(def) == len (f);
;

function compact(obj) =
    let (pf=poly_faces(obj))
    let (pv=poly_vertices(obj))
    let(cv=
        [for (i=[0:len(pv)-1])
            len(vertex_faces(i,pf))>0 ? i :[]
        ])
    let (map = non_null_map(cv))
    poly(name=poly_name(obj),
         vertices=remove_nulls(cv),
         faces=
           [for (face=pf)
             remap(face,map)
         ]
     )
;
// generate points on the circumference of the tube  
function circle_points(r, sides,phase=0) = 
    [for (i=[0:sides-1]) [r * sin(i*360/sides+phase), r * cos(i*360/sides+phase), 0]];

// generate the points along the centre of the tube
function loop_points(step) = 
    [for (t=[0:step:360-step]) fknot(t) ];

// generate all points on the tube surface  
function tube_points(loop, circle_points) = 
    [for (i=[0:len(loop)-1])
       let (n1=loop[(i + 1) % len(loop)] - loop[i],
            n0=loop[i]-loop[(i - 1 +len(loop)) % len(loop)],
            m = m_to(loop[i], (n0+n1)))
       for (p = circle_points) 
          transform(p,m)
    ];
// generate the faces of the tube surface 
function loop_faces(segs, sides) =    
      [for (i=[0:segs-1]) 
       for (j=[0:sides -1])  
       let (a=i * sides + j, 
            b=i * sides + (j + 1) % sides, 
            c=((i + 1) % segs) * sides + (j + 1) % sides, 
            d=((i + 1) % segs) * sides + j)
       [a,b,c,d]    
     ];

//  create a knot from global function f as a  polyhedron
function fun_knot(name="not set",step=10,r=0.2,sides=6,phase=0) =
    let(circle_points = circle_points(r,sides,phase),
        loop_points = loop_points(step),
        tube_points = tube_points(loop_points,circle_points),
       loop_faces = loop_faces(len(loop_points),sides))
    poly(name=name, vertices = tube_points, faces = loop_faces)
; 

// t= 0:360 
function ftrefoil(t,a=2,b=0.75) = 
    [  sin(t) + a * sin(2 * t),
       cos(t) - a * cos(2 * t),
       - b * sin (3 * t)
    ];            
            
function frolling(t,a=0.8) =   
   let(b=sqrt (1 - a * a))
   [ a * cos (3 * t) / (1 - b* sin (2 *t)),
     a * sin( 3 * t) / (1 - b* sin (2 *t)),
     1.8 * b * cos (2 * t) /(1 - b* sin (2 *t))
    ];
    
function ftorus(t) =   
   [ cos (t),
     sin(t) ,
     0
    ];

function felipse(t,e=1) =   
   [ cos (t),
     e* sin(t) ,
     0.1*sin(2*t)
    ];
function fcardiod(t)=
  [  2*cos( t) - cos( 2* t),
     2*sin( t) - sin (2* t),
     0
   ];
function sgn(x) =  x >0 ? 1 : -1;
function fsuper(t,a,e) =
    [pow(abs(cos(t)), 2/a)* sgn(cos(t)),	
     e*pow(abs(sin(t)), 2/a)* sgn(sin(t)),
     0];
    
function fknot(t) = ftrefoil(t);
// end knot

  
// object operations
    
module ruler(n) {
   for (i=[0:n-1]) 
       translate([(i-n/2 +0.5)* 10,0,0]) cube([9.8,5,2], center=true);
}

module ground(x=0) {
   translate([0,0,-(100+x)]) cube(200,center=true);
}    

function shell(obj,outer_inset=0.2,inner_inset=[],thickness=0.2,fn=[]) = 
   let(inner_inset= inner_inset == [] ? outer_inset : inner_inset,
       pf=poly_faces(obj),           
       pv=poly_vertices(obj))

   let(inv=   // corresponding points on inner surface
       [for (i =[0:len(pv)-1])
        let(v = pv[i])
        let(norms =
            [for (f=vertex_faces(i,pf))
             let (fp=as_points(f,pv))
                normal(fp)
            ])
        let(av_norm = -vsum(norms)/len(norms))
            v + thickness*av_norm
        ])
                 
   let (newv =   // the inset points on outer and inner surfaces
         flatten(
           [ for (face = pf)
             if(selected_face(face,fn))
                 let(fp=as_points(face,pv),
                     ofp=as_points(face,inv),
                     c=centre(fp),
                     oc=centre(ofp))
                 flatten(
                    [for (i=[0:len(face)-1])
                     let(v=face[i],
                         p = fp[i],
                         op= ofp[i],
                         ip = p + (c-p)*outer_inset,
                         oip = op + (oc-op)*inner_inset)
                     [ [[face,v],ip],[[face,-v],oip]]
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
                ? [for (j=[0:len(face)-1])   //  replace N-face with 3*N quads 
                  let (a=face[j],
                       inseta = vertex([face,a],newids),
                       oinseta= vertex([face,-a],newids),
                       b=face[(j+1)%len(face)],
                       insetb= vertex([face,b],newids),
                       oinsetb=vertex([face,-b],newids),
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
                           
   poly(name=str("x",poly_name(obj)),
       vertices=  concat(pv, inv, vertex_values(newv)) ,    
       faces= newf           
       )
; // end shell  

/*
//  superegg_ccD  - Goldberg (0,4) 
function fmod(r,theta,phi) = fsuperegg(r,theta,phi,2.5,1.2);
         
s= modulate(plane(chamfer(plane(chamfer(D)))));
echo(poly_description(s));                    
t=shell(s,thickness=0.15,outer_inset=0.35,inner_inset=0.2,fn=[6]);              
scale(20)  poly_render(t,false,false,true);
*/

/*
//  superegg_tktI  - Goldberg (3,3)  
function fmod(r,theta,phi) = fsuperegg(r,theta,phi,2.5,1.2);
          
s= modulate(plane(trunc(plane(kis(trunc(I))))));
echo(poly_description(s));                    
t=shell(s,thickness=0.15,outer_inset=0.35,inner_inset=0.2,fn=[6]);              
scale(20)  poly_render(t,false,false,true);
*/                        

/*
// trefoil knot
function fknot(t) = ftrefoil(t);
s=fun_knot(step=10,r=0.4,sides=6);
t=shell(s,thickness=0.2,outer_inset=0.5,inner_inset=0.3,fn=[]);              
scale(20)  poly_render(t,false,false,true);
*/

/*
// torus knot

function fknot(t) = ftorus(t);

s=fun_knot(step=90,r=0.7,sides=4,phase=45);
t=shell(s,thickness=0.5,outer_inset=0.5,inner_inset=0.35,fn=[]);              
scale(20)  poly_render(t,false,false,true);

*/

s=shell(plane(trunc(plane(kis(plane(trunc(D)), fn=[10])), fn=[10])));
// s=trunc(plane(kis(T)),fn=[3]);
poly_print(s);
poly_render(s,false,false,true);

// ruler(10);
