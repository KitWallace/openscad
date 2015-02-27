/*
   turtle simulation 
   
   Kit Wallace 
   
   Code licensed under the Creative Commons - Attribution - Share Alike license.

  The project is documented in my blog 
   http://kitwallace.tumblr.com/tagged/turtle
  
   using open knot code to render in 3D - much faster  but no rounded corners
   
   uses concat, list comprehension, let 
*/

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

// matrix to orient from centre in direction normal
function m_to(centre,normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
    * m_translate(centre);  

function flatten(l) = [ for (a = l) for (b = a) b ] ;

function ssum(list,i=0) =  
      i < len(list)
        ?  (list[i] + ssum(list,i+1))
        :  0;

function hadamard(a,b) =
       len(a)==len(b)
           ?  [for (i=[0:len(a)-1]) a[i]*b[i]] 
           :  [];   

function scale_3(list,scale) =
   let (mscale = 
        len(scale) == 3 
          ? scale : [scale,scale,scale])
   [for (p=list) hadamard(p,mscale)] ;
       
// generate points for the profile as an ellipse
// with radius r, eccentricity e 
           
function ellipse_points(r, sides, e=1, theta=0) = 
   [for (i=[0:sides-1]) [r * e * sin(i*360/sides + theta), r *  cos(i*360/sides +theta), 0]];

// generate the points along the centre of the tube
function function_points(step,min=0,max=360) = 
   [for (t=[min:step:max]) f(t)];

function path_length(points) =
    ssum([for (i=[0:len(points)-2]) norm(points[i+1] - points[i])]);

// generate all points on the tube surface  
function tube_points(loop_points,profile_points,closed) = 
   closed 
    ?  let (n = len(loop_points)-1 )// ignore last point
       [for (i=[0:n-1])   
        let (n1=loop_points[i + 1] - loop_points[i])
        let (n0=loop_points[i]-loop_points[(i-1+n) % n ])
        let (m = m_to(loop_points[i], (n0+n1)))
        for (p = profile_points) 
           transform(p,m)
       ]
    : concat(
       let (n1=loop_points[1] - loop_points[0])
       let (m = m_to(loop_points[0], n1))
       [for (p = profile_points) 
          transform(p,m)],
       [for (i=[1:len(loop_points)-2])   
       let (n1=loop_points[i + 1] - loop_points[i])
       let (n0=loop_points[i]-loop_points[i-1])
       let (m = m_to(loop_points[i], (n0+n1)))
       for (p = profile_points) 
          transform(p,m)
      ] ,
       let (last=len(loop_points) - 1)
       let (n1=loop_points[last] - loop_points[last-1])
       let (m = m_to(loop_points[last], n1))
       [for (p = profile_points) 
          transform(p,m)]
     )
       
;
// generate the faces of the tube surface 
function loop_faces(segs, sides, closed) =  
   closed
       ? 
        let (n = segs-1 )// ignore last point
        [for (i=[0:n])       
           for (j=[0:sides -1])  
            [ i * sides + j, 
              i * sides + (j + 1) % sides, 
             (i + 1) % n  * sides + (j + 1) % sides, 
             (i + 1) % n  * sides + j
             ]
          ]   
       : concat(
         [[for (j=[sides - 1:-1:0])    // one end
              j 
         ]], 
         [for (i=[0:segs-2])           // body
          for (j=[0:sides -1])  
             [ i * sides + j, 
               i * sides + (j + 1) % sides, 
              (i + 1) * sides + (j + 1) % sides, 
              (i + 1) * sides + j
             ]
          ] ,   
          [[for (j=[0:1:sides - 1])   // other end
             (segs-1)*sides  + j]
          ])
     ;
   
// create a knot from a sequnce of path points 
// and cross_section profile points as a polyhedron
module path_knot(loop_points,profile_points)  {
    closed = loop_points[0] == loop_points[len(loop_points)-1]; 
    tube_points = tube_points(loop_points,profile_points,closed);
    loop_faces = loop_faces(len(loop_points),len(profile_points),closed);
    polyhedron(points = tube_points, faces = loop_faces);
}; 

function turtle_path(steps,pos=[0,0,0],dir=0,i=0) =
   i <len(steps)
      ? let(step = steps[i], command=step[0])
        command=="F"
          ? let (distance = step[1])
            let (newpos = pos + distance* [cos(dir), sin(dir),0])
            concat([pos],turtle_path(steps,newpos,dir,i+1)) 
          : command=="L" 
            ?  let (angle = step[1])
               turtle_path(steps,pos,dir+angle,i+1)
            : command=="R"
               ? let (angle = step[1])
                 turtle_path(steps,pos,dir-angle,i+1)
               : turtle_path(steps,pos,dir,i+1)
      : [pos]
;
         
module turtle (steps, i=0, corner=true) {
  if ( i < len(steps)) {
   step = steps[i];
   command=step[0];
      
   if(command=="F") {
       distance = step[1];
       width=step[2];
       translate([distance/2,0]) 
            square([distance,width],center=true);
       translate([distance,0]) 
         turtle(steps,i+1);
      }
   else if (command=="L") {
      angle=step[1];
      width=step[2];
      if (corner) circle(width/2);
      rotate([0,0,angle])
         turtle(steps,i+1);
      }
   else if (command=="R") {
      angle=step[1];
      width=step[2];
      if (corner) circle(width/2);
      rotate([0,0,-angle])
         turtle(steps,i+1);
      }
   else
      echo("unknown command" ,step);
  }
};

//  basic poly 
function poly(side,angle,steps,width=1) =
   flatten(
    [for (i=[0:steps-1])
     [ ["F",side,width],["R",angle,width]]
    ]);

function poly2(side,angle,steps,width=1) =
   flatten(
    [for (i=[0:steps-1])
     [ ["F",side,width],["R",angle,width],["F",side,width],["R",2*angle,width] ]
    ]);

function spi(side,side_inc,angle,width=1,steps) =
   steps == 0
      ? []
      : concat( [["F",side,width]],
                [["L",angle,width]] ,
                spi(side+side_inc,side_inc,angle,width,steps-1) 
              )
    ; 

function inspi(side,angle,angle_inc,width=1,steps) =
   steps == 0
      ? []
      : concat( [["F",side,width]],
                [["L",angle,width]] ,
                inspi(side,angle+angle_inc,angle_inc,width,steps-1) 
              )
    ; 

$fn=30;
    
// steps = poly(20,90,4);    //square    
// steps = poly(10,45,8,4);    // an octagon  
// steps =  poly(40,144,5,2);  // a pentagram
// steps = poly(30,135,8);
// steps = poly(20,108,11);
// steps= poly2(5,144,5);
    
// steps= poly2(3,125,40,0.5);
    
// steps =  inspi(5,0,7,width=1,steps=200); 
// echo(steps);

// translate([100,100,0]) 
// linear_extrude(height=10) 

 
// sample turtle graphics

steps = spi(2,2,60,3,50); 
echo(steps);
path=turtle_path(steps);
perimeter = ellipse_points(r=5,e=10,sides=4,theta=45);
echo(perimeter);
echo(path_length(path));
path_knot(path,perimeter);

