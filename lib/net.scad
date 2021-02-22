// functions to generate a net from a polyhedron

include <../lib/svg.scad>
include <../lib/basics.scad>
include <../lib/poly.scad>

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

module show_directed_edge(e,r=1) {
     translate(e[0]) {
         sphere(r*1.5);
         translate((e[1]-e[0])*0.8) sphere(r);
     }
}

module show_face(face,t) {
// render (convex) face by hulling spheres placed at the vertices
    hull()
    for (i=[0:len(face) -1])
       translate(face[i]) sphere(t/2);     
} 
module show_faces(faces,t,colors,number_faces) {
   for (i=[0:len(faces)-1]) {
      face=faces[i];
      color(colors[i%len(colors)])    // pretty random
          show_face(face,t);
      if (number_faces)
      color("black") orient_to(centroid(face),-normal(face))  text(str(i),valign="center",font="Georgia",size=2);
   }
}
 
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
                           [face_area(as_points(faces[fe[1]],points)),fe]],
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
     
function net_position(obj,net,closedness,scale) = 
   let (faces_at_origin = faces_to_origin(obj,scale)) //in index order
   let (start=net[0][0])
   let (faces=net_position_r(net,faces_at_origin,closedness,start))
   [for (f=quicksort_kv(faces)) f[1]];
 
function net_position_r(net,faces,closedness,root,current) =
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
              current==undef ? [[root,root_face]] : [], // first face 
              len(adjacents) > 0
              ? flatten([for (adjacent = adjacents)
                 let (root_side=adjacent[0],
                      face_index=adjacent[1],
                      face_side=adjacent[2],
                      dihedral=adjacent[3],
                      angle = (180-dihedral)*closedness,
                      face= faces[face_index],
                      rface= place_face(angle,root_face,root_side,face,face_side), 
                      childfaces = net_position_r(net,faces,closedness,face_index,rface),
                      tface = [[face_index,rface]]
                      )                
                  concat(tface,childfaces)
                ])
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


function net_edges(faces) =
   flatten([ for (face = faces) 
     [for (i=[0:len(face)-1])  
      [face[i],face[(i + 1) % len(face)]]
      ] 
   ])
;

function equal_edges(e0,e1) =
  ( norm(e0[0] - e1[0])
     + norm(e0[1] - e1[1]) )< 0.2    
;
        
function interior_edge(edges,i,start) =
     let(edge=edges[i])
     let(redge=[edge[1],edge[0]])
        [for (j=[start:len(edges)-1])
            let(oedge = edges[j]) 
            if (equal_edges(redge,oedge)) edge
        ] ;
           
function interior_edges(edges) =
    [for (i=[0:len(edges)-1])
        let(edge = edges[i]) 
        if (interior_edge(edges,i,i))
             edge
     ];
function exterior_edges(edges) =
    [for (i=[0:len(edges)-1])
        let(edge = edges[i]) 
        if (!interior_edge(edges,i,0))
             edge
     ]; 
        
module p_net_render(obj,closedness=0,thickness=0.1,
     colors=["green","blue","red","yellow","teal",
        ,"purple","orange",
        "paleGreen","slateblue","greenyellow"] ,
      scale=1,number_faces=false,tab_height=0,show_svg=true) {
//    echo(p_description(obj));
    net=p_create_net(obj);
//    echo(net);
    positioned_faces = net_position(obj,net,closedness,scale);
//    echo("positioned_faces",positioned_faces); 
    net_edges = net_edges(positioned_faces);
//    echo("net edges",net_edges);
    net_vertices = flatten(net_edges);  // duplicated but only used for determining the bounding box
//    echo("vertices",net_vertices);
    iedges = interior_edges(net_edges);
//    echo("iedges",iedges);
    eedges = exterior_edges(net_edges);  
//    echo("eedges",eedges);


    mirror([0,0,1])
        show_faces(positioned_faces,thickness,colors,number_faces); 
    
   if(show_svg)
        p_svg(net_vertices,positioned_faces,iedges,eedges,p_name(obj),thickness,number_faces,tab_height);
}
   
// making the tabs
// ordering exterior edges

function pt_equal(a,b) =
    norm(a-b) < 0.001;

function edge_match (e,f) =
     pt_equal(e[1],f[0]) 
     ||
     pt_equal(e[1],f[1]); 
    
function order_edges(edges) =
    order_edges_r ([edges[0]],remove (edges,edges[0]));
 
function match_edges(edge,edges,i=0) =
    i <len(edges)
      ? let (next = edges[i])
        edge_match(edge,next)
         ? next
         : match_edges(edge,edges,i+1)
      : false;
 
function order_edges_r(ol,edges)=
    len(edges) > 0  
    ? let(last = ol[len(ol)-1])
      let(next_edge  =match_edges(last,edges))
      let(next= 
             pt_equal(last[1],next_edge[0]) 
             ? next_edge
             : [next_edge[1],next_edge[0]])
      order_edges_r(concat(ol,[next]),
                  remove(edges,next_edge))
    :ol;

function edges_to_polygon(oedges) =
     [for (e=oedges) e[0] ];

function m_edge_to_edge(edge1, edge2,end=0) =
  // need to 
    let (start = (end==0 || end== undef) ? 1 : 0)
    let (a = angle_between(  
                edge2[1] - edge2[0],
                edge1[0] - edge1[1],
                [0,0,1]))
    let (t1 = m_translate(-edge1[start]))
    let (r =  m_rotate([0,0,-a]))
    let (t2 = m_translate(edge2[end])) 
    t1*r*t2;

     
function tabs_to_svg(oedges,p=0.25,interior_color,exterior_color,width) =
    let(poly = edges_to_polygon(oedges))
    rstr(
     [for (i=[0:len(poly)-1]) 
       if (i % 2 == 0) 
          let(a=poly[i],
              b=poly[(i+1) % len(poly)],
              l= norm(b-a),
              tab=[[0,0,0],[l,0,0],[l/2,-l*p,0]],
              m = m_edge_to_edge([tab[0],tab[1]],[a,b],1),
              t = transform_points(tab,m)
            )
              str(lines_to_svg([[t[0],t[1]]],interior_color,width),
                  lines_to_svg([[t[1],t[2]],[t[2],t[0]]],exterior_color,width)
              )      
     ]);

module p_svg(vertices,net_faces,interior_edges, exterior_edges,name,thickness,number_faces,tab_height){
    interior_color ="#00ff00";
    exterior_color ="#000000";
    text_color = "#0000ff";
    iedges = interior_edges;
    oedges=order_edges(exterior_edges);
    cut_edges = 
       tab_height>0 
         ? [for (i=[0:len(oedges)]) 
              if (i % 2 ==1) oedges[i]
           ]
         : oedges;
              
    poly = edges_to_polygon(oedges);
//    echo(poly);
 
    svg=str(
       start_svg(bounding_box_3d(vertices),name,padding=10),
       lines_to_svg(iedges,interior_color,thickness),
       lines_to_svg(cut_edges,exterior_color,thickness),
       tab_height > 0 
          ? tabs_to_svg(oedges,tab_height,interior_color,exterior_color,thickness) 
          : "",
       number_faces
            ? rstr([for (i=[0:len(net_faces)-1])
                      text_to_svg(i+1,centroid(net_faces[i]),color=text_color,text_size=2)
                  ])
            : "" ,
       end_svg()
    );
    echo(svg);
};
