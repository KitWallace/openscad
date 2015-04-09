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

function rr(a,face,edges,i=0)  =
// apply r to a sequence of edges
     i < len(edges)
       ? rr(a,r(a,face,edges[i]),edges,i+1) 
       : face;

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
     r(a,d_tri);   // finally rotate tri about the common edge

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
     turtle_path(flatten([for(i=[1:sides]) [length,["L",359.99999/sides]]]));

function rhomboid_face(length,angle) =
     turtle_path(flatten([for(i=[1:2]) [length,["L",angle],length,["L",180-angle]]]));


// rendering  

colors=["green","blue","red","fuchsia",
        "Hotpink","silver","teal","purple",
        "black","white","grey","orange",
        "paleGreen","darkred","greenyellow"
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
   
// platonic solid functions
function S_net(length,a) =
   let(base = [[0,0,0],[length,0,0],[length,length,0]],
     bs = [for (i=[0:2]) r(a,base,i)])
   dflatten([base,bs]);

function T_net(length,a) =
   let(base = [for (i=[0:2])  // anticlockwise order 
          [ length * cos(i*120), length*sin(i*120),0]] ,
     bs = [for (i=[0:2]) r(a,base,i)])
   dflatten([base,bs]);

function C_net(length,a) =
   let(base = [for (i=[0:3])  // anticlockwise order 
          [ length * cos(i*90), length*sin(i*90),0]] ,
       bs = [for (i=[0:3]) r(a,base,i)],
       top = r(a,bs[0],2))
   dflatten([base,bs,top]);
   
function O_net(length,a) =
   let(base = [for (i=[0:2])  // anticlockwise order 
          [ length * cos(i*120), length*sin(i*120),0]] ,
     bs = [for (i=[0:2]) r(a,base,i)],
     sa= r(a,bs[2],2),
     sb= r(a,bs[1],2),
     sc= r(a,bs[1],1),
     sd= r(a,sc,2))        
   dflatten([base,bs,sa,sb,sc,sd]); 


function dodecahedron_half(a,base) =
  dflatten([base,[for (i=[0:4]) r(a,base,i)]],2);
     
function D_net(length,a) =
  let(base = 
       [for (i=[0:4])  // anticlockwise order 
          [ length * cos(i*72), length*sin(i*72),0]] , 
      bottom_half = dodecahedron_half(a,base),
      top_half= dodecahedron_half(a,rr(a,base,[0,2,3])))
  dflatten([bottom_half,top_half],2);
     
function icosa_strip(base,a,n) =
   n==0 
      ? []
      :  concat( 
           [base,r(a,base,2),r(a,base,0), r(a,r(a,base,0),2)],
            icosa_strip(r(a,r(a,base,1),2),a,n-1)
         );
           
function I_net(length,a) =
   let(base = [for (i=[0:2])  // anticlockwise order 
          [ length * cos(i*120), length * sin(i*120), 0]]) 
     icosa_strip(base,a,5); 

// bipyramids
function TDi_net(length,a,b) =
   let(base = [for (i=[0:2])  // anticlockwise order 
          [ length * cos(i*120), length*sin(i*120),0]] ,
     
     sa= r(a,base,1),
     sb= r(a,base,2),
     sc =r(b,base,0),
     sd = r(a,sc,1),
     se = r(a,sc,2))        
   dflatten([base,sa,sb,sc,sd,se]); 
     
function PDi_net(length,a,b) =
   let(base = [for (i=[0:2])  // anticlockwise order 
          [ length * cos(i*120), length*sin(i*120),0]] ,
     
     ta= r(a,base,1),
     tb= r(a,ta,2),
     tc =r(a,tb,2),
     td =r(a,tc,2),
   
     ba = r(b,base,0),
     bb = r(a,ba,2),
     bc = r(a,bb,1),
     bd = r(a,bc,1),
     be = r(a,bd,1)
   )        
   dflatten([base,ta,tb,tc,td,ba,bb,bc,bd,be]); 
     
   
// archimedean solids

function aC(length,a) =
   let(sq= regular_face(length,4),
       tri= regular_face(length,3),
   t1= rp(a,sq,2,tri),
   t2 =rp(a,sq,1,tri),
   t3 =rp(a,sq,0,tri),
   s1= rp(a,t2,2,sq),
   s2= rp(a,t2,1,sq),
   t4= rp(a,s1,2,tri),    
   t5= rp(a,s2,2,tri),   
   s3= rp(a,t5,1,sq),
   t6= rp(a,s3,2,tri),
   s4= rp(a,t4,2,sq),  
   s5= rp(a,t4,1,sq),  
   t7= rp(a,s5,1,tri),  
   t8= rp(a,s5,3,tri) 

       )
   [sq,t1,t2,t3,s1,s2,t4,t5,s3,t6,s4,s5,t7,t8];

function tO(length,a,b) =
   let(sq= regular_face(length,4),
       hex=regular_face(length,6)
   ,hex1=hex,
   ,hex2=rp(a,hex1,1,hex)
   ,hex3=rp(a,hex1,3,hex) // bad
   ,hex4=rp(a,hex1,5,hex)
   ,sq1 =rp(b,hex1,0,sq)
   ,sq2= rp(b,hex1,2,sq)
   ,sq3= rp(b,hex1,4,sq)   
       
   ,hex5=rp(b,sq1,2,hex) 
   ,hex6=rp(b,sq2,2,hex)
   ,hex7=rp(b,sq3,2,hex)
   ,sq4= rp(b,hex2,3,sq)
   ,sq5= rp(b,hex3,3,sq)
   ,sq6= rp(b,hex4,3,sq)
       
   ,hex8=rp(a,hex5,3,hex) 
 
       )
   [hex1,hex2,hex3,hex4,hex5,hex6,hex7,hex8, sq1,sq2,sq3,sq4,sq5,sq6];
   
function daC(length,a) =
   let(rhoml = rhomboid_face(length,70+32/60),
       rhomr = rhomboid_face(length,180-(70+32/60)),
   r1=rhomr
   ,r2=rp(a,r1,2,rhomr)
   ,r3=rp(a,r2,1,rhomr)
   ,r4=rp(a,r3,2,rhoml)
   ,r5=rp(a,r4,3,rhoml)
   ,r6=rp(a,r5,2,rhomr)
   ,r7=rp(a,r6,1,rhomr)
   ,r8=rp(a,r7,2,rhoml)
   ,r9=rp(a,r8,3,rhoml)
   ,r10=rp(a,r9,2,rhomr)
   ,r11=rp(a,r10,1,rhomr)
   ,r12=rp(a,r11,2,rhoml)
    
   )
   [r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12];

dihedral_angles = [
    ["T", 70.53],
    ["C",90],
    ["O",109.47],
    ["D",116.57],
    ["I",138.19],
    ["TDi",70.53,2*70.53],
    ["PDi",138,75] ,
    ["aC",125.264],
    ["tO",109+28/60,125+16/60],
    ["daC",120]
   ];             

/*
$fn=4; 
$t=0.2;    // remove to animate
complete=ramp($t,0.04) ;  // 0 .. 1
dihedral_angle_a =  find("tO",dihedral_angles)[1];
dihedral_angle_b =  find("tO",dihedral_angles)[2];
a= 180 - (180 - dihedral_angle_a)*complete;  
b= 180 - (180 - dihedral_angle_b)*complete;  
      
net = tO(length,a,b);
// echo(net);
scale(scale) show_faces(net);

*/
/*
f = rhomboid_face(20,70+32/60);
translate([100,0,0]) show_face(f);
f1= f; //r(150,f,2);
 rf=rp(150,f1,2,f,debug=true);
 echo(rf);
color("grey") show_face(f1);
color("red") show_face(rf[0]);
color("green",0.5) show_face(rf[1]);
color("blue")  show_face(rf[2]);
color("pink",0.5) show_face(rf[3]);
 color("gold") show_face(rf[4]);

*/

$fn=4; 
$t=0.6;    // remove to animate
complete=ramp($t,0.04) ;  // 0 .. 1
dihedral_angle_a =  find("daC",dihedral_angles)[1];
a= 180 - (180 - dihedral_angle_a)*complete;  
      
net = place(daC(length,a),6);
// echo(net);
scale(scale) show_faces(net);


/*
dihedral_angle_a =  find("TDi",dihedral_angles)[1];
dihedral_angle_b =  find("TDi",dihedral_angles)[2];
a= 180 - (180 - dihedral_angle_a)*complete;  
b= 180 - (180 - dihedral_angle_b)*complete;  

net = TDi_net(length,a,b);
echo(len(net),net);
show_faces(net);
   
*/
