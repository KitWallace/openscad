//include <../lib/basics.scad>
include <../lib/polyfns.scad>
include <../lib/miller.scad>

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
