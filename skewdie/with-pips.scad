
/* parametric asymmetric trigonal trapezohdron
   geometry from Matlab code by https://twitter.com/etzpcm
   Paul Matthews , Nottingham Uni 
     
     
   pips are placed relative to the face
   
*/

// Initial point
//x0
x0 = 1;
//y0
y0 = 0.7;
//z0
z0 = 0.4;
//scale 
scale=30;
// pip size
pip_size=3;
//pip inset_ratio
pip_inset_ratio=0.5;
//pip offset from face
pip_offset=1.5;
//pip resolution 
pip_resolution=20;
//corner radius
radius =1;
// corner resolution
corner_resolution = 20;

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
      [vertices,faces];

obj=att(x0,y0,z0,scale);
vertices=obj[0];
faces=obj[1];
      
difference() {
    solid(vertices,faces,radius,corner_resolution);
    pips(vertices,faces,pip_size,pip_inset_ratio,pip_offset,pip_resolution) ;
}

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
     
