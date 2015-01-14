/* 
A project by Chris Wallace to implement the Conway operations on Polyhedra.  
The project is being documented in my blog 
  http://kitwallace.tumblr.com/tagged/conway

Done :
    primitives T,C,O,D I , pyramid(), prism() , antiprism()
    operators
       kis(obj,ratio, nsides)
       ambo(obj)
      
     
    last updated 14 Jan 2015 
    
*/
// list comprehension support

function flatten(l) = [ for (a = l) for (b = a) b ] ;
    
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


// vector functions

function vadd(points,v,i=0) =
      i < len(points)
        ?  concat([points[i] + v], vadd(points,v,i+1))
        :  [];

function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];

function ssum(list,i=0) =  
      i < len(list)
        ?  (list[i] + ssum(list,i+1))
        :  0;

function reverse(l) = 
     [for (i=[0:len(l)-1]) l[len(l)-i]];
 
     
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

function contains(n, list, i=0) =
     i < len(list) 
        ?  n == list[i]
           ?  true
           :  contains(n,list,i+1)
        : false;

function index_of(n, list, i=0) =
     i < len(list) 
        ?  n == list[i]
           ?  i
           :  index_of(n,list,i+1)
        : -1;

function distinct(d,u=[],i=0) =
// return only distinct items of d 
      i==len(d)
         ? u
         : contains(d[i],u)
             ? distinct(d,u,i+1)
             : distinct(d,concat(u,d[i]),i+1)
      ;

// points functions
function centre(points) = 
      vsum(points) / len(points);

function as_points(indexes,points) =
    [for (i=[0:len(indexes)-1])
          points[indexes[i]]
    ]; 

function vnorm(points) =
  [for (p=points) norm(p)];
      
function average_norm(points) =
       ssum(vnorm(points)) / len(points);

function transform_points(points, matrix) = 
    [for (p=points) transform(p, matrix) ] ;
 
// vertex functions
    
function vertex_faces(p,faces) =
     [ for (f=faces)  
           if(contains(p,f)) f
     ];
                    
function vertex_edges_r(v,vfaces,cface,vedges)  =
     len(vedges) < len(vfaces)
          ? vertex_edges_r(
              v,
              vfaces,
              face_with_edge(vfaces,reverse_edge(last_face_edge(v,cface))),
              concat(vedges,[order_edge(last_face_edge(v,cface))])
              )
          : vedges;
          
function vertex_edges(v,vfaces)  =
    vertex_edges_r(v,vfaces,vfaces[0],[]);
          
// edge functions
          
function reverse_edge(e) = [e[1],e[0]];
function order_edge(e) = 
     e[0]< e[1]
           ? e
           : reverse_edge(e);
          
function ordered_face_edges(f) =
 // edges are ordered anticlockwise
    [for (j=[0:len(f)-1])
        [f[j],f[(j+1)%len(f)]]
    ];
 
function face_edges(f) =
    [for (j=[0:len(f)-1])
       let(p=f[j],q=f[(j+1)%len(f)])
          order_edge([p,q])
    ];
    
function edges(faces) =
   [for (i=[0:len(faces)-1])
       let( f=faces[i])
       for (j=[0:len(f)-1])
       let(p=f[j],q=f[(j+1)%len(f)])
          if(p<q) [p,q]  // no duplicates
   ];
      
function check_euler(obj) =
     //  E = V + F -2    
    len(poly_vertices(obj)) + len(poly_faces(obj)) - 2 ==  len(edges(obj[2]));
         
function edge_lengths(edges,points) =
 [ for (edge = edges) 
     let(points = as_points(edge,points))
        norm(points[0]-points[1])
 ];
   
//face functions
 
function normal_r(face) =
     cross(face[1]-face[0],face[2]-face[0]);

function normal(face) =
     - normal_r(face) / norm(normal_r(face));

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
function face_centre(face,points)  =
   centre(as_points(face,points));
   
function face_centres(obj) =
   [ for (f = poly_faces(obj))
         face_centre(as_points(f,poly_vertices(obj)))
   ];
function face_sides(obj) =
    [for (f=poly_faces(obj)) len(f)];

function face_with_edge(faces,edge) =
     flatten(
        [for (f = faces) 
           if (contains(edge,ordered_face_edges(f))) f
        ]);
           
function last_face_edge(v,face) =   
     flatten(
      [for (e = ordered_face_edges(face))
          if (e[1]==v) e
      ]);    
// normalisation
   
// normalize the points to have origin at 0,0,0 
function centre_points(points) = 
     vadd(points, - centre(points));

//scale to average radius = radius
function normalize(points,radius) =
    points * radius /average_norm(points);

function spherize(points,radius) =
    [for (p=points)
        p * radius /norm(p)];

  
// poly functions
// accessors
function poly_name(obj) = obj[0];
function poly_vertices(obj) = obj[1];
function poly_faces(obj) = obj[2];
function poly_edges(obj) = edges(poly_faces(obj));

function poly_normalize(obj,radius) =
   [str(poly_name(obj)," Normalized"),
    normalize(poly_vertices(obj),radius),
    poly_faces(obj)];
    
function poly_spherize(obj,radius=1) =
   [str(poly_name(obj)," Spherized"),
    spherize(poly_vertices(obj),radius),
    poly_faces(obj)];

function poly_transform(obj,matrix) =
     [str(poly_name(obj)," Transformed"),
      transform_points(poly_vertices(obj),matrix),
      poly_faces(obj)];

module poly_render(obj) {
     polyhedron(poly_vertices(obj),poly_faces(obj));
};

module poly_print(obj) {
    echo("Name",poly_name(obj));
    echo(len(poly_vertices(obj)), "Vertices" ,poly_vertices(obj));
    echo(len(poly_faces(obj)),"Faces", poly_faces(obj));
    echo(len(poly_edges(obj)),"Edges",poly_edges(obj));
};
// primitive solids
C0 = 0.809016994374947424102293417183;
C1 = 1.30901699437494742410229341718;
C2 = 0.7071067811865475244008443621048;
T=
  [ "Tetrahedron",
    [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]],
    [[2,1,0],[3,2,0],[1,3,0],[2,3,1]]
    ];
C =              
    [ "Cube",
[
[ 0.5,  0.5,  0.5],
[ 0.5,  0.5, -0.5],
[ 0.5, -0.5,  0.5],
[ 0.5, -0.5, -0.5],
[-0.5,  0.5,  0.5],
[-0.5,  0.5, -0.5],
[-0.5, -0.5,  0.5],
[-0.5, -0.5, -0.5]],
 [
[ 4 , 5, 1, 0],
[ 2 , 6, 4, 0],
[ 1 , 3, 2, 0],
[ 6 , 2, 3, 7],
[ 5 , 4, 6, 7],
[ 3 , 1, 5, 7]]
];

O =
    [ "Octahedron",
[
[0.0, 0.0,  C2],
[0.0, 0.0, -C2],
[ C2, 0.0, 0.0],
[-C2, 0.0, 0.0],
[0.0,  C2, 0.0],
[0.0, -C2, 0.0]],
 [
[ 4 , 2, 0],
[ 3 , 4, 0],
[ 5 , 3, 0],
[ 2 , 5, 0],
[ 5 , 2, 1],
[ 3 , 5, 1],
[ 4 , 3, 1],
[ 2 , 4, 1]]   
    ];
D = 
["Dodecahedron",
[
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
[
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
];
I =
[ "Icosahedron",

[
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
 [
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

];


function Pyramid(n,h=1) =
    [ str("Y",n) ,
      concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),0]
        ],
        [[0,0,h]]
      ),
      concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,n]
        ],
        [[for (i=[0:n-1]) i]]
      )
     ];

function Prism(n,h=1) =
    [ str("P",n) ,
      concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),-h/2]
        ],
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),h/2]
        ]
      ),
      concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,i+n,(i+1)%n + n]
        ],
        [[for (i=[0:n-1]) i]], 
        [[for (i=[n-1:-1:0]) i+n]]
      )
     ];
        
function Antiprism(n,h=1) =
    [ str("A",n) ,
      concat(
        [for (i=[0:n-1])
            [cos(i*360/n),sin(i*360/n),-h/2]
        ],
        [for (i=[0:n-1])
            [cos((i+1/2)*360/n),sin((i+1/2)*360/n),h/2]
        ]
      ),
      concat(
        [for (i=[0:n-1])
            [(i+1)%n,i,i+n,(i+1)%n + n]
        ],
        [[for (i=[0:n-1]) i]], 
        [[for (i=[n-1:-1:0]) i+n]]
      )
     ];

// Conway operators 
// kis - k 
function kis(obj,ratio=0.1, fn=[]) =
    [str(poly_name(obj), " Kis(",ratio,")"),
     concat(poly_vertices(obj),                   // original vertices
         [for (f = poly_faces(obj))               // new centrid vertices
            let(fp=as_points(f,poly_vertices(obj)))
            (len(fn)==0 || contains(len(f),fn))   // to be included
               ? centre(fp) + normal(fp)*ratio    // centroid + a bit of normal
               : []                               // to preserve the numbering for faces
         ]),
     flatten(
         [for (i = [0:len(poly_faces(obj))-1])   // use indexes so new vertices can be located
            let(f = poly_faces(obj)[i])
            (len(fn)==0 || contains(len(f),fn))
              ? [for (p=[0:len(f)-1])            //replace face with trianges
                [f[p],f[(p+1)%len(f)],len(poly_vertices(obj))+i]
               ]
              : [f]                              // original face
         ]) 
    ];

 function ambo(obj) =
      [str(poly_name(obj), " Ambo"),
       [for (e = poly_edges(obj))
           let (ep = as_points(e,poly_vertices(obj)))
           (ep[0]+ep[1])/2
       ],
       
       concat(
         [for (face = poly_faces(obj))
            [for (e = face_edges(face))
              index_of(e,poly_edges(obj))
            ]
         ]     
       ,        
        [for (vi = [0:len(poly_vertices(obj))-1])
           [for (ve = vertex_edges(vi,vertex_faces(vi,poly_faces(obj))))
              index_of(ve,poly_edges(obj))               
           ]
          ]  
         )
       ];       

             
poly_render(ambo(kis(T,0.5)));
