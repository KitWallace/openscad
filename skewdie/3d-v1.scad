
/* parametric asymmetric trigonal trapezohdron
   geometry from Matlab code by https://twitter.com/etzpcm
   Paul Matthews , Nottingham Uni 
     
*/

// Initial point
//x0
x0 = 1;
//y0
y0 = 0.9;
//z0
z0 = 0.7;
//scale 
scale=30;
// pip size
pip_size=3;
//pip spacing
pip_spacing=9;
//pip resolution 
pip_resolution=5;
//pip alignment - angle of alignment within face 
pip_alignment=35;
//corner radius
radius =0;
// corner resolution
corner_resolution = 5;

function end() = "end";

m1= [[1,0,0], [0,-1,0], [0,0,-1]];   // 180 rotation about x axis
t=2*180/3;
c=cos(t);
s=sin(t);
m2= [ [c,s,0], [-s,c,0], [0,0,1]];   // 120 rotation about z axis

p0= [x0,y0,z0];  
//Ensure 4 face points are coplanar 
z = z0*(-s*x0+(c-1)*y0)*x0/((c-1)*x0+s*y0)/y0;

p1= m2 * p0;
p2= m2 * p1;
p3= m1 * p0;
p4= m2 * p3;
p5= m2 * p4;
p6 = [0,0,z];
p7 = [0,0,-z];
unit_vertices = [p0,p1,p2,p3,p4,p5,p6,p7];
vertices = [for (v=unit_vertices) v* scale];

// faces 2 and 3 reversed to get all faces with the same orientation
// faces reordered so face[i] has i+1 pips

faces = [[0,3,1,6], 
         [5,7,3,0],  
         [2,5,0,6],  
         [1,3,7,4], 
         [4,2,6,1], 
         [4,7,5,2], 
        ];

pips = [  
         [[0,0]],
         [[-1,1],[1,-1]],
         [[-1,-1],[0,0],[1,1]],
         [[-1,1],[1,1],[1,-1],[-1,-1]],
         [[-1,1],[1,1],[1,-1],[-1,-1],[0,0]],
         [[-1,1],[1,1],[1,-1],[-1,-1],[0,1],[0,-1]]
       ];
       
dice(vertices,faces,radius,pip_size,pip_spacing,pip_alignment) ;


module dice(vertices,faces,radius,size,spacing,alignment) {
/*
    base = [for (v = faces[1]) vertices[v]];
    base_centre = centroid(base);
    base_normal = normal(base);
    echo(base,base_centre,base_normal);
    orient_to( [0,0,0], base_normal)
*/
      difference() {
       if(radius==0)
           polyhedron(vertices,faces);
       else hull() 
             for (v = vertices) translate(v) sphere(radius,$fn=corner_resolution);

       for (i =[0:len(faces)-1])  {
           face=faces[i];
           facep = [for (p = face) vertices[p]];
           center=centroid(facep);
           normal=normal(facep);
           orient_to(center,normal) 
               for(place = pips[i]) 
                   rotate([0,0,alignment])
                    translate([place[0]*spacing,place[1]*spacing,radius+2*size/5])
                    sphere(size,$fn=pip_resolution);
       }
     }
 }
function centroid(points) = 
      vsum(points) / len(points);

function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];

function orthogonal(v0,v1,v2) =  cross(v1-v0,v2-v1);

function normal(face) =
     let (n=orthogonal(face[0],face[1],face[2]))
     - n / norm(n);
            
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

module orient_from(centre, normal) {   
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      translate(centre)
      children();
}
