// create 2D,2.5D amd 3D models based on 

// utility functions  
function m_translate(v) = [ [1, 0, 0, 0],
                            [0, 1, 0, 0],
                            [0, 0, 1, 0],
                            [v.x, v.y, v.z, 1  ] ];
                            
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
function transform(v, m)  = vec3([v.x, v.y, v.z, 1] * m);
                            
function orient_to(centre,normal, p) = m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
                     * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
                     * m_translate(centre);

// solid from path

function circle_points(r, sides,phase=45) = 
    let (delta = 360/sides)
    [for (i=[0:sides-1]) [r * sin(i*delta + phase), r *  cos(i*delta+phase), 0]];

function path_points(step,min=0,max=360,params) = 
    [for (t=[min:step:max-step]) f(t,params)];

function transform_points(list, matrix, i = 0) = 
    i < len(list) 
       ? concat([ transform(list[i], matrix) ], transform_points(list, matrix, i + 1))
       : [];

function tube_points(loop, circle_points,  i = 0) = 
    (i < len(loop) - 1)
     ?  concat(transform_points(circle_points, orient_to(loop[i], loop[i + 1] - loop[i] )), 
               tube_points(loop, circle_points, i + 1)) 
     : transform_points(circle_points, orient_to(loop[i], loop[0] - loop[i] )) ;

function loop_faces(segs, sides, open=false) = 
   open 
     ?  concat(
         [[for (j=[sides - 1:-1:0]) j ]],
         [for (i=[0:segs-3]) 
          for (j=[0:sides -1])  
             [ i * sides + j, 
               i * sides + (j + 1) % sides, 
              (i + 1) * sides + (j + 1) % sides, 
              (i + 1) * sides + j
             ]
        ] ,   
        [[for (j=[0:1:sides - 1]) (segs-2)*sides  + j]]
        )
     : [for (i=[0:segs]) 
        for (j=[0:sides -1])  
         [ i * sides + j, 
          i * sides + (j + 1) % sides, 
          ((i + 1) % segs) * sides + (j + 1) % sides, 
          ((i + 1) % segs) * sides + j
         ]   
       ]  
     ;

module hull_path(path,r) {
    for (i = [0 : len(path) - 1 ]) {
        hull() {
            translate(path[i]) sphere(r);
            translate(path[(i + 1) % len(path)]) sphere(r);
        }
    }
};

function path_points(step,min=0,max=360,params) = 
    [for (t=[min:step:max-step]) f(t,params)];

//  create a polyhedron from a path 

function poly_path(path,r,sides,phase=45,open=false)  =
  let(circle_points = circle_points(r,sides,phase))
  let(tube_points = tube_points(path,circle_points))
  let(loop_faces = loop_faces(len(path),sides,open))
  [tube_points,loop_faces];
        
// 
module graph(path,thickness=0.5,open=0) {
   for(i =[0:len(path)-1-open]) {
      hull() {
          translate(path[i]) circle(d=thickness);
          translate(path[(i+1) % len(path)]) circle(d=thickness);
      }
  }
}

// object trimming

module ground(z=200) {
   translate([0,0,-z]) cube(z*2,center=true);
} 

module sky(z=200) {
   rotate([0,180,0]) ground(z);
}

function f(t,param) = 
    let(p1=param[0],p2=param[1],p3=param[2])
    let(r1=p1[0],a1=p1[1],t1=p1[2])
    let(r2=p2[0]+r1,a2=p2[1],t2=p2[2])
    let(r3=p3[0]+r2,a3=p3[1],t3=p3[2])
    let(X=a1*cos(r1*(t+t1))+a2*cos(r2*(t+t2))+a3*cos(r3*(t+t3)))
    let(Y=a1*sin(r1*(t+t1))+a2*sin(r2*(t+t2))+a3*sin(r3*(t+t3)))
    let(r=sqrt(X*X+Y*Y))
    [X,Y,pow(r/7,3)]
   ;
// function parameters

step=0.5;   // step size in degrees
thickness=0.5; // width of the line 

/*  Engare 1
nodes=4;
cycles=1;
R=nodes/cycles;
link1=[1,10,0];
link2=[R,5.5,0];
link3=[4*R,1.5,0];
links=[link1,link2,link3];

reps=1;
*/
/*  Engare 2
nodes=4;
cycles=1;
R=nodes/cycles;

R=10;

link1=[1,10,0];
link2=[-R,5,0];  // anticlockwise 
link3=[3*R,1.75,0];
links=[link1,link2,link3];

reps=1;

*/

// swirl
cycles=1;
nodes=6;

R=6;
link1=[1,8,0];
link2=[-R,5,0];
link3=[5*R,3*0.75,10];
links=[link1,link2,link3];

reps=1;

/*
nodes=1;
cycles=1;
R=nodes/cycles;

R=1;

link1=[1,10,0];
link2=[R,7,0];  // anticlockwise 
link3=[3*R,0,0];
links=[link1,link2,link3];

reps=1;
*/
render="2D";
method="poly";
$fn=12;

// overall scale
Scale=2;
path = path_points(step,0, 1*cycles*360,links);
color("red")
scale(Scale)
if (render=="2D") {
     for(rep=[0:1:reps-1]) {
         pmax= 360 / nodes;
         rotate([0,0,pmax*rep/reps])
         graph( path,thickness);
     }
} 

else if (render=="2.5D") {    
    height=2;
    linear_extrude(height=height)
       for(rep=[0:1:reps-1]) {
           pmax= 360 / nodes;
           rotate([0,0,pmax*rep/reps])
           graph(path, thickness);
    }
} 

else if (render=="3D")
   if( method=="hull") 
     if(reps==1) {
       hull_path(path,thickness);
     }
     else {   
       for(rep=[0:1:reps-1]) 
          rotate([0,0,pmax*rep/reps])
             hull_path(path,thickness);
        }
   else if(method=="poly") {
       Sides=12;  // Sides of rope - must be a divisor of 360
       Phase = 45;  // phase angle for profile (maters for low Sides
       Open = false;   // true if knot is open or partial
       Start=0; End=cycles*360;  // change for partial path  
       if(reps==1) {
            poly= poly_path(path,thickness,Sides,Phase,Open);
            polyhedron(poly[0],poly[1]);
        }
        else {   
           poly= poly_path(path,thickness,Sides,Phase,Open);
           for(rep=[0:1:reps-1]) {
               pmax= 360 / nodes;
               rotate([0,0,pmax*rep/reps])
               polyhedron(poly[0],poly[1]);
          }  
      }
  }

