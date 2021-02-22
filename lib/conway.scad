include <basics.scad>
include <poly.scad>

/* 
A script to implement the Conway operations and more on Polyhedra.  

By Kit Wallace kit.wallace@gmail.com

with thanks to George Hart whose javascript version http://www.georgehart.com/virtual-polyhedra/conway_notation.html was the inspiration for this work.

Code licensed under the Creative Commons - Attribution - Share Alike license.

The project is being documented in my blog 
   http://kitwallace.tumblr.com/tagged/conway
      
OpenSCAD version 2015-03-01 or later: requires concat, list comprehension and let()
         
Features

some functions have been moved to poly.scad 

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
       hexpropello(obj) (Dave Mccooey)
       join(obj)  == dual(ambo(obj)
       bevel(obj) == trunc(ambo(obj))
       chamfer(obj,ratio)
       whirl(obj,ratio)
       quinta(obj)
         
   additional operators, mostly decorative
       tt(obj)   convert triangular faces into 4 triangles
       cc(obj)  - Catmull-Clark smoothing
       transform(obj,matrix)    matrix transformation of vertices
       inset_kis(obj,ratio,height,fn)
       modulate(obj)  with global spherical function fmod()
       openface(obj,outer_inset_ratio,inner_inset_ratio,
            ,outer_inset,inner_inset,height,min_edge_length)
       place(obj)  on largest face -use before openface
       crop(obj,minz,maxz) - then render with wire frame
    orientation, centering and resizing
       p_inscribed_resize_points()  - resize to a given average face centroid
       p_midscribed_resize_points() - resize to a given average edge centroid
       p_circumscribed_resize_points() - resize to a given average vertex
       orient(obj)  - ensure all faces have lhs order (only convex )
         needed for some imported solids eg Georges solids and Johnson
             and occasionally for David's 
    
    canonicalization
       plane(obj,itr) - planarization using reciprocals of face centroids
       canon(obj,itr) - canonicalization using edge tangents
    
    rendering
      p_render(obj,...)
      p_hull(obj,r)
      p_render_text(obj,texts...)
      
    version 2016/04/19
    version 2017/04/09  - quinto added
    version 2021/01/15  - refactored to move common polyhedron code to poly.scad
    
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


  
// canonicalization

function rdual(obj) =
    let(np=p_vertices(obj))
    poly(name=p_name(obj),
           vertices =
                [ for (f=p_faces(obj))
                  let (c=centroid(as_points(f,np)))
                     reciprocal(c)
                ]
           ,
           faces= p_vertices_to_faces(obj)  
           );
          
function plane(obj,n=10) = 
    n > 0 
       ? plane(rdual(rdual(obj)),n-1)   
       : p_resize(poly(name=str("K",p_name(obj)),
              vertices=p_vertices(obj),
              faces=p_faces(obj)
             ));

function ndual(obj) =
      let(np=p_vertices(obj))
      poly(name=p_name(obj),
           vertices = 
                [ for (f=p_faces(obj))
                  let (fp=as_points(f,np),
                       c=centroid(fp),
                       n=average_normal(fp),
                       cdotn = c*n,
                       ed=average_edge_distance(fp))
                  reciprocal(n*cdotn) * (1+ed)/2
                ]
           ,  
           faces= p_vertices_to_faces(obj)        
           );
                
function canon(obj,n=10) = 
    n > 0 
       ? canon(ndual(ndual(obj)),n-1)   
       : p_resize(poly(name=str("N",p_name(obj)),
              vertices=p_vertices(obj),
              faces=p_faces(obj)
             ));   
             
function dual(obj) =
    poly(name=str("d",p_name(obj)),
         vertices = 
              [for (f = p_faces(obj))
               let(fp=as_points(f,p_vertices(obj)))
                 centroid(fp)  
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
             [entries[i][0] ,i+offset]
           ]
          :[]
          ;
   
function vertex_values(entries)= 
    [for (e = entries) e[1]];
 
function vertex(key,entries) =   // key is an array 
    entries[search([key],entries)[0]][1];
    
// operators
function kis(obj,fn=[],h=0,regular=false) =
// kis each n-face is divided into n triangles which extend to the face centroid
// existimg vertices retained
              
   let(pf=p_faces(obj),
       pv=p_vertices(obj))
   let(newv=   // new centroid vertices    
        [for (f=pf)
         if (selected_face(f,fn) && ( !regular || abs(face_irregularity(f,pv) - 1.0) <0.1))                      
             let(fp=as_points(f,pv))
             [f,centroid(fp) + normal(fp) * h]    // centroid + a bit of normal
        ]) 
   let(newids=vertex_ids(newv,len(pv)))
   let(newf=
       flatten(
         [for (f=pf)                   
            //replace face with triangles
             let(centroid=vertex(f,newids))
             centroid != undef
               ? [for (j=[0:len(f)-1])           
                 let(a=f[j],
                     b=f[(j+1)%len(f)])    
                  [a,b,centroid]
                ]
              : [f]                              // original face
         ]) 
        )         
  
   poly(name=str("k",p_name(obj)),
       vertices= concat(pv, vertex_values(newv)) , 
       faces=newf
   )
; // end kis

function gyro(obj, r=0.3333, h=0.2) = 
// retain original vertices, add face centroids and directed edge points 
//  each N-face becomes N pentagons
    let(pf=p_faces(obj),
        pv=p_vertices(obj),
        pe=p_edges(obj))
    let(newv= 
          concat(
           [for (face=pf)  // centroids
            let(fp=as_points(face,pv))
             [face,centroid(fp) + normal(fp) * h]    // centroid + a bit of normal
           ] ,
           flatten(      //  2 points per edge
              [for (edge = pe)                 
               let (ep = as_points(edge,pv))
                   [ [ edge,  ep[0]+ r *(ep[1]-ep[0])],
                     [ reverse(edge),  ep[1]+ r *(ep[0]-ep[1])]
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
                     centroid=vertex(face,newids))                   
                [a,eab,centroid,eza,eaz]  
            ]
         ]
       )) 
               
    poly(name=str("g",p_name(obj)),
      vertices=  concat(pv, vertex_values(newv)),
      faces= newf
      )
; // end gyro

            
function meta(obj,h=0.1) =
// each face is replaced with 2n triangles based on edge midpoint and centroid
    let(pe=p_edges(obj),
        pf=p_faces(obj),
        pv=p_vertices(obj))
    let (newv =concat(
           [for (face = pf)               // new centroid vertices
            let (fp=as_points(face,pv))
             [face,centroid(fp) + normal(fp)*h]                                
           ],
           [for (edge=pe)
            let (ep = as_points(edge,pv))
            [edge,(ep[0]+ep[1])/2]
           ]))
     let(newids=vertex_ids(newv,len(pv)))
          
     let(newf =
          flatten(
          [for (face=pf) 
             let(centroid=vertex(face,newids))  
             flatten(
              [for (j=[0:len(face)-1])    //  replace face with 2n triangle 
               let (a=face[j],
                    b=face[(j+1)%len(face)],
                    mid=vertex(distinct_edge([a,b]),newids))
                 [ [ mid, centroid, a],
                    [b,centroid, mid] ]  
                 ] )
         ])
      )   
               
     poly(name=str("m",p_name(obj)),
          vertices= concat(pv,vertex_values(newv)),                
          faces=newf
      ) 
 ; //end meta


function cc(obj) =
// Catmull-Clark smoothing
// each face is replaced with n quadralaterals based on edge midpoints vertices and centroid
// edge midpoints are average of edge endpoints and adjacent centroids
// original vertices replaced by weighted average of original vertex, face centroids and edge midpoints

    let(pe=p_edges(obj),
        pf=p_faces(obj),
        pv=p_vertices(obj))
    let (newfv =
           [for (face = pf)               // new centroid vertices
            let (fp=as_points(face,pv))
             [face,centroid(fp)]                                
           ])
    let (newev =                          // new edge 'midpoints'
           [for (edge=pe)
            let (ep = as_points(edge,pv),
                 af1 = face_with_edge(edge,pf),
                 af2 = face_with_edge(reverse(edge),pf),
                 fc1 = vertex(af1, newfv),
                 fc2 = vertex(af2, newfv))
             [edge,(ep[0]+ep[1]+fc1+fc2)/4]
           ])
     let(newfvids=vertex_ids(newfv,len(pv)))
     let(newevids=vertex_ids(newev,len(pv)+len(newfv)))
         
     let(newf =
          flatten(
          [for (face=pf) 
             let(centroid=vertex(face,newfvids))  
             flatten(
              [for (j=[0:len(face)-1])    //  
               let (a=face[j],
                    b=face[(j+1)%len(face)],
                    c=face[(j+2)%len(face)],
                    mid1=vertex(distinct_edge([a,b]),newevids),
                    mid2=vertex(distinct_edge([b,c]),newevids)         
              )
                   [[ centroid, mid1,b,mid2]]
              ])
           ]))   
     let(newv =                       // revised original vertices 
         [ for (i = [0:len(pv)-1])
           let (v = pv[i],
                vf = [for (face = vertex_faces(i,pf)) vertex(face,newfv)],
                F = centroid(vf),
                R = centroid([for (edge = vertex_edges(i,pe)) vertex(edge,newev)]),
                n = len(vf))
           ( F + 2* R + (n  - 3 )* v ) / n
         ])         
     poly(name=str("S",p_name(obj)),
          vertices= concat(newv,vertex_values(newfv),vertex_values(newev)),                
          faces=newf
      ) 
 ; //end cc

function rcc(s,n=0) =
// multilevel Catmull-Clark
    n == 0
         ? s
         : rcc(cc(s),n-1)
;            
function pyra(obj,h=0.0) =   
// very like meta but different triangles
    let(pe=p_edges(obj),
        pf=p_faces(obj),
        pv=p_vertices(obj))
    let(newv=concat(
          [for (face = pf)               // new centroid vertices
            let(fp=as_points(face,pv))
            [face,centroid(fp) + normal(fp)*h]                                  
          ],
         [for (edge=pe)                // new midpoints
          let (ep = as_points(edge,pv))
            [edge,(ep[0]+ep[1])/2]
         ]))
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=flatten(
         [ for (face=pf) 
           let(centroid=vertex(face,newids))  
           flatten( [for (j=[0:len(face)-1]) 
             let(a=face[j],
                 b=face[(j+1)%len(face)], 
                 z=face[(j-1+len(face))%len(face)],        
                 midab = vertex(distinct_edge([a,b]),newids),
                 midza = vertex(distinct_edge([z,a]),newids))             
             [[midza,a,midab], [midza,midab,centroid]]         
             ])
          ] ))
              
     poly(name=str("y",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )
;   // end pyra 
                                 
function ortho(obj,h=0) =  
// each face is replaced with n quadralaterals based on edge midpoints vertices and centroid moved normally
    let (pe=p_edges(obj),
         pf=p_faces(obj),
         pv=p_vertices(obj))
     let(newv=concat(
          [for (face = pf)               // new centroid vertices
            let(fp=as_points(face,pv))
            [face,centroid(fp) + normal(fp)*h]                                  
          ],
         [for (edge=pe)               // new midpoints
          let (ep = as_points(edge,pv))
            [edge,(ep[0]+ep[1])/2]
         ]))
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=
         flatten(
         [ for (face=pf)   
           let(centroid=vertex(face,newids))  
            [for (j=[0:len(face)-1])    
             let(a=face[j],
                 b=face[(j+1)%len(face)],
                 c=face[(j+2)%len(face)],
                 midab= vertex(distinct_edge([a,b]),newids),
                 midbc= vertex(distinct_edge([b,c]),newids))                 
             [centroid,midab,b,midbc]                            
             ]
          ] ))
      
     poly(name=str("o",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )
; // end ortho
       
function trunc(obj,fn=[],r=0.25) =
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
                [edge,  v + (opv - v) * r ]
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



function quinto(obj) =
    let (pv=p_vertices(obj),
         pf=p_faces(obj),
         pe=p_edges(obj))
               
    let (newv = 
         concat(
         [for (edge = pe) 
          let(ep = as_points(edge,pv))
          let(v= (ep[0] + ep[1])/ 2)
          [edge, v]
         ]
         ,
          flatten([for (face = pf)
           let(ep = as_points(face,pv))
           let(c = centroid(ep))
           [ for (j = [0:len(face) - 1])
             let (v= (ep[j] + ep[(j + 1) % len(face)]  + c) / 3)
             [ [face,j], v]  
           ]])
           
          )
          )
     let (newids = vertex_ids(newv,len(pv)))   
     let (newf = 
          concat(   
          [for (face=pf)    // reduced faces
              [for (j=[0:len(face)-1])
               let (nv=vertex([face,j],newids)) 
               nv 
              ]
              ]

              ,
         
           [for (face=pf)
               for (i = [0:len(face)-1])
               let (v = face[i])
               let (e0 = [face[(i-1+len(face)) % len(face)],face[i]])
               let (e1 = [face[i] , face[(i + 1) % len(face)]])
               let (e0p = vertex(distinct_edge(e0),newids))
               let (e1p = vertex(distinct_edge(e1),newids))
               let (iv0 = vertex([face,(i -1 + len(face)) % len(face)],newids))
               let (iv1 = vertex([face,i],newids))
               [v,e1p,iv1,iv0,e0p]
              
              // [v,e0p,iv0,iv1,e1p]
              ]
          
           ) )   

     poly(name=str("q",p_name(obj)),
          vertices= concat(pv,vertex_values(newv)),
          faces=newf
         )        
; // end quinta    

function propellor(obj,r =0.333) =
    let (pf=p_faces(obj),
         pv=p_vertices(obj),
         pe=p_edges(obj))
    let(newv=
         flatten(      //  2 points per edge
              [for (edge = pe)                 
               let (ep = as_points(edge,pv))
                   [ [ edge,  ep[0]+ r *(ep[1]-ep[0])],
                     [ reverse(edge),  ep[1]+ r *(ep[0]-ep[1])]
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


function hexpropello(obj) =
// Dave Mccooey's Hexpropello operator
    let (pf=p_faces(obj),
         pv=p_vertices(obj),
         pe=p_edges(obj))
    let(newv=
          concat(
              //  2 points per edge
              flatten(
               [for (edge = pe)                 
                let (ep = as_points(edge,pv)) 
                 [
                  [ [ edge[0], edge[1]], ep[0] + 1/3*(ep[1]-ep[0]) ],
                  [ [ edge[1], edge[0]], ep[1] + 1/3*(ep[0]-ep[1]) ]
                 ]
               ])
              ,   // new rotated inner face vertices
              
                [for (face= pf)
                 let (v = as_points(face,pv))
                 for (i = [0:len(v)-1])
                   [[face,i],   0.2 * v[i] +
                                0.6 * v[(i+1) % len(v)] + 
                                0.2 * v[(i+2) % len(v)]]  
                 
               ]             
                      
           ))
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=
         concat(    
            [for (face=pf)   // rotated face
               [ for (j=[0:len(face)-1])
                 vertex([face,j],newids)
               ]  
            ]
        ,
            flatten(
             [for (face=pf)   
               [for (j=[0:len(face)-1])
                let (a=face[j],
                     b=vertex([face[j],face[(j+1)%len(face)]],newids),
                     c=vertex([face[(j+1)%len(face)],face[j]],newids),
                     d=vertex([face,j],newids),
                     e=vertex([face,(j - 1 +len(face))%len(face)],newids),
                     f =vertex([face[j],face[(j-1+len(face))%len(face)]],newids))      
                 [a, b, c, d, e, f]
               ]
             ]) 
            
           )
       )        
     poly(name=str("h",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf
     )         
; // end hexpropellor
        
function chamfer(obj,r=0.333) =
    let (pf=p_faces(obj),
         pv=p_vertices(obj))  
    let(newv=              
          flatten(         //  face inset
          [for(face=pf)
           let(fp=as_points(face,pv),
               c=centroid(fp))
            [for (j=[0:len(face)-1])
               [[face,face[j]], fp[j] + r *(c - fp[j])]
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
          [for (v = pv)  (1.0 - r)*v],             // original        
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
       
function snub(obj,h=0.5) = 
   let(pf=p_faces(obj),   
       pv=p_vertices(obj)  )       
       
   let(newv =
          flatten(
             [for (face = pf)   
              let (r = -90 / len(face),
                  fp = as_points(face,pv),
                  c = centroid(fp),
                  n = normal(fp),
                  m =  m_from(c,n) 
                      * m_rotate([0,0,r]) 
                      * m_translate([0,0,h]) 
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
   
function expand(obj,h=0.5) =                    
   let(pf=p_faces(obj),           
       pv=p_vertices(obj))        
   let(newv=
           flatten(
            [for (face = pf)     //move the whole face outwards
             let (fp = as_points(face,pv),
                  c = centroid(fp),
                  n = normal(fp),
                  m =  m_from(c,n)
                      *  m_translate([0,0,h]) 
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

function rexpand(s,h,n=0) =
// used to round edges 
    n == 0
         ? s
         : rexpand(expand(s,h),h *2,n-1)
;
 
function edgequad(obj) =   
// replace each edge with a quad using the centrods of the oposing faces and the edge endpoints                 
   let(pf=p_faces(obj),           
       pv=p_vertices(obj))        
   let(newv=
            [for (face = pf)     // centroids
             let (fp = as_points(face,pv),
                  c = centroid(fp))
              [[face],c]
             ]
             )
   let(newids=vertex_ids(newv,len(pv)))
   let(newf =
          
             [for (face = pf)     // expanded faces
              for (edge=ordered_face_edges(face))
              let (oppface=face_with_edge(reverse(edge),pf),
                   copp=vertex([oppface],newids),
                   c=vertex([face],newids))                 
              if (edge[0]<edge[1])   // no duplicates
                 [edge[0],c,edge[1],copp] 
             ]          
        )
                   
   poly(name=str("e",p_name(obj)),
       vertices= concat(pv,vertex_values(newv)),
       faces=newf
      )
         
; // end edgequad                 
function whirl(obj, r=0.3333, h=0.2) = 
// retain original vertices, add directed edge points  and rotated inset points
//  each edge  becomes 2 hexagons
    let(pf=p_faces(obj),
        pv=p_vertices(obj),
        pe=p_edges(obj))
    let(newv= 
          concat(          
           flatten([for (face=pf)  // centroids
            let (fp=as_points(face,pv))
            let (c = centroid(fp) + normal(fp)*h  )
            [for (i=[0:len(face)-1])
             let (f = face[i])
             let (ep = [fp[i],fp[(i+1) % len(face)]])
             let (mid =  ep[0]+ r *(ep[1]-ep[0])) 
              [[face,f], mid + r  * (c - mid)]
           ]]) ,
           flatten(      //  2 points per edge
              [for (edge = pe)                 
               let (ep = as_points(edge,pv))
                   [ [ edge,  ep[0]+ r *(ep[1]-ep[0])],
                     [ reverse(edge),  ep[1]+ r *(ep[0]-ep[1])]
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

function random(obj,o=0.1) =
    poly(name=str("R",p_name(obj)),
         vertices =
          [for (v = p_vertices(obj))
             v + rands(0,o,3)
          ],
        faces= p_faces(obj)
     )
; 

// triangulation operators - need to  be unified 
          
function qt(obj , shortest=1) =
// bitriangulate quadrilateral faces
// use shortest diagonal so triangles are most nearly equilateral
  let (pf=p_faces(obj),
       pv=p_vertices(obj))
           
  poly(name=str("q",p_name(obj)),
       vertices=pv,          
       faces= flatten(
           [for (f = pf)
            
            len(f) == 4
            ? let (p=as_points(f,pv))
              let(comp = norm(p[0]-p[2]) < norm(p[1]-p[3]) ? 1 :0 )
              comp  == shortest
                    ? [ [f[0],f[1],f[2]], [f[0],f[2],f[3]] ]  
                     : [ [f[1],f[2],f[3]], [f[1],f[3],f[0]] ]  
                :  [f]
           ])
       )
;// end qt
        
function pt(obj) =
// tri-triangulate pentagonal faces
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

function hq(obj,h=0.2) =  
// each hex face is replaced with 3 quadrilaterals based on alternate vertices and centroid moved normally
    let (pe=p_edges(obj),
         pf=p_faces(obj),
         pv=p_vertices(obj))
     let(newv= 
          [ for (face = pf)               // new centroid vertices
            if (len(face)==6) 
               let(fp=as_points(face,pv))
               [face,centroid(fp) + normal(fp)*h]   
                      
          ])
     let(newids=vertex_ids(newv,len(pv)))
     let(newf=
         flatten(
         [ for (face=pf) 
           len(face)==6 
           ? let(centroid=vertex(face,newids))  
             [for (j=[0:2:len(face)-1])    
             let(a=face[j],
                 b=face[(j+1)%len(face)],
                 c=face[(j+2)%len(face)])                 
             [a,b,c,centroid]                            
             ]
           : [face]
          ] ))
      
     poly(name=str("o",p_name(obj)),
          vertices= concat(pv, vertex_values(newv)),
          faces=newf,debug=newf
     )
; // end hq    
            
function tt(obj) =
// quad triangulate triangular faces 
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

  poly(name=str("v",p_name(obj)),
       vertices=
           concat(pv, vertex_values(newv)),  
       faces= newf
       )
;// end tt

function inset_kis(obj,fn=[], r=0.5,h=0) = 
 // as kis but pyramids inset in the face 
    let (pe=p_edges(obj),
         pf=p_faces(obj),
         pv=p_vertices(obj))
     
    let(newv =
         flatten(  
          [for (face = pf)               // new centroid vertices
            let(fp=as_points(face,pv))
            if (selected_face(face,fn))
               let(c=centroid(fp))
               let(ec = c+ normal(fp) * h)     // centroid + a bit of normal  
               concat(  
                      [[face,ec]],      // face centroid
                      [ for (j=[0:len(face)-1])
                         [[face,face[j]], fp[j] + r *(c-fp[j])]
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
                       centroid=vertex(face,newids),
                       mida=vertex([face,a],newids),
                       b=face[(j+1)%len(face)],
                       midb=vertex([face,b],newids)) 
                   [ [a,b,midb,mida]  ,   [centroid,mida,midb] ]         
                 ] )
              : [ face ]
         ] ))       
   
    poly(name=str("i",p_name(obj)),
      vertices=  concat(pv, vertex_values(newv)) ,
      faces= newf
    )
;   // end inset_kis
               
