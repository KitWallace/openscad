// ===== Start irregular-die.scad ================================================================================
// include <../lib/basics.scad>
// ===== Start ../lib/polyfns.scad =====================================================================================
// points functions

// ===== Start basics.scad =============================================================================================
// basic list comprehension functions

function depth(a) =
   a[0]== undef 
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
 
function slice(list,k) =
    [for (e = list) e[k]];
  
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
      
function transform_points(points, matrix) = 
    [for (p=points) m_transform(p, matrix) ] ;
        
// modules to orient objects for rendering
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

// vector functions
function unitv(v)=  
   let (n = norm(v))
   n !=0 ? v/ norm(v) : v;

function signx (x) =
     x==0 ? 1 : sign(x);

function between(a,b,x) = x >= a && x <= b;

function point_between(a,b,r) =
    a * r + b * (1-r);
   
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


function orthogonal(v0,v1,v2) =  cross(v1-v0,v2-v1);

function normal(face) =
     let (n=orthogonal(face[0],face[1],face[2]))
     - n / norm(n);
 
function centroid(points) = 
      vsum(points) / len(points);

// dictionary shorthand assuming present
function find(key,array) =  array[search([key],array)[0]];

function count(val, list) =  // number of occurances of val in list
   ssum([for(v= list) v== val ? 1 :0]);
    
function distinct(list,dlist=[],i=0) =  // return only distinct items of d 
      i==len(list)
         ? dlist
         : search(list[i],dlist) != []
             ? distinct(list,dlist,i+1)
             : distinct(list,concat(dlist,list[i]),i+1)
      ;

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
  
// ===== End basics.scad ===============================================================================================

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
        dihedral = dot < 0 ? 180-angle  : 180 +  angle  
        )
     [dihedral,f0+1,f1+1]; 
         
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
       p_render(obj,faces=true);
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
// ===== End ../lib/polyfns.scad =======================================================================================
// ===== Start ../lib/miller.scad ======================================================================================
// ===== Start hull.scad ===============================================================================================
// list operations
eps=0.0001;

function flatten(l) = [ for (a = l) for (b = a) b ] ;

function _subseq(list,start,end=undef) =
    let(end = end==undef ? len(list):end)
    [for(i=[start:1:end-1]) list[i]];
        
function _delete(list,pos) =
    [for (i=[0:len(list)-1])
        if (i != pos) list[i]
    ];

function _remove(list,entry) =
    [for (e=list)
        if (e != entry) e
    ];

function _remove_all(list,entries,pos=0) =
   pos >= len(entries)
     ? list
     : _remove_all(_remove(list,entries[pos]),entries,pos+1)
   ; 
        
// basic geometry tests          
function _isCollinear(a,b,c) = norm(cross(b-a,c-a)) < eps;

function _firstnoncollinear(list,point1,point2,pos=0) = 
    pos >= len(list) 
        ? undef 
        : ! _isCollinear(point1,point2,list[pos]) 
           ? pos 
           : _firstnoncollinear(list,point1,point2,pos+1);
                
function _isCoplanar(a,b,c,d) = abs((d-a)*cross(b-a,c-a)) < eps;

function _firstnoncoplanar(list,point1,point2,point3,pos=0) =
   pos >= len(list) 
        ? undef 
        : ! _isCoplanar(point1,point2,point3,list[pos]) 
           ? pos : 
           _firstnoncoplanar(list,point1,point2,point3,pos+1);

// orientation tests        
function _sameSide(p1,p2, a,b) = 
    let(cp1 = cross(b-a, p1-a),
        cp2 = cross(b-a, p2-a)) 
    cp1*cp2 >= eps;
        
function _insideTriangle(p, t) = 
    _sameSide(p,t[0],t[1],t[2]) &&
    _sameSide(p,t[1],t[2],t[0]) &&
    _sameSide(p,t[2],t[0],t[1]);

function _isBoundedBy(a,face,strict=false) =
    cross(face[1]-face[0],face[2]-face[0])*(a-face[0]);

function _point_outside_triangle(p, triangle) =
    let(c=_isBoundedBy(p, triangle))
    c > 0 || (c == 0 && _insideTriangle(p, triangle));
    
function _insidePoly(p, triangles, pos=0) = 
    pos >= len(triangles) 
         ? true 
         : !_point_outside_triangle(p, triangles[pos]) 
           ? false 
           : _insidePoly(p, triangles, pos=pos+1);
           
function _orientTet(a,b,c,d) =
    _isBoundedBy(d,[a,b,c]) >= eps    //  get faces oriented the same way 
        ? [[a,b,c],[b,a,d],[c,b,d],[a,c,d]] 
        : [[c,b,a],[d,a,b],[d,b,c],[d,c,a]];
            
// list search 
function _find(list,value) =
    let(m=search([value],list,1)[0]) 
    m==[] ? undef : m;
    
function find(array,key) =  array[search([key],array)[0]];
         
function _distinct(list,dlist=[],i=0) =
    i >= len(list) 
      ? dlist 
      : _find(dlist,list[i]) == undef 
        ? _distinct(list,concat(dlist,[list[i]]),i+1) 
        : _distinct(list,dlist,i+1);

// find convex hull using ? quick hull ?         
function pointHull3D(points) =
// return hull as a number of triangular faces
    let (pts = _distinct(points))
    let (ft=_initialTet(pts))  
     _expandHull(ft[0], ft[1]);
     
function _initialTri(list) = 
    assert(len(list)>=3)
    let(a=list[0],
        b=list[1],
        rest=_subseq(list,2),
        ci=_firstnoncollinear(rest,a,b),        
        c=assert(ci != undef) rest[ci],
        rlist=_delete(rest,ci))
        [[a,b,c],rlist];
        
function _initialTet(list) = 
    let(ft=_initialTri(list),
        tri=ft[0],
        rest=ft[1],
        di=assert(len(rest)>0) _firstnoncoplanar(rest,tri[0],tri[1],tri[2]),
        d=assert(di != undef) rest[di],
        rrest= _delete(rest,di))
        [_orientTet(tri[0],tri[1],tri[2],d),rrest];
     
function _triangle_edges(triangle) =
    [[triangle[0],triangle[1]],
     [triangle[1],triangle[2]],
     [triangle[2],triangle[0]]
    ];

function _equal_edges(a,b) = a==b;

function _triangle_has_edge(triangle,edge) =
     let (edges = _triangle_edges(triangle))
     _equal_edges(edges[0],edge) || edges[1]==edge || edges[2] == edge ;
     
function _outerEdges(triangles) =
    let(edges=
        flatten([for(t=triangles) _triangle_edges(t)]))   
    [for(e=edges) 
        if(undef == _find(edges,[e[1],e[0]])) e];
      
function _unlit(triangles, p) = 
    [for(t=triangles) 
         if(_isBoundedBy(p, t) >= eps) t];
        
function _addToHull(hull, p) = 
    let(unlit = _unlit(hull,p),
        edges = _outerEdges(unlit))
        concat(unlit, [for(e=edges) [e[1],e[0],p]]);

function _expandHull(hull, points, pos=0) =
    pos >= len(points) 
        ? hull 
        : ! _insidePoly(points[pos],hull) 
            ? _expandHull(_addToHull(hull,points[pos]),points,pos=pos+1)  // add point
            : _expandHull(hull, points, pos=pos+1); // ignore point
 
// triangulated hull

function extractPointsFromHull(hull) =
    _distinct( [for(triangle=hull) for( v=triangle) v] );
        
function _makePointsAndFaces(triangles) =
    let(points=extractPointsFromHull(triangles))
    [points, [for(t=triangles) [for(v=t) _find(points,v)]]];

function pointHull(points) =
    _makePointsAndFaces(pointHull3D(points));

function triangulatedHull(points) =
    let (hull = pointHull3D(points))
    _makePointsAndFaces(hull);
    
    
// unite triangular faces to create polygonal faces 

function _tri_minus_edge(tri,edge)  =
     [for (p=tri) if(p != edge[0] && p != edge[1]) p];
        
function connected_tris(tri,tris,pos=1) =
    let(edges=_triangle_edges(tri))           
    flatten([for (e = edges)
       [for(a_tri = tris)
       let (a_edges = _triangle_edges(a_tri))
       if  (_find(a_edges,[e[1],e[0]]) != undef)
          let (p = _tri_minus_edge(a_tri, e))
          if(_isCoplanar(tri[0],tri[1],tri[2],p[0]))
             a_tri
       ]
    ]);  
          
function make_face(working,tris,face=[]) =
    len(working) == 0
       ? face
       : let (t=working[0])
         let (facex=concat(face,[t]))
         let (connected = connected_tris(t,tris))
         connected == undef
            ? let (workingx= _remove(working,t))
              let (trisx= _remove(tris,t))
              make_face(workingx,trisx,facex)
            : let (workingx= concat(_remove(working,t),connected))
              let (trisx = _remove_all(tris,concat(t,connected)))
              make_face(workingx,trisx,facex)
     ;
          
function make_poly(tris,faces=[]) =
    len(tris) == 0 
        ? faces 
        : let (t=tris[0])
          let (face = make_face([t],_remove(tris,t)))
          make_poly(_remove_all(tris,face),concat(faces,[face]));
      
function connect_edges_r(edge,edges) =
   len(edges) == 0 
      ? []
      : let (next =
          [for (i=[0:len(edges)-1])
           if(edge[1]==edges[i][0])
              edges[i] 
          ][0])
        concat([edge[0]],connect_edges_r(next,_remove(edges,edge)))
  ;

function connect_edges(edges) =
   connect_edges_r(edges[0],_remove(edges,edges[0]));
      
function edges_to_vertices(edges) =  
      [for (e = edges) e[0]];

function triangles_to_face (tris) =
      connect_edges(_outerEdges(tris)); 

function tris_to_faces(tris) =
    [for (t=tris) triangles_to_face(t)];
        
function facedHull(points) =
    let (tris = pointHull3D(points))
    let (grouped_tris= make_poly(tris))
    let (faces= tris_to_faces(grouped_tris))
    _makePointsAndFaces(faces);
// ===== End hull.scad =================================================================================================
 
eps= 0.01;

function comb_3 (N) =
   flatten(flatten([for (i=[0:N-3])
       [for (j=[i+1:N-2])
           [for (k=[j+1:N-1])
               [i,j,k]
           ]
       ]
   ]));

// solve matrix equation
function _d22(a00,a01,a10,a11) = a00*a11-a01*a10;

function _determinant3x3(m) =
     m[0][0]*_d22(m[1][1],m[1][2],m[2][1],m[2][2])
    -m[0][1]*_d22(m[1][0],m[1][2],m[2][0],m[2][2])
    +m[0][2]*_d22(m[1][0],m[1][1],m[2][0],m[2][1]);
        
// Cramer's rule for inversion

function _solve3(a,b,c) = 
     let (na=a[0],nb=b[0],nc=c[0])
     let (da=a[1],db=b[1],dc=c[1])
     let (det=_determinant3x3([na,nb,nc]))
     det == 0 
       ? undef 
       :
        let(rhs=[da,db,dc],
            col0=[na[0],nb[0],nc[0]],
            col1=[na[1],nb[1],nc[1]],
            col2=[na[2],nb[2],nc[2]])
       
       [_determinant3x3([rhs,col1,col2]),
        _determinant3x3([col0,rhs,col2]),
        _determinant3x3([col0,col1,rhs])
       ] / det;

     
function _perp_distance(plane,point) =
       plane[0]*point - plane[1] ;
         
function _point_on_or_inside(planes,point,i=0) =
    i >= len(planes)
       ? true
       : let (pd=_perp_distance(planes[i],point))
         pd > eps
           ? false         
           : _point_on_or_inside(planes,point,i+1);

function _normalize_planes(planes) =
      [for (plane= planes)
           [plane[0],plane[1]*norm(plane[0])]
      ];
      
function _intersections(combs,planes) =     
     [for (c = combs) 
      let (p = _solve3(planes[c[0]],planes[c[1]],planes[c[2]]))
      if (p != undef )
          flatten(p)
     ]; 

function _inside (points,planes) =
    [for (p=points)
       if( _point_on_or_inside(planes,p))
         p
    ];

function _equal_pts(a,b) = norm(a-b) < eps;

function _pt_in_pointsx(pt,pts) =
     let (same= [for (p=pts) if (_equal_pts(p,pt)) p])
     len(same) > 0;
     
function _pt_in_points(pt,pts,i=0) =
     i >= len(pts)
        ? false
        : _equal_pts(pts[i],pt)
          ? true
          : _pt_in_points(pt,pts,i+1);
     
function _distinct_points(list,dlist=[],i=0) =
    i >= len(list) 
      ? dlist 
      : _pt_in_points(list[i],dlist)
        ? _distinct_points(list,dlist,i+1)
        : _distinct_points(list,concat(dlist,[list[i]]),i+1); 
           
function perturb(faces,r) =
     [for (face=faces)
       let(d= rands(-r,+r,1)[0])
       [face[0],face[1]+d]
     ];

function miller_to_points(faces) =
  let (N=len(faces))
  let (combs = comb_3(N))
  let (nfaces=_normalize_planes(faces))
  let (inter = _intersections(combs,nfaces))
  let (inside = _inside(inter,nfaces))
  let (pts = _distinct_points(inside))
  pts;

function points_to_poly(name,pts) =
   let (polyhull=facedHull(pts))
   [name,polyhull[0],polyhull[1]];

function points_to_tri_poly(name,pts) =
   let (polyhull=triangulatedHull(pts))
   [name,polyhull[0],polyhull[1]];

module hull_points(pts) {
//     hull()
      for (p = pts) 
          translate(p)
             sphere(r=0.1);
  }

function compound(name,components) =
   [name,flatten(
   [for (component = components)
     let (faces =component[0][1])
     let (scale= component[1])
     [for (f = faces)
        [f[0],f[1]*scale]
     ]
   ])]; 

function face_to_miller(points) =
         let (normal = normal(points))
         let (d = normal*points[0])  //any point on the face
         [normal,d];
     
function poly_to_miller(obj) =
    [
      obj[0],
        [for (f=p_faces(obj))
         let (points =as_points(f,p_vertices(obj)))
         face_to_miller(points)
        ]
     ];  // ===== End ../lib/miller.scad ========================================================================================

module solid(vertices,faces,radius,corner_resolution) {
     if(radius==0)
         polyhedron(vertices,faces);
     else hull() 
        for (v=vertices) 
           translate(v) 
             sphere(radius,$fn=corner_resolution);
 };
 
module pips(vertices,faces,pip_size,pip_inset_ratio,pip_offset, pip_resolution) {   
    pips=[[0],[1,3],[1,0,3],[1,2,3,4],[0,1,2,3,4],[1,2,3,4,5,7]];

    for (i =[0:len(faces)-1])  {
           face=faces[i];
           facep = face(vertices,face);
           norm = normal(facep);
           pips_p = pip_points(facep,pip_inset_ratio);
           face_pips = pips[i];
           for (j=face_pips)
              translate(norm*pip_offset)
                 translate(pips_p[j])
                   sphere(pip_size,$fn=pip_resolution);         
     }
};
 
function orthogonal(v0,v1,v2) =  cross(v1-v0,v2-v1);

function normal(face) =
     let (n=orthogonal(face[0],face[1],face[2]))
     - n / norm(n);
 
function centroid(points) = 
      vsum(points) / len(points);

function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];

function flatten(l) = [ for (a = l) for (b = a) b ] ;
    
function between(a,b,r) =
    a * r + b * (1-r);

function face(vertices,face) =
   [for (i=face) vertices[i] ];
      
function pip_points(face,r) =
  let (p0=centroid(face))
  let (corners=
     [for (p=face) between(p0,p,r)])
  let (edges=
     [for (i=[0:len(face)-1])
         between(corners[i],corners[(i + 1) % len(face)],0.5)])
  flatten([[p0],corners,edges]);
     

cube=[
[1,0,0],
[-1,0,0],
[0,1,0],
[0,-1,0],
[0,0,1],
[0,0,-1]
];


function distort(miller,r,d) =
 [for (m=miller)
     let (rv=rands(-r,r,3))
     [m+rv,d]
 ];
 
// scale 
scale=30;
// pip size
pip_size=3.5;
//pip inset_ratio
pip_inset_ratio=0.5;
//pip offset from face
pip_offset=1.5;
//pip resolution 
pip_resolution=20;
//corner radius
radius =2;
// corner resolution
corner_resolution = 20;
 
 
// main

miller = distort(cube,0.1,20);
echo(miller);
 
pts = miller_to_points(miller);
// echo(pts);

poly= place(points_to_poly ("unfair",pts));
vertices=poly[1];
faces=poly[2];

difference() {
   solid(vertices,faces,radius,corner_resolution);
   pips(vertices,faces,pip_size,pip_inset_ratio,pip_offset,pip_resolution) ;
}

fa=face_areas(poly);
echo([for (f=fa)  100* f/fa[0]]);
// ===== End irregular-die.scad ==================================================================================
