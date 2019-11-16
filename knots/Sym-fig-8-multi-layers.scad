// create layers to be laser cut in perspex to make a knot-shaped space to be filled with liquid
// this knot is the symmetric figure 8 knot via Henry Segerman
// Nov 2019

// generated code from http://kitwallace.co.uk/3d/knot.xq
// create a tube as a polyhedron 
// tube can be open or closed

// polyhedron constructor

function poly(name,vertices,faces,debug=[],partial=false) = 
    [name,vertices,faces,debug,partial];

function p_name(obj) = obj[0];
function p_vertices(obj) = obj[1];
function p_faces(obj) = obj[2];
  
module show_solid(obj) {
    polyhedron(p_vertices(obj),p_faces(obj),convexity=10);
};

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

function loop_points(step,min=0,max=360) = 
    [for (t=[min:step:max-step]) f(t)];

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

//  path with hulls

module hulled_path(path,r) {
    for (i = [0 : 1 : len(path) - 1 ]) {
        hull() {
            translate(path[i]) sphere(r);
            translate(path[(i + 1) % len(path)]) sphere(r);
        }
    }
};

// smoothed path by interpolate between points 

weight = [-1, 9, 9, -1] / 16;

function interpolate(path,n,i) =
        path[(i + n - 1) %n] * weight[0] +
        path[i]             * weight[1] +
        path[(i + 1) %n]    * weight[2] +
        path[(i + 2) %n]    * weight[3] ;

function subdivide(path,i=0) = 
    i < len(path) 
     ? concat([path[i]], 
              [interpolate(path,len(path),i)],
              subdivide(path, i+1))
     : [];

function smooth(path,n) =
    n == 0
     ?  path
     :  smooth(subdivide(path),n-1);


function path_segment(path,start,end) =
    let (l = len(path))
    let (s = max(floor(start * 360 / l),0),
         e = min(ceil(end * 360 / l),l - 1))
    [for (i=[s:e]) path[i]];


function scale(points,scale,i=0) =
     [for (p=points)
       [p[0]*scale[0],p[1]*scale[1],p[2]*scale[2]], 
     ];
   
function slice(points,d) =
     [for (p=points) p[d]] ;
    
function dimensions(points)=
    [for (d=[0:2])    
     max(slice(points,d))- min(slice(points,d))
    ];
    
function map(t, min, max) =
      min + t* (max-min)/360;
    
//  create a knot from a path 

function path_knot(path,r,sides,kscale,phase=45,open=false)  =
  let(loop_points = scale(path,kscale))
  let(circle_points = circle_points(r,sides,phase))
  let(tube_points = tube_points(loop_points,circle_points))
  let(loop_faces = loop_faces(len(loop_points),sides,open))
  poly(name="Knot",
         vertices = tube_points,
         faces = loop_faces);

 // render_type function-2

A=0.35;
B=1-A;
C=2*sqrt(A-A*A);
Phase=45;
Shift=0;
function f(t) =  
       [  
          A*cos(t+90)-B*cos(3*t+90) ,
          A*cos(t)+B*cos(3*t) ,
          C*cos(2*t-Phase)
       ];            
            

 
Scale=35;
Sides=50;  // Sides of rope - must be a divisor of 360
KPhase = 45;  // phase angle for profile (maters for low Sides
Kscale=[1,1,1]*Scale;  // x,y,z scaling
R=8;   // Rope diameter
Step=2 ;  // decrease for finer details
Open = false;   // true if knot is open or partial
Start=0; End=360;  // change for partial path
path = loop_points(Step,Start,End);
knot= path_knot(path,R,Sides,Kscale,KPhase,Open); 
    echo(dimensions(p_vertices(knot)));
mode="layers";

if(mode=="solid") {
    show_solid(knot);
    echo(dimensions(p_vertices(knot)));
}
else {


// this part does the layer creation, with 4 holes for the securing bolts, a notch which slants up the side to guide the layers, a second notch to ensure the layer has the right orientation

thickness=3;  // of acrylic
height=95;  // of stack, including top and bottom layers
layers = floor(height/thickness); // no of layers needed
echo(layers);

side=95; // side of bounding square
// holes for clamping bolts
hole_inset=6; // from edge
hole_diameter=6;  
hole_d=side/2-hole_inset;  // hole distance
hole_radius=hole_diameter/2;  // hole radius

//locating notches
notch_side=2;

// layers
layer_start=1;
layer_count=5;
rows=3;
sep=5;

for (l =[0:layer_count-1]) {
   i=l % rows;
   j= floor(l / rows); 
   layer=layer_start + l;
echo(i,j,layer);   
offset = -height/2 +thickness*layer;
echo(offset);
translate([side/2 + sep + j * (side+sep),
           side/2 + sep + i * (side+sep),
          0]) //position in laser bed
difference() {
   square(side,center=true);
   projection(cut=true) 
         translate([0,0,offset]) 
            show_solid(knot);
// holes for clamping bolts
   translate([hole_d,hole_d,0])circle(hole_radius,$fn=20);
   translate([-hole_d,hole_d,0])circle(hole_radius,$fn=20);
   translate([-hole_d,-hole_d,0])circle(hole_radius,$fn=20);
   translate([hole_d,-hole_d,0])circle(hole_radius,$fn=20);
// layer order notch
   translate([-hole_d+2*(layer+5),-side/2,0])
         square(notch_side,center=true);
// layer orientation notch
   translate([-side/2,0,0])
         square(notch_side,center=true);
}
}
}
