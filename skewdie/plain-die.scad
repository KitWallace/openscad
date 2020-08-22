
/* parametric asymmetric trigonal trapezohdron
   geometry from Matlab code by https://twitter.com/etzpcm
   Paul Matthews , Nottingham Uni 
     
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
//corner radius
radius =2;
// corner resolution
corner_resolution = 15;


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

dice(vertices,faces,radius) ;

module dice(vertices,faces,radius) {
       if(radius==0)
           polyhedron(vertices,faces);
       else hull() 
             for (v = vertices) 
                  translate(v) 
                     sphere(radius, $fn=corner_resolution);    
 };
 
