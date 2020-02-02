
/* parametric asymmetric trigonal trapezohdron
   geometry from Matlab code by https://twitter.com/etzpcm
   Paul Matthews , Nottingham Uni 
   
   inspired by Henry Segerman's skew dice
     
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
pip_size=5;
//pip spacing
pip_spacing=10;
//pip resolution 
pip_resolution=5;
//pip alignment - angle of alignment within face 
pip_alignment=50;
//corner radius
corner_radius =5;
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

vertices = [for (v=unit_vertices) v* scale];
placed_vertices = place(vertices,faces,0);   
dice(placed_vertices,faces,corner_radius,pip_size,pip_spacing,pip_alignment) ;


module dice(vertices,faces,radius,size,spacing,alignment) {
   difference() {
       if(radius==0)
           polyhedron(vertices,faces);
       else hull() 
             for (v = vertices) translate(v) sphere(radius,          $fn=corner_resolution);

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

function place(vertices,faces,f) =
// place on nomated face or largest face for printing
   let (face= faces[f])
   let (points =[for (v=face) vertices[v]])
   let (n = normal(points), c=centroid(points))
   let (m=m_from(c,-n))
   [for (v=vertices) m_transform(v, m) ];

function m_from(centre,normal) = 
      m_translate(-centre)
    * m_rotate([0, 0, -atan2(normal.y, normal.x)]) 
    * m_rotate([0, -atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]); 

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

 
