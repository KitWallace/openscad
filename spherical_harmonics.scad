
m=[2,0,1,4,0,4,1,5];

r=0.01;
step=2;

function spherical_r(phi,theta,m) =
     pow(sin(m[0]*phi),m[1])+
     pow(cos(m[2]*phi), m[3])+
     pow(sin(m[4]*theta), m[5])+
     pow(cos(m[6]*theta), m[7]);

function spherical_xyz(phi,theta,r) =
   [r * sin(phi) * cos(theta),
    r * cos(phi),
    r * sin(phi) * sin(theta)
   ];

function spherical(phi,theta,m) =
    spherical_xyz(phi,theta,spherical_r(phi,theta,m));


function space_lat(m,step=5,phi=0) =
   phi <= 180 
     ? concat(space_long(m,step,phi),
              space_lat(m,step,phi+step))
     : [];

function space_long(m,step=5,phi,theta=1) =
   theta <= 360 
     ? concat([spherical(phi,theta,m)],
              space_long(m,step,phi,theta+step))
     : [];

function space_faces(max_phi,max_theta,i=0) =
   i <= max_phi
     ? concat(space_faces_long(max_phi,max_theta,i),
              space_faces(max_phi,max_theta,i+1))
     : [];

function pid(i,j,max_j) =
     max_j * i  + (j % max_j) ;

function square(i,j,max_i,max_j) =
   [pid(i,j,,max_j),
    pid(i+1,j,max_j),
    pid(i+1,j+1,max_j),
    pid(i,j+1,max_j)
   ];

function space_faces_long(max_phi,max_theta,i,j=0) =
   j < max_theta 
     ? concat([square(i,j,max_phi,max_theta)],
          space_faces_long(max_phi,max_theta,i,j+1)
            )
     : [];


points= space_lat(m,step);
faces = space_faces(180/step,360/step);
polyhedron(points,faces);
