// points functions
include <basics.scad>

function as_points(indexes,points) =
    [for (i=[0:len(indexes)-1])
          points[indexes[i]]
    ]; 
 
function vnorm(points) =
     [for (p=points) norm(p)];
  
function average_norm(points) =
       ssum(vnorm(points)) / len(points);

function transform_points(points, matrix) = 
    [for (p=points) m_transform(p, matrix) ] ;
   
// vertex functions

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
     
function vertex_edges(v,edges) = // return the ordered edges containing v
      [for (e = edges) if(e[0]==v || e[1]==v) e];
                       
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

function face_with_edge_index(edge,faces) =
     flatten(
        [for (i = [0:len(faces)-1])
           let(f = faces[i])
           if (vcontains(edge,ordered_face_edges(f)))
           i
        ])[0];
                  
function dihedral_angle(edge,faces,points)=
    let(f0 = face_with_edge(edge,faces),
        f1 = face_with_edge(reverse(edge),faces),
        p0 = as_points(f0,points),
        p1 = as_points(f1,points),
        n0 = normal(p0),
        n1 = normal(p1),
        angle =  angle_between(n0,n1),
        dot=(centroid(p0)-centroid(p1))*n1,
        dihedral = dot < 0 ? 180-angle  : 180 +  angle  
        )
     dihedral;     
   
function dihedral_angle_index(edge,faces,points)=
    let(
        f0 = face_with_edge_index(edge,faces),
        f1 = face_with_edge_index(reverse(edge),faces),
        p0 = as_points(faces[f0],points),
        p1 = as_points(faces[f1],points),
        n0 = normal(p0),
        n1 = normal(p1),
        angle =  angle_between(n0,n1),
        dot=(centroid(p0)-centroid(p1))*n1,
        dihedral = dot < 0 ? 180-angle  : 180 +  angle ,
        edge = f0 < f1 ? [f0+1,f1+1] : [f1+1,f0+1]
        )
     [dihedral,edge]; 
         
function dihedral_angle_faces(f0,f1,faces,points)=
    let(p0 = as_points(faces[f0],points),
        p1 = as_points(faces[f1],points),
        n0 = normal(p0),
        n1 = normal(p1),
        angle =  angle_between(n0,n1),
        dot=(centroid(p0)-centroid(p1))*n1,
        dihedral = dot < 0 ? 180-angle  : 180 +  angle  
        )
     dihedral; 

//face functions
function selected_face(face,fn) = 
     fn == [] || (len(fn)==undef ?  len(face)== fn : search(len(face),fn) != []) ;

function triangle(a,b) = norm(cross(a,b))/2;

function face_area(face) =
     ssum([for (i=[0:len(face)-1])
           triangle(face[i], face[(i+1)%len(face)]) ]);
     
function face_areas(obj) =
   [for (f=p_faces(obj))
       let(face_points = as_points(f,p_vertices(obj)))
       let(centroid=centroid(face_points))
          face_area(vadd(face_points,-centroid))
   ];

function face_areas_index(obj) =
   [for (face=p_faces(obj))
       let(face_points = as_points(face,p_vertices(obj)))
       let(centroid=centroid(face_points))
          [face,face_area(vadd(face_points,-centroid))]
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
        cosine_between(normal(points), centroid(points)) < 0
        ?  reverse(face)  :  face
    ];

function bounding_box(vertices) =
    bounding_box_3d(vertices);
    
function bounding_box_3d(vertices) =
   [ [ min([for (v = vertices) v.x]),  
       min([for (v = vertices) v.y]),
       min([for (v = vertices) v.z])],
     [ max([for (v = vertices) v.x]), 
       max([for (v = vertices) v.y]),
       max([for (v= vertices) v.z])] 
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

function p_face_as_points(face,obj) =
     as_points(face,p_vertices(obj));
     
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
       
module show_points(obj,r=0.1) {
    for (point=p_vertices(obj))
        if (point != [])   // ignore null points
           translate(point) sphere(r);
};

module show_edge(edge, r) {
    p0 = edge[0]; 
    p1 = edge[1];
    hull() {
       translate(p0) sphere(r);
       translate(p1) sphere(r);
    } 
};

module show_edges(obj,r=0.1) {
    for (edge = p_edges(obj))
        show_edge(as_points(edge, p_vertices(obj)), r); 
};
  
    
module show_solid(obj) {
    polyhedron(p_vertices(obj),p_faces(obj),convexity=10);
};
       
module p_render(obj,show_vertices=false,show_edges=false,show_faces=true, rv=0.04, re=0.02) {
     if(show_faces) 
          show_solid(obj);
     if(show_vertices) 
          show_points(obj,rv);
     if(show_edges)
          show_edges(obj,re);
};

module p_hull(obj,r=0.01){
  hull() {
      for (p=p_vertices(obj))
          translate(p) sphere(r);    
  }
};
   
module p_describe(obj){
    echo(p_description(obj));
}

module p_print(obj) {
    p_describe(obj);
    echo(" Vertices " ,p_vertices(obj));
    echo(" Faces ", p_faces(obj));
    edges=p_edges(obj);
    echo(str(len(edges)," Edges ",edges));
    non_planar=p_non_planar_faces(obj);
    echo(str(len(non_planar)," faces are not planar", non_planar));
    debug=p_debug(obj);
    if(debug!=[]) echo("Debug",debug);
};

module p_dihedral(obj) {
    // output solid dihedral angles 
    angles = [for (edge = p_edges(obj))
              dihedral_angle_index(edge,p_faces(obj),p_vertices(obj))
           ];
    sorted_angles = quicksort_kv(angles);
//    echo(sorted_angles);
    distinct_angles = distinct(slice(sorted_angles,0));
    for (angle=distinct_angles) {
         edges= search([angle],sorted_angles,num_returns_per_match=0)[0];
//         echo(edges);
         edge0 = sorted_angles[edges[0]];
         angle = edge0[0];
         acute_angle = angle <180 ? angle : 360 - angle;
         bevel_angle = 90 - acute_angle/2;
         echo(str("angle=",angle," ,bevel=",bevel_angle," ,edges=",
             [for (e=edges)
                 sorted_angles[e][1]
             ]));
    };
};

// centering and resizing
        
function centroid_points(points) = 
     vadd(points, - centroid(points));
        
function p_inscribed_resize(obj,radius=1) =
    let(pv=centroid_points(p_vertices(obj)))
    let (centroids= [for (f=p_faces(obj))
                       norm(centroid(as_points(f,pv)))
                      ])
    let (average = ssum(centroids) / len(centroids))
    poly(name=p_name(obj),
         vertices = pv * radius /average,
         faces=p_faces(obj),
         debug=centroids
         );

function p_midscribed_resize(obj,radius=1) =
    let(pv=centroid_points(p_vertices(obj)))
    let(centroids= [for (e=p_edges(obj))
                    let (ep = as_points(e,pv))
                    norm((ep[0]+ep[1])/2)
                   ])
    let (average = ssum(centroids) / len(centroids))
    poly(name=p_name(obj),
         vertices = pv * radius /average,
         faces=p_faces(obj),
         debug=centroids
         );

function p_circumscribed_resize(obj,radius=1) =
    let(pv=centroid_points(p_vertices(obj)))
    let(average=average_norm(pv))
    poly(name=p_name(obj),
         vertices=pv * radius /average,
         faces=p_faces(obj),
         debug=average
    );
 
function p_resize(obj,radius=1) =
    p_circumscribed_resize(obj,radius);

function p_transform(obj,matrix) =
   poly(
       name=str("X",p_name(obj)),
       vertices=transform_points(p_vertices(obj),matrix),
       faces=p_faces(obj));

function place(obj,f) =
// place on nomated face or largest face for printing
   let (face= f == undef ? max_area(face_areas_index(obj)) : p_faces(obj)[f])
   let (points =as_points(face,p_vertices(obj)))
   let (n = normal(points), c=centroid(points))
   let (m=m_from(c,-n))
   p_transform(obj,m)
;

function orient(obj) =
// ensure faces have lhs order
    poly(name=str("M",p_name(obj)),
         vertices= p_vertices(obj),
         faces = lhs_faces(p_faces(obj),p_vertices(obj))
    );
 
function invert(obj,p) =
// invert vertices 
    poly(name=str("V",p_name(obj)),
         vertices= 
            [ for (v =p_vertices(obj))
              let (n=norm(v))
              v /  pow(n,p)  
            ],
         faces = p_faces(obj)
    );
function skew(obj,a,b,c) =
   let (m =  [
      [1, 0, 0,  0],
      [tan(a), 1, 0,  0],
      [tan(b), 0, 1,  0],
      [tan(c),  0,  0,  1]
    ]) 
    poly(
       name=str("X",p_name(obj)),
       vertices=transform_points(p_vertices(obj),m),
       faces=p_faces(obj));
            
function openface(obj,outer_inset_ratio=0.2, outer_inset, inner_inset_ratio, inner_inset,depth=0.2,fn=[],min_edge_length=0.01,nocut=0) = 
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
            v + depth * unitv(av_norm)
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
                     c=centroid(fp),
                     oc=centroid(ofp))
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
                           
   poly(name=str("L",p_name(obj)),
       vertices=  concat(pv, inv, vertex_values(newv)) ,    
       faces= newf,
       debug=newv       
       )
; // end openface 


function inset(obj,r=0.3, h=-0.1, fn=[]) = 
// upper and lower inset can be specified by ratio or absolute distance
   let(pf=p_faces(obj),           
       pv=p_vertices(obj))    
   let (newv =   
 // the inset points on outer and inner surfaces
 // outer inset points keyed by face, v, inner points by face,-v-1
         flatten(
           [ for (face = pf)
             if(selected_face(face,fn))
             let(fp=as_points(face,pv),
                  c=centroid(fp))
                    [for (i=[0:len(face)-1])
                     let(ip = fp[i] + r * (c-fp[i]) + h *  normal(fp) )                  
                     [ [face,face[i]],ip]
                    ]
             ])          
           )
   let(newids=vertex_ids(newv,len(pv)))
   let(newf =
         flatten(
          [ for (i = [0:len(pf)-1])   
            let(face = pf[i])
            selected_face(face,fn)
              
               ? flatten(concat([for (j=[0:len(face)-1])   // add new face for each edge
                  let (a=face[j],
                       inseta = vertex([face,a],newids),
                       b=face[(j+1)%len(face)],
                       insetb= vertex([face,b],newids))             
                      [[a,b,insetb,inseta]]               
                  ],
                  [[[for (j=[0:len(face)-1]) 
                   let (a=face[j])
                   vertex([face,a],newids)
                  ]]]))
                  
                : [face]
               
         ] ))    
                           
   poly(name=str("n",p_name(obj)),
       vertices=  concat(pv, vertex_values(newv)) ,    
       faces= newf
       )
; // end inset
                  
function p_rotate_to(obj,n) =
     p_transform(obj,m_from([0,0,0],-n));
                  
module p_render_text(obj,texts,font,depth,offset,size) {
    
/*
    obj is a polyhedron object created as a conway seed or chain of operation
    texts is an array of strings to be placed on the faces of s
    fint is the definition of the fint used by text()
    depth is the depth of the incised text
    offset is the offset of the strings to control the horizontal alignment
    size is the size of the text - because the defualt solid is about 1 mm in 
        size, and the default font size is 10, this needs to be quite small.
    
   e.g. 
    scale(20) p_render_text(place(O()),["1","2","3","4","5","6","7","8"],"Georgia",0.8,4,0.06);
    
    creates an octahedron with the numbers 1 to 8 on the faces
*/
    
 difference() {
       p_render(obj,show_faces=true);
       for (i =[0:len(texts)-1])  {
           face=p_faces(obj)[i];
           facep = as_points(face,p_vertices(obj));
           center=centroid(facep);
           normal=normal(facep);
           echo(i,face,facep,center,normal,texts[i]);
           orient_to(center,normal)
               scale(size) rotate([0,0,90])
                   translate([-offset,0,-depth])
                     linear_extrude(height=depth+0.1)
                        text(texts[i],valign="center", font=font);
       }
     }
 }  // end of p_render_text
   

// modulation  
                           
function modulate_points(points) =
   [for(p=points)
       let(s=xyz_to_spherical(p),
           fs=fmod(s[0],s[1],s[2]))
       spherical_to_xyz(fs[0],fs[1],fs[2])
   ];

function xyz_to_spherical(p) =
    [ norm(p), acos(p.z/ norm(p)), atan2(p.y,p.x)] ;

function spherical_to_xyz(r,theta,phi) =
    [ r * sin(theta) * cos(phi),
      r * sin(theta) * sin(phi),
      r * cos(theta)];

function modulate(obj) =
    poly(name=str("W",p_name(obj)),
         vertices=modulate_points(p_vertices(obj)),         
         faces= 
          [ for (face =p_faces(obj))
              reverse(face)
          ]
    )
;  // end modulate

function scale(obj,s)=
   p_transform(obj,m_scale(s)) ;

// object trimming

module ground(z=200) {
   translate([0,0,-z]) cube(z*2,center=true);
} 

module sky(z=200) {
   rotate([0,180,0]) ground(z);
}

// solid faces



module solid_face(obj,face,thickness) {
     vertices =p_vertices(obj);
     tvertices = [for (p = face) vertices[p]];
     normal=normal(tvertices);
//    upper=vadd(tvertices,thickness/2 *normal) ; 
     upper=tvertices;
/*  
    find dihedral angle at each edge  
    compute offset at each corner of the face
    offset set the point so that the thickness is as given
    nearly there perhaps - works for C() but not for D
  */
    lower = 
        [ for (i=[0:len(face)-1])
          let (edge0= [face[(i-1+len(face))%len(face)], face[i]])
          let (angle0 = dihedral_angle(edge0,p_faces(obj),p_vertices(obj)) /2 )
          let (ed0 = unitv(vertices[edge0[1]]-vertices[edge0[0]]))
          let(v0 = ( ( ed0 + sin(angle0) * normal )*thickness))
          let (edge1= [face[i],face[(i+1)%len(face)]])
          let (angle1 = dihedral_angle(edge1,p_faces(obj),p_vertices(obj)) /2 )
          let (ed1 = unitv(vertices[edge1[0]]-vertices[edge1[1]]))
          let(v1 = ( (ed1 +sin(angle1) * normal)*thickness))
          let (ed=vertices[face[i]] - (v0+v1)/2)
            ed    
        ] ;
     echo(reverse(lower));
     // construct faces
     top = [for(i=[0:len(face)-1]) i];
     bottom = [for(i=[0:len(face)-1]) 2*len(face)-1-i];
     sides = [for(i=[0:len(face)-1])
                [i,(i+1)%len(face),(i+1)%len(face)+len(face),i+len(face)]
             ];
     s_faces = concat([top],[bottom],sides);
     s_vertices= concat(upper,lower);
     echo(s_vertices);
     polyhedron(s_vertices,s_faces);
  };
  
  

module include_solid_faces(obj,face_list,thickness) {
    faces= p_faces(obj);
    for (i = face_list) {
        face=faces[i];
        solid_face(obj,faces[i],thickness);
    }
};

/*
module enclude_solid_faces(obj,face_list,thickness) {
    faces= p_faces(obj);
    for (i = p_faces(obj) {
        if (face=faces[i];
        solid_face(obj,faces[i],thickness);
    }
};

module solid_faces(obj,thickness) {
    faces= p_faces(obj);
    for (i=[0:len(faces) -1]) {
        face=faces[i];
        if (i ==floor($t*25))
            solid_face(obj,faces[i],thickness);
        }
};


*/

function points_as_xml(points) =
   str(
     "&lt;points&gt;\n",
     rstr([for (p=points)
          str("&lt;point&gt;",p.x,",",p.y,",",p.z,"&lt;/point&gt;\n")
     ]),
     "&lt;/points&gt;\n"
     );
     
function faces_as_xml(faces) =
   str(
     "&lt;faces&gt;\n",
     rstr([for (f=faces)
          str("&lt;face&gt;",rstr([for (v=f) str(v,",")]),"&lt;/face&gt;\n")
     ]),
     "&lt;/faces&gt;\n"
     );
     
     
function poly_as_xml(poly,id) =
     str("\n\n&lt;solid&gt;\n",
         "&lt;id&gt;",id,"&lt;/id&gt;\n",
         "&lt;name&gt;",poly[0],"&lt;/name&gt;\n",
         points_as_xml(poly[1]),
         faces_as_xml(poly[2]),
        "&lt;/solid&gt;\n\n" 
         ); 
