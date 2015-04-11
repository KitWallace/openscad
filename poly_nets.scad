/*
   folding nets of solids
   kit wallace
   

*/
//thickness of 'paper'
thickness=0.5;
// length of side
length=10;

//quality of curves
steps=20;
scale=1;


// for flattening list and lists of lists

function depth(a) =
   len(a)== undef 
       ? 0
       : 1+depth(a[0]);

function flatten(l) = [ for (a = l) for (b = a) b ] ;

function dflatten(l,d=2) =
// hack to flattened mixed list and list of lists
   flatten([for (a = l) depth(a) > d ? dflatten(a, d) : [a]]);

// dictionary shorthand assuming present
function find(key,array) =  array[search([key],array)[0]];
   
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
                            
function m_to(centre,normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal.y, normal.x)]) 
    * m_translate(centre);   

function m_rotate_to(normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal.y, normal.x)]);  
  
function m_from(centre,normal) = 
      m_translate(-centre)
    * m_rotate([0, 0, -atan2(normal.y, normal.x)]) 
    * m_rotate([0, -atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]); 

function m_rotate_about_line(a,v1,v2) =
      m_from(v1,v2-v1)*m_rotate([0,0,a])*m_to(v1,v2-v1);

function vec3(v) = [v.x, v.y, v.z];
function m_transform(v, m)  = vec3([v.x, v.y, v.z, 1] * m);
 
function face_transform(face,m) =
     [ for (v = face) m_transform(v,m) ];

function rotate_about_edge(a,face,edge) =
     let (v1 = face[edge], v2= face[(edge+1) %len(face)])
     let (m = m_rotate_about_line(a,v1,v2))
     face_transform(face,m);

// face operations
     
function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];
function centre(points) = 
      vsum(points) / len(points);
     
function unitv(v)=  v/ norm(v);

function normal(face) =
     let (n=orthogonal(face[0],face[1],face[2]))
     - n / norm(n);

function signx (x) =
     x==0 ? 1 : sign(x);
     
function angle_between(u, v, n) = 
// protection against inaccurate computation
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     let (sign = signx(n* cross(u,v)))
     
     sign*a;

function orthogonal(v0,v1,v2) =  cross(v1-v0,v2-v1);
   
function reverse(l,shift=0) = 
     [for (i=[0:len(l)-1]) l[(len(l)-1-i + shift)%len(l)]];   
                        
function r(a,face,edge=0) = 
// replicate the face rotated about edge so the two faces have an internal angle of a
// vertices are reordered so that the edge of rotation is edge 0 in the rotated face 
// and vertices are ordered anticlockwise   
     reverse(rotate_about_edge(a,face,edge),shift=edge+2);

function face_edge(face,edge) =
    [face[edge], face[(edge+1) %len(face)]];

function line(edge) = edge[1]-edge[0];
   
function rp(a,sq,sq_edge,tri,tri_edge=0) =
//  tri is the face to be placed on the sq_edge of sq at angle a
     let (sq_normal= normal(sq),
          sq_edgev=face_edge(sq,sq_edge),
          sq_corner=sq_edgev[0],
          tri_edgev=face_edge(tri,tri_edge), 
          tri_corner=tri_edgev[0],
          ma= m_translate(-tri_corner),  // make edge[0] the origin
          a_tri = face_transform(tri,ma),
          mb = m_rotate_to(-sq_normal),
          b_tri= face_transform(a_tri,mb),  // rotate tri so plane is paralledl to sq
          b_tri_corner = face_edge(b_tri,tri_edge)[0],
          offset = sq_corner - b_tri_corner,
          mc = m_translate(offset),      
          c_tri= face_transform(b_tri,mc), // translate so tri-edge[0] coincides with sq_edge[0]
          c_tri_edgev= face_edge(c_tri,tri_edge),      
          line_tri=line(c_tri_edgev),
          line_sq=line(sq_edgev),
          angle = angle_between(line_tri,line_sq,sq_normal),  // compute angle between edges
          md =  m_rotate_about_line(angle, sq_corner, sq_corner +sq_normal), 
          d_tri= face_transform(c_tri,md) //rotate about edge[0] normal to the plane of sq
          )
    r(a,d_tri,tri_edge);   // finally rotate tri about the common edge
 //   [a_tri,b_tri,c_tri,d_tri, r(a,d_tri,tri_edge),angle]
 
     ;

function place(faces,face_i) =
// place the net so that face_i is on the xy plane
   let (pface=faces[face_i])
   let (n = normal(pface), c=centre(pface))
   let (m=m_from(c,-n))
   [for(face=faces) face_transform(face,m)]
;
   
// use turtle geometry to create shapes defined by length of side and turning angle
function turtle_path(steps,pos=[0,0,0],dir=0,i=0,closed=false) =
   i <len(steps)
      ? let(step = steps[i],
          command = step[0] != undef ? step[0] : "F",
          p = step[0] == undef ? step : step[1])
          command=="L" 
            ? turtle_path(steps,pos,dir+p,i+1)
            : command=="R"
               ? turtle_path(steps,pos,dir-p,i+1)
               : command=="F" 
                 ? let (newpos = pos + p * [cos(dir), sin(dir),0])
                   concat([pos],turtle_path(steps,newpos,dir,i+1)) 
                 : turtle_path(steps,newpos,dir,i+1) // ignore
      : closed ? [pos] : [] ;   

function regular_face(length,sides) =
     turtle_path(flatten([for(i=[1:sides]) [length,["L",360/sides]]]));

function rhomboid_face(length,angle) =
     turtle_path(flatten([for(i=[1:2]) [length,["L",angle],length,["L",180-angle]]]));


// rendering  

colors=["green","blue","red","fuchsia",
        "Hotpink","aqua","teal","purple",
        "black","tan","gold","orange",
        "paleGreen","slateblue","greenyellow",
     
];

module show_edge(e,r=2) {
     translate(e[0]) sphere(r*1.5);
     translate(e[1])  sphere(r);
}

module show_face(s,t=thickness,edge=false) {
// render (convex) face by hulling spheres placed at the vertices
    hull()
    for (i=[0:len(s) -1])
       translate(s[i]) sphere(t/2);     
    if(edge) show_edge([s[0],s[1]]);
} 

module show_faces(faces,t=thickness) {
   for (i=[0:len(faces)-1]) {
      face=faces[i];
      color(colors[i])
       show_face(face,t=thickness);
   }
  
}
       
function ramp(t,dwell) =
// to shape the animation to give a dwell at begining and end
   t < dwell 
       ? 0
       : t > 1 - dwell 
         ? 1
         :  ( t-dwell) /(1 - 2 * dwell);
   
function tface(faces,hinges,current,step) =
     let(side = step[0],   // step
        face_spec = step[1],
        face = face_spec[0] == undef ? face_spec : face_spec[0],
        face_side = face_spec[0] == undef ? 0 : face_spec[1],
        a = step[2] == undef ? hinges[0] : hinges[step[2]])
     rp(a,current,side,faces[face],face_side); 
                    
function rrp(faces,hinges,tree,current) =
    let(root= tree[0])
    let (troot = current == undef ? faces[root] : tface(faces,hinges,current,root))
    concat ( [troot],
             len(tree) > 1
             ?[for (i=[1:len(tree) -1])
              let(step = tree[i])
              depth(step) == 1   //  transformation
                  ? [tface(faces,hinges,troot,step)]
                  : rrp(faces,hinges,step,troot)  // subtree
              ]
             :[]
            );           
            
function fold(name,faces,dihedral_angles,net) =
     [name,faces,dihedral_angles,net];
     
function fold_name(f) = f[0];
function fold_faces(f) = f[1];
function fold_dihedral_angles(f) = f[2];
function fold_net(f) = f[3];

module fold_render(fold, complete) {
   hinges = [for (angle = fold_dihedral_angles(fold) ) 180 -(180 - angle)*complete];
   faces = dflatten(rrp(fold_faces(fold),hinges,fold_net(fold)));
   echo(len(faces),faces);
   show_faces(faces);   
}

function D_net(length) =
   let (p=0)
   fold (
        name = "Dodecahedron",
        faces= [regular_face(length,5)],
        dihedral_angles=[125.264],
        net =  [p,[0,p],[1,p],[2,p],[3,p],
                  [[4,p], [[2,p], [[3,p],[1,p],[2,p],[3,p],[4,p]]]]]
        );
 
function I_net(length) =
   let (t=0)
   fold (
        name = "Icosahedron",
        faces= [regular_face(length,3)],
        dihedral_angles=[138 +11/60],
        net = [t,[0,t],[[1,t],[2,t],[[1,t],[1,t],[[2,t],[2,t], [[1,t],[1,t],[[2,t],[2,t]]]]]], [[2,t],[1,t],[[2,t], [2,t],[[1,t],[1,t],[[2,t],[2,t]]]]]] 
        );

function T_net(length) =
   let (tri=0)
   fold (
        name = "Tetrahedron",
        faces= [regular_face(length,3)],
        dihedral_angles=[70+32/60],
        net =  [tri,[0,tri],[1,tri],[2,tri]]
        );

function C_net(length) =
   let (sq=0)
   fold (
        name = "Cube",
        faces= [regular_face(length,4)],
        dihedral_angles=[90],
        net =  [sq, [0,sq], [1,sq] , [2,sq], [[3,sq],[2,sq] ]] 
        );

function O_net(length) =
   let (tri=0)
   fold (
        name = "Octahedron",
        faces= [regular_face(length,3)],
        dihedral_angles=[109+28/60],
        net =  [tri, [0,tri] , [[1,tri],[2,tri], [[1,tri],[2,tri]]],[[2,tri], [2,tri]]] 

        );
function tC_net(length) =
   let (oct=0,tri=1)
   fold (
        name = "Truncated Cube",
        faces= [regular_face(length,8),regular_face(length,3)],
        dihedral_angles=[90, 125.264],
        net = [oct,[0,oct],
                   [1,tri,1],
                   [[2,oct],[3,tri,1],[5,tri,1],
                                    [[4,oct],[3,tri,1],[5,tri,1]]],
                   [3,tri,1],
                   [4,oct],
                   [5,tri,1],
                   [6,oct],
                   [7,tri,1]
               ]           

        );
        
function aC_net(length) =
   let (tri=0,sq=1)
   fold (
        name = "Cubeoctahedron",
        faces= [regular_face(length,3),regular_face(length,4)],
        dihedral_angles=[125.264],
        net = [tri,[[0,sq],[0,tri],[2,tri]],
                   [[1,sq],[[2,tri],[[1,sq], [2,tri]]]],
                   [[2,sq],[[2,tri],[2,sq],[[1,sq],[1,tri],[3,tri]]]]
              ]
        );
        
function daC_net(length) =
    let(a=0,b=1)
    fold(
        name="Rhombic Dodecahedron",
        faces =[rhomboid_face(length,109+28/60),rhomboid_face(length,180 - (109+28/60))],
        dihedral_angles=[120],
        net= [ a,[[2,a],[[1,a], [[2,b],  [[3,b],[[2,a], [[1,a], [[2,b], [[3,b], [[2,a],[[1,a],[2,b]]]]]]]]]]]]

        );

function tO_net(length) =
    let(sq=0,hex=1)
    fold(
        name="Rhombic Dodecahedron",
        faces =[regular_face(length,4),regular_face(length,6)],
        dihedral_angles=[125+16/60,109+28/60],
        net= 
        [ hex, [0,sq],
               [[1,hex],[5,sq], [[4,hex],[1,sq]]],
               [3,hex],
               [[5,hex], [1,sq], [4,hex], [[2,hex],[5,sq], [[4,hex],[1,sq]]]]
        ]
        );

function DP3_net (length) =
    let(tri=0)
    fold(
       name="Triangular dipyramid",
       faces= [regular_face(length,3)],
       dihedral_angles =[70.53,2*70.53],
       net= [tri, [[1,tri,0], [1,tri,0]],[[2,tri,1], [[1,tri,0],[2,tri,0]]]]
    );

function DP5_net(length) =
     let (tri=0)
     fold(
         name = "Pentagonal Dipyramid",
         faces= [regular_face(length,3)],
         dihedral_angles=[138,75],
         net= [tri, [[2,tri], [[2,tri],[[2,tri], [2,tri] ]]], [[1,tri,1], [[1,tri], [[2,tri], [[2,tri], [2,tri]]]]]]
         
     );
function test(length) =
    let (tri=0)
   fold (
        name = "test",
        faces= [regular_face(length,3)],
        dihedral_angles=[109+28/60],
        net = [tri,[0,tri],[1,tri], [[2,tri], [[2,tri],[1,tri]]]] 
//        net = [tri,[1,tri],[2,tri], [[0,tri],[1,tri]]]
        );
        

$t=1;
pfold = DP5_net(length);
echo(fold_net(pfold));
fold_render(pfold,$t);


       




