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
       meta(obj,ratio,nsides)
       ortho(obj,ratio,nsides)
       trunc(obj,ratio) 
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
       modulate(obj)  with global spherical function f()
       
    canonicalization
       planar(obj,itr) -    planarization using reciprocals of centres
       canon(obj,itr) -     canonicalization using edge tangents
       normalize() centre and scale
       
to do
       trunc/gyro for selected vertices
       whirl
       canon still fails on occasion 
       normalize removed from plane,canon - recursion problem ?
   
      last updated 28 Jan 2015 21:00
 
requires concat and list comprehension

*/

// indexing 

function ci(a,i) = a[(i + len(a)) % len(a)];
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
              let(nface=face_with_edge(vfaces,edge))
                 concat([nface],ordered_vertex_faces(v,vfaces,nface,k+1 ))  
           : []
;       
      
function ordered_vertex_edges(v,vfaces,face,k=0)  =
   let(cface=(k==0)? vfaces[0] : face)
   k < len(vfaces)
           ?  let(i = index_of(v,cface))
              let(j= (i-1+len(cface))%len(cface))
              let(edge=[v,cface[j]])
              let(nface=face_with_edge(vfaces,edge))
                 concat([edge],ordered_vertex_edges(v,vfaces,nface,k+1 ))  
           : []
;     
     
function face_with_edge(faces,edge) =
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
function include(face,fn) = 
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
        if (len(point)==3)   // ignore null points
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
          polyhedron(poly_vertices(obj),poly_faces(obj));
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
    assign(edges=poly_edges(obj))
        echo(str(len(edges)," Edges ",edges));
    assign(non_planar=poly_non_planar_faces(obj))
         echo(str(len(non_planar)," faces are not planar", non_planar));
    assign(debug=poly_debug(obj))
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
// cleanup, normalization amd canonicalisation
        
function non_null_map(v,i=0,j=0) =
   i< len(v)
     ?  v[i]!=[]
          ? concat(j,non_null_map(v,i+1,j+1)) 
          : concat(-1,non_null_map(v,i+1,j))
     :  [];
     
function remove_nulls(list) =
   [for (v = list) if (v!=[]) v];
       
function remap(face,map) =
  [for (i=[0:len(face)-1]) map[face[i]]];
      
function poly_remap(obj) =
    let (map = non_null_map(poly_vertices(obj)))
    poly(name=poly_name(obj),
         vertices=remove_nulls(poly_vertices(obj)),
         faces=
           [for (face=poly_faces(obj))
             remap(face,map)
         ]
    );
        
function centre_points(points) = 
     vadd(points, - centre(points));

//scale to average radius = radius
function normalize(points,radius=1) =
    let(ps=centre_points(points))
    let(an=average_norm(ps))
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
          
function plane(obj,n=1) = 
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
                  let (fp=as_points(f,np))
                  let (c=centre(fp))
                  let (n=average_normal(fp))
                  let (cdotn = c*n)
                  let (ed=average_edge_distance(fp))
                  abs(cdotn) <0.0000001
                   ?   reciprocal(c)        // fallback to centre
                   :   reciprocal(n*cdotn) * (1+ed)/2
                ]
           ,
           faces= poly_vertices_to_faces(obj)        
           );

function ndual_data(obj) =
      let(np=poly_vertices(obj))
      
                [ for (f=poly_faces(obj))
                  let (fp=as_points(f,np))
                  let (c=centre(fp))
                  let (n=average_normal(fp))
                  let (ed=average_edge_distance(fp))
                     ["X",f,c,n,ed,c*n,n*(c*n),reciprocal(n*(c*n)) * (1+ed)/2]
                ]
           ;
                
function canon(obj,n=1) = 
    n > 0 
       ? canon(ndual(ndual(obj)),n-1)   
       : poly(name=str("K",poly_name(obj)),
              vertices=poly_vertices(obj),
              faces=poly_faces(obj)
             );   

// Conway operators 
                
function dual(obj) =
    poly(name=str("d",poly_name(obj)),
           vertices = 
              [for (f = poly_faces(obj))
               let(fp=as_points(f,poly_vertices(obj)))
                 centre(fp)  
              ],
           faces= poly_vertices_to_faces(obj)        
      )
;  ///end dual

function kis(obj,height=0.1, fn=[]) =
// kis each n-face is divided into n triangles which extend to the face centre
   let(pf=poly_faces(obj))
   let(off=len(poly_vertices(obj)))
   let(newp=
     poly(name=str("k",poly_name(obj)),
      vertices= 
         concat(
         poly_vertices(obj),       // original vertices
         [for (f=pf)               // new centroid vertices       
            let(fp=as_points(f,poly_vertices(obj)))
            include(fp,fn)
               ? centre(fp) + normal(fp) * height    // centroid + a bit of normal
               : []                // to preserve the numbering for faces
         ]),
      faces=
        flatten(
         [for (i = [0:len(pf)-1])   // use indexes so new vertices can be located
            let(f = pf[i])
            include(f,fn)
              ? [for (j=[0:len(f)-1])            //replace face with triangles
                 let(ca=f[j])
                 let(cb=f[(j+1)%len(f)])
                 let(centre=off+i) 
                  [ca,cb,centre]
               ]
              : [f]                              // original face
         ]) 
    ))
    fn!=[] ? poly_remap(newp) : newp
; // end kis

function offset_faces(faces,start=0,inc=0,i=0) = 
// to get position of new vertices
      i < len(faces)
           ?  concat(
               start,
               offset_faces(faces,start+len(faces[i])+inc,inc,i+1)
               )
           :[]; 

function gyro(obj,ratio=0.3333,height=0.2) = 
    let(pf=poly_faces(obj))
    let(pv=poly_vertices(obj))
    let(off=offset_faces(pf,start=len(pv)+len(pf)))         

    poly(name=str("g",poly_name(obj)),
      vertices= 
        concat(
           poly_vertices(obj),          // original vertices
           [for (f =  pf)               // face centres
            let(fp=as_points(f,pv))
               centre(fp) + normal(fp)*height
            ],  
           flatten(                    // face edges
              [for (f = pf)                 
                [for (e = ordered_face_edges(f))
                 let (ep = as_points(e,pv))
                      ep[0]+ ratio*(ep[1]-ep[0]) 
              ]         
           ])
        ),     

      faces=    
        flatten(                        // new faces are pentagons 
         [for (i = [0:len(pf)-1])   
             let(f = pf[i])
             [for (j=[0:len(f)-1])
                let (jp1=(j+1)%len(f))
                let (jm1=(j-1+len(f))%len(f))
                let (edge=[f[j],f[jp1]])
                let (oppface=face_with_edge(pf,reverse(edge)))
                let (k=index_of(oppface,pf))  
                let (l = index_of(f[jp1],oppface))
                let (ca=f[j])
                let (ez=off[i]+jm1)
                let (centre=len(pv)+i)
                let (ea=off[i]+j)
                let (eaopp=off[k]+l)
                   [ca,eaopp,ea,centre,ez]  
            ]
         ]
       )
      )
; // end gyro
              
function meta(obj,height=0.1, fn=[]) =
// each face is replaced with 2n triangles based on midpoint and centre
    let(pe=poly_edges(obj))
    let(pf=poly_faces(obj))
    let(pv=poly_vertices(obj))
    let(off= len(pv) + len(pf))
    let(newp=
     poly(name=str("m",poly_name(obj)),
      vertices= 
         concat(pv,                
         [for (f = pf)               // new centre vertices
          let (fp=as_points(f,pv))
             include(f,fn)
               ? centre(fp) + normal(fp)*height    
               : []                             
         ],
         [for (e=pe)
          let (ep = as_points(e,pv))
           (ep[0]+ep[1])/2
         ]),
      faces=
        flatten(
         [for (i = [0:len(pf)-1])       
            let(f = pf[i])
            include(f,fn)
              ? flatten(
                 [for (j=[0:len(f)-1])            //  replace face with 2n triangle 
                  let (ca=f[j])
                  let (cb=f[(j+1)%len(f)])
                  let (centre=len(pv)+i)
                  let (edgei=index_of(distinct_edge([ca,cb]),pe))
                   let(mid = off + edgei)
                 [[ mid, centre, ca],[cb,centre, mid] ]  
                 ] )
              : [flatten(
                 [for (j=[0:len(f)-1])
                  let (ca=f[j])
                  let (edgei=index_of(distinct_edge([ca,cb]),pe))
                  let (mid = off + edgei)
                     [ca,mid]
               ])]
         ]) 
    ))
    fn !=[] ? poly_remap(newp) : newp
 ; //end meta

function pyra(obj,height=0.1, fn=[]) =   
// very like meta but different triangles
    let(pe=poly_edges(obj))
    let(pf=poly_faces(obj))
    let(pv=poly_vertices(obj))
    let(offset=len(pv) + len(pf))
    let(newp=
     poly(name=str("y",poly_name(obj)),
      vertices= 
         concat(pv,                 // original vertices
         [for (f = pf)               // new centre vertices
            let(fp=as_points(f,pv))
            include(f,fn)
               ? centre(fp) + normal(fp)*height    
               : []                               
         ],
         [for (e=pe)               // new midpoints
          let (ep = as_points(e,pv))
            (ep[0]+ep[1])/2
         ]),
      faces=
        flatten(
         [ for (i = [0:len(pf)-1])   
            let(f = pf[i])
            include(f,fn)
              ? flatten(
                 [for (j=[0:len(f)-1]) 
                  let(ca=f[j])
                  let(cb=f[(j+1)%len(f)]) 
                  let(centre=len(pv)+i)
                  let(cz=f[(j-1+len(f))%len(f)])         
                  let(midab = offset + index_of(distinct_edge([ca,cb]),pe))
                  let(midza = offset + index_of(distinct_edge([cz,ca]),pe))             
                     [[midza,ca,midab],  [midza,midab,centre ] ]         
                 ] )
              : [flatten(
                 [for (j=[0:len(f)-1])
                  let(ca=f[j])
                  let(cb=f[(j+1)%len(f)]) 
                  let(midab = offset + index_of(distinct_edge([ca,cb]),pe))
                   [ca,midab]
                 ])]
         ]) 
    ))
    fn != [] ? poly_remap(newp) : newp
;   // end pyra 
                                 
function ortho(obj,height=0.2, fn=[]) =  
// very like meta but divided into quadrilaterals
    let (pe=poly_edges(obj))
    let (pf=poly_faces(obj))
    let (pv=poly_vertices(obj))
    let(off=len(pv) + len(pf))
    let(newp=
     poly(name=str("o",poly_name(obj)),
      vertices= 
         concat(pv,                   
         [for (f = pf)     // new centre vertices
          include(f,fn)
            ?  let(fp=as_points(f,pv))
                   centre(fp) + normal(fp)*height   
            : []                              
         ],
         [for (e=pe)       // midpoints
          let (ep = as_points(e,pv))
             (ep[0]+ep[1])/2
         ]),
      faces=
        flatten(
         [ for (i = [0:len(poly_faces(obj))-1])   // use indexes so new vertices can be located
            let(f = pf[i])
            include(f,fn)
             ?  [for (j=[0:len(f)-1])            //  replace face with n quadrilaterals 
                 let(ca=f[j])
                 let(cb=f[(j+1)%len(f)] )
                 let(cz=f[(j-1+len(f))%len(f)])
                 let(midab= off + index_of(distinct_edge([ca,cb]),pe))
                 let(midza= off + index_of(distinct_edge([cz,ca]),pe))
                 let(centre = len(pv)+i)                  
                   [centre,midza,ca,midab]                    
                 ]
              : [flatten(
                 [for (j=[0:len(f)-1])
                  let(ca=f[j])
                  let(cb=f[(j+1)%len(f)] )
                  let(midab= off + index_of(distinct_edge([ca,cb]),pe))          
                     [ca,midab]
                 ] )
                 ]
          ] ) 
    ))
    fn !=[] ?poly_remap(newp) : newp
 ; // end ortho

function trunc(obj,ratio=0.25) = 
// truncate  vertices 
// should be able to restrict to vertices with given order
    let (pe= poly_edges(obj))
    let (pf=poly_faces(obj))
    let (pv=poly_vertices(obj))
      poly(name=str("t",poly_name(obj)),
      vertices=         
         flatten(
            [for (e=pe)
             let (ep = as_points(e,pv))
               [
                 ep[0]+ratio*(ep[1]-ep[0]),
                 ep[1]+ratio*(ep[0]-ep[1])         
               ]
           ])
         ,
      faces= 
         concat(    
           [for (face = pf)
            let  (edges = ordered_face_edges(face))
            flatten([for (i =[0:len(edges)-1] )         
                let (ei = edges[i])
                let (k= index_of(distinct_edge(ei),pe))
                let (oei=pe[k])           
                   [  ei==oei ? 2 *k: 2*k+1 ,
                      ei==oei ? 2 *k+1: 2*k 
                   ]          
            ])
         ] 
         ,       
         [for (vi = [0:len(pv)-1])        // each old vertex creates a new face, with 
         let (vf=vertex_faces(vi,pf))      // the old edges in left-hand order as vertices
         [for (ve = ordered_vertex_edges(vi,vf))                 
              let (k=index_of(distinct_edge(ve),pe))
              let (ue = pe[k])
                 ve != ue 
                    ? 2 * k +1
                    : 2 * k                            
           ]
          ]  
         )
    )
; //end trunc

function propellor(obj,ratio=0.333) =
    let (pf=poly_faces(obj))
    let (pv=poly_vertices(obj))
    let (off=offset_faces(poly_faces(obj),start=len(pv) ))         
    poly(name=str("p",poly_name(obj)),
      vertices=
        concat( 
          pv,                 
          flatten( 
          [for (face=pf)
            [for (edge = ordered_face_edges(face))             
             let (ep = as_points(edge,pv))
                 ep[0]+ratio*(ep[1]-ep[0])         
           ]
          ])
        )
      ,
      faces= 
         concat(    
            [for (i = [0:len(pf)-1])   // rotated faces
             let (face=pf[i])
               [ for (j=[0:len(face)-1])
                  off[i] + j  
               ]  
            ]
               ,
            flatten(
             [for (i = [0:len(pf)-1])   
              let(face=pf[i])
               [
                for (j=[0:len(face)-1])
                 let (jp1=(j+1)%len(face))
                 let(ca=face[j])
                 let(cb=face[jp1])
              
                 let (edge= [ca,cb])
                 let (oppedge=reverse(edge))
                 let (oppface=face_with_edge(pf,reverse(edge)))
                 let (k=index_of(oppface,pf))                
                 let (l = index_of(oppedge,ordered_face_edges(oppface)))    
                 let (v1 = off[i] + j)
                 let (v2 =  off[i] + jp1)
                 let (opp = off[k] + l)
                 let (corner=face[jp1])
                      [corner,v2,v1,opp]
               ]
             ])            
           )   
    ); 
     
function chamfer(obj,ratio=0.333) =
    let (pf=poly_faces(obj))
    let (pv=poly_vertices(obj))
    let (off=offset_faces(poly_faces(obj),start=len(pv) ))         
    poly(name=str("c",poly_name(obj)),
      vertices=
        concat( 
          [for (v = pv)  (1.0-ratio)*v],             // original        
          flatten(         //  face inset
          [for (f=pf)
            let(fp=as_points(f,pv))
            let(c=centre(fp))
            [for (p = fp)
               p + ratio*(c - p)
            ]
          ])
        )
      ,
      faces= 
         concat(    
            [for (i = [0:len(pf)-1])   // rotated faces
               let (face=pf[i])
               [ for (j=[0:len(face)-1])
                  off[i] + j  
               ]  
            ]
               ,
            flatten(
             [for (i = [0:len(pf)-1])   
               let(face=pf[i])
               [
                 for (j=[0:len(face)-1])
                 let (jp1=(j+1)%len(face))
                 let (ca=face[j])
                 let (cb=face[jp1])
                 if(ca<cb)  
                 let (edge= [ca,cb])
                 let (oppedge=reverse(edge))
                 let (oppface=face_with_edge(pf,reverse(edge)))
                 let (k=index_of(oppface,pf))                
                 let (l = index_of(oppedge,ordered_face_edges(oppface)))        
                 let (v1 = off[i] + j)
                 let (v2 =  off[i] + jp1)
                 let (opp1 = off[k] + l)
                 let (opp2 = off[k]+(l+1)%len(oppface))
                      [ca,opp2,opp1, cb,v2,v1]
               ]
             ])            
           )   
    ); 
// end chamfer                   
              
              
function ambo(obj) =
  let (pf=poly_faces(obj))
  let (pv=poly_vertices(obj))
  let (pe=poly_edges(obj))
  poly(name=str("a",poly_name(obj)),
       vertices= 
          [for (e = pe)                 
           let (ep = as_points(e,pv))
             (ep[0]+ep[1])/2  
          ],          
       faces= 
         concat(
         [for (face = pf)
            [for (e = distinct_face_edges(face))   // old faces become the same with the new vertices
              index_of(e,pe)
            ]
         ]     
         ,        
        [for (vi = [0:len(pv)-1])        // each old vertex creates a new face, with 
           let (vf= vertex_faces(vi,pf)) // the old edges in left-hand order as vertices
           [for (ve = ordered_vertex_edges(vi,vf))
              index_of(distinct_edge(ve),pe)               
           ]
          ]  
         )
       )
;// end ambo

function expand_faces(faces,start=0,i=0) = 
      i < len(faces)
           ? concat(
               [[for (i=[0:len(faces[i])-1])  i + start]],
                  expand_faces(faces,start+len(faces[i]),i+1)
               )
           :[]; 

function new_vertex(nf,vi,of,pf)=
       nf[index_of(of,pf)][index_of(vi,of)]  ;    
       
function snub(obj,height=0.5) = 
   let(pf=poly_faces(obj))   
   let(pv=poly_vertices(obj))         
   let(ef=expand_faces(pf))
   poly(name=str("s",poly_name(obj)),
       vertices= 
          flatten([for (f = pf)   
            let (r = -90 / len(f))
            let (fp = as_points(f,pv))
            let (c = centre(fp))
            let (n = normal(fp))
            let (m =  m_from(c,n) 
                      * m_rotate([0,0,r]) 
                      * m_translate([0,0,height]) 
                      * m_to(c,n))
               [for (p = fp) transform(p,m)]
            ]),     
       faces = 
          concat(ef ,
             ,   // vertex faces 
                 [for (vi=[0:len(pv)-1])   
                  let (vf=vertex_faces(vi,pf))   // vertex faces in left-hand order 
                  [for (of = ordered_vertex_faces(vi,vf))
                     new_vertex(ef,vi,of,pf)
                  ]
                 ]
             ,   //  two edge triangles 
             flatten( [for (face=pf)
                flatten(  [for (edge=ordered_face_edges(face))
                   let (oppface=face_with_edge(pf,reverse(edge)))
                   let (e00=new_vertex(ef,edge[0],face,pf))
                   let (e01=new_vertex(ef,edge[1],face,pf) )                
                   let (e10=new_vertex(ef,edge[0],oppface,pf))                 
                   let (e11=new_vertex(ef,edge[1],oppface,pf) )
                   if (edge[0]<edge[1])
                      [
                         [e00,e10,e11],
                         [e01,e00,e11]
                      ] 
                   ])
                ])     
          )
       )
; // end snub
                 
function expand(obj,height=0.5) =                    
   let(pf=poly_faces(obj))            
   let(pv=poly_vertices(obj))         
   let(ef=expand_faces(pf))
   poly(name=str("e",poly_name(obj)),
       vertices= 
          flatten(
            [for (f = pf)     //move the whole face outwards
            let (fp = as_points(f,pv))
            let (c = centre(fp))
            let (n = normal(fp))
            let (m =  m_from(c,n)
                    *  m_translate([0,0,height]) 
                    * m_to(c,n))
               [for (p = fp) transform(p,m)]
            ]),     
       faces = 
             concat(
               ef  // new expanded faces
               ,   // vertex faces 
                 [for (vi=[0:len(pv)-1])   
                  let (vf=vertex_faces(vi,pf))   
                  [for(of=ordered_vertex_faces(vi,vf))
                     new_vertex(ef,vi,of,pf)
                  ]
                 ]
               ,    //edge faces                 
               flatten([for (face=pf)
                  [for (edge=ordered_face_edges(face))
                   let (oppface=face_with_edge(pf,reverse(edge)))
                   let (e00=new_vertex(ef,edge[0],face,pf))
                   let (e01=new_vertex(ef,edge[1],face,pf))                 
                   let (e10=new_vertex(ef,edge[0],oppface,pf))                
                   let (e11=new_vertex(ef,edge[1],oppface,pf)) 
                   if (edge[0]<edge[1])
                      [e00,e10,e11,e01] 
                   ]
                ] )           
              )
       )
; // end expand
                   
function reflect(obj) =
    poly(name=str("r",poly_name(obj)),
         vertices =
          [for (v = poly_vertices(obj))
              [v.x,-v.y,v.z]
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

function insetkis(obj,ratio=0.5,height=-0.5, fn=[]) = 
 // as kis but pyramids inset in the face 
 // useful for shell 
    let (pe=poly_edges(obj))
    let (pf=poly_faces(obj))
    let (pv=poly_vertices(obj))
    let (offset=offset_faces(pf,start=len(pv),inc=1))
    let(newp=
     poly(name=str("x",poly_name(obj)),
      vertices= 
         concat(
         pv,               // original vertices
        flatten(  
          [for (f = pf)               // new centre vertices
            let(fp=as_points(f,pv))
            include(f,fn)
               ? let(c=centre(fp))
                 let(ec = c+ normal(fp)*height)     // centroid + a bit of normal  
                 concat([ec],      
                   [ for (p=fp) p+ratio*(c-p)]
                )
               : []                               
         ])),
      faces=
        flatten(
         [ for (i = [0:len(pf)-1])   
            let(f = pf[i])
            include(f,fn)
              ? flatten(
                 [for (j=[0:len(f)-1])   //  replace face with n quads and n triangles 
                  let (ca=f[j])
                  let (centre=offset[i])
                  let (mida=offset[i]+1+j)
                  let (cb=f[(j+1)%len(f)])
                  let (midb=offset[i]+1+(j+1)%len(f))   
                   [ [ca,cb,midb,mida]  ,   [centre,mida,midb] ]         
                 ] )
              : f
         ] )
    ))
    fn != [] ? poly_remap(newp) : newp
;   // end insetkis
               
function ptransform(obj,matrix) =
   poly(
       name=str("T",poly_name(obj)),
       vertices=transform_points(poly_vertices(obj),matrix),
       faces=poly_faces(obj));
              
//modulation

function modulate_points(points) =
   [for(p=points)
       let(s=xyz_to_spherical(p))
       let(fs=f(s[0],s[1],s[2]))
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
     [1.0+ 0.5*pow(1.1*(cos(1*theta)),3), theta,phi];

function fberry(r,theta,phi) =
     [1.0 - 0.5*pow(0.8*(cos(theta+60)),2),theta,phi];       

function fcushion(r,theta,phi) =
     [r*(1.0 - 0.5*pow(0.9*cos(theta),2)), theta, phi];
          
function fbauble(r,theta,phi) = 
     [r*(1- 0.5*sin(theta*2) + 0.1* sin(theta)*sqrt(abs(cos(theta*2)))) / (sin(theta)), theta,phi] ;

function fellipsoid(r,theta,phi) = [r*(1.0+pow(0.3*cos(theta),2)),theta,phi] ;
          
function f(r,theta,phi) = fellipsoid(r,theta,phi);
 
function modulate(obj) =
    poly(name=str("S",poly_name(obj)),
         vertices=modulate_points(poly_vertices(obj)),         
         faces= 
          [ for (face =poly_faces(obj))
              reverse(face)
          ]
    )
;  // end modulate

 
// object operations
    
module ruler(n) {
   for (i=[0:n-1]) 
       translate([(i-n/2 +0.5)* 10,0,0]) cube([9.8,5,2], center=true);
}

module ground(x=0) {
   translate([0,0,-(100+x)]) cube(200,center=true);
}

module shell(s,r=1,shell_ratio=0.15,ratio=0.3,height=-1) {
  sa=poly_normalize(s);
  se=insetkis(sa,ratio,height);
  echo(poly_description(s));
  difference () {
     scale(r)poly_render(se,false,false,true,0.01,0.01);
     scale(r*(1-shell_ratio))poly_render(sa,false,false,true,0.01,0.01);
  }      
}
// generate points on the circumference of the tube  
function circle_points(r, sides,phase=0) = 
    [for (i=[0:sides-1]) [r * sin(i*360/sides+phase), r * cos(i*360/sides+phase), 0]];

// generate the points along the centre of the tube
function loop_points(step) = 
    [for (t=[0:step:360-step]) f(t) ];

// generate all points on the tube surface  
function tube_points(loop, circle_points) = 
    [for (i=[0:len(loop)-1])
       let (n1=loop[(i + 1) % len(loop)] - loop[i])
       let (n0=loop[i]-loop[(i - 1 +len(loop)) % len(loop)])
       let (m = m_to(loop[i], (n0+n1)))
       for (p = circle_points) 
          transform(p,m)
    ];
// generate the faces of the tube surface 
function loop_faces(segs, sides) = 
     [for (i=[0:segs-1]) 
       for (j=[0:sides -1])  
        [ i * sides + j, 
          i * sides + (j + 1) % sides, 
        ((i + 1) % segs) * sides + (j + 1) % sides, 
        ((i + 1) % segs) * sides + j
        ]   
     ] ;

//  create a knot from global function f as a  polyhedron
function fun_knot(name,step,r,sides,phase=0) =
    let(circle_points = circle_points(r,sides,phase))
    let(loop_points = loop_points(step))
    let(tube_points = tube_points(loop_points,circle_points))
    let(loop_faces = loop_faces(len(loop_points),sides))
    poly(name=name, vertices = tube_points, faces = loop_faces)
; 

a = 0.8;
b = sqrt (1 - a * a);
ecc=2;
// t= 0:360 
function frolling(t) =   
   [ a * cos (3 * t) / (1 - b* sin (2 *t)),
     a * sin( 3 * t) / (1 - b* sin (2 *t)),
     1.8 * b * cos (2 * t) /(1 - b* sin (2 *t))
    ];
    
function funknot(t) =   
   [ cos (t),
     sin(t) ,
     0
    ];

function f(t) = frolling(t);

r=0.3;
sides=5;
step=10;  


scale(25) shell(plane(chamfer(plane(chamfer(plane(meta(D),5)),5)),5));

//ruler(10);
