
/* parametric asymmetric trigonal trapezohdron
   geometry from Matlab code by https://twitter.com/etzpcm
   Paul Matthews , Nottingham Uni 
     
   net
   
*/
include <../lib/basics.scad>
include <../lib/polyfns.scad>
include <../lib/netfns.scad>

// Initial point
//x0
x0 = 1;
//y0
y0 = 0.7;
//z0
z0 = 0.4;
//scale 
scale=8;
// pip size
pip_size=5;
// pip_inset
pip_inset_ratio = 0.4;
// line width
line_width=0.1;

// end of parameters

function att(x0,y0,z0,scale) =
   let(m1= [[1,0,0], [0,-1,0], [0,0,-1]],   // 180 rotation about x axis
      t=2*180/3,
      c=cos(t),
      s=sin(t),
      m2= [ [c,s,0], [-s,c,0], [0,0,1]],   // 120 rotation about z axis
      p0= [x0,y0,z0],  
//Ensure 4 face points are coplanar 
      z = z0*(-s*x0+(c-1)*y0)*x0/((c-1)*x0+s*y0)/y0,
      p1= m2 * p0,
      p2= m2 * p1,
      p3= m1 * p0,
      p4= m2 * p3,
      p5= m2 * p4,
      p6 = [0,0,z],
      p7 = [0,0,-z],
      unit_vertices = [p0,p1,p2,p3,p4,p5,p6,p7],
      vertices = [for (v=unit_vertices) v* scale],
   
// faces 2 and 3 reversed fro mMathews to get all faces with the same orientation
// faces reordered so face[i] has i+1 pips 

     faces = 
       [[0,3,1,6], 
         [5,7,3,0],  
         [2,5,0,6],  
         [1,3,7,4], 
         [4,2,6,1], 
         [4,7,5,2], 
        ])
      ["Att",vertices,faces];
        
function face(vertices,face) =
   [for (i=face) vertices[i] ];
      
function pip_points(face,r) =
  let (p0=centroid(face))
  let (corners=
     [for (p=face) point_between(p0,p,r)])
  let (edges=
     [for (i=[0:len(face)-1])
          point_between(corners[i],corners[(i + 1) % len(face)],0.5)])
  flatten([[p0],corners,edges]);
     
function svg_pips(faces,pip_size,pip_inset_ratio) =  
    let (pips=[[0],[1,3],[1,0,3],[1,2,3,4],[0,1,2,3,4],[1,2,3,4,5,7]])

    rstr([for (i =[0:len(faces)-1]) 
           let(face=faces[i])
           let(norm = normal(face))
           let(pips_p = pip_points(face,pip_inset_ratio))
           let(face_pips = pips[i])
           rstr([for (j=face_pips)
                 circle_to_svg(pips_p[j],pip_size)] )     
     ]);   

module p_svg(obj,faces,width,pip_size,pip_inset_ratio) {
    exterior_color ="#000000";
    interior_color ="#000000";
    edges = net_edges(faces);
    vertices = flatten(edges);
    iedges = interior_edges(edges);
    eedges = exterior_edges(edges);
    svg=str(
       start_svg(vertices,p_name(obj)),
       path_to_svg(iedges,interior_color,width),
       path_to_svg(eedges,exterior_color,width),
       svgpips = svg_pips(faces,pip_size,pip_inset_ratio),
       end_svg()
    );
    echo(svg);
};


obj=att(x0,y0,z0,scale);
net=p_create_net(obj);
start=net[0][0];
faces = faces_to_origin(obj,scale);  // in face index order
nfaces = net_render(net,faces,0,start);
sorted_faces = quicksort_kv([for (f=dflatten(nfaces,3)) [f[0][0][0],f[1]]]); 
net_faces = slice(sorted_faces,1);
p_svg(obj,net_faces,line_width,pip_size,pip_inset_ratio);

    edges = p_edges(obj);
    angles = [for (edge = edges)
              dihedral_angle_index(edge,p_faces(obj),p_vertices(obj))
           ];
    echo ("Dihedral angles",quicksort_kv(angles));
