/*
   origami ship
   straight sides
   
   Kit Wallace

*/
// length of bow from centre
lb=15; 
// height of bow
hb=12;
// width midships
wm=6; 
// height midships
hm=3; 
// waterline length e.g. from centre eg. half length of bow
wl=8.5; 
// width of hull from centre  - here this is computed so sides has no crease
// wh; 

// height of sail
h=10; 
//Thickness of paper
thickness=1;
// sphere quality
steps = 20;
// overall scale
scale=2;

module double(axis) { 
      union() {
          children();
          mirror(axis) children();
      }
  }
module plane(s,t=0.5) {
    hull()
    for (i=[0:len(s) -1])
       translate(s[i]) sphere(t/2);     
    } 

module ground(size=50) {
   translate([0,0,-size]) cube(2*size,center=true);
}

// functions to make 4 points coplanar - by computing the value of one value so that determinat of matri of 4 points is zero

function det4(m) =
// from http://www.euclideanspace.com/maths/algebra/matrix/functions/determinant/fourD/index.htm
    m[0][3] * m[1][2] * m[2][1] * m[3][0] - m[0][2] * m[1][3] * m[2][1] * m[3][0]- m[0][3] * m[1][1] * m[2][2] * m[3][0]+m[0][1] * m[1][3] * m[2][2] * m[3][0]+ m[0][2] * m[1][1] * m[2][3] * m[3][0]-m[0][1] * m[1][2] * m[2][3] * m[3][0]- m[0][3] * m[1][2] * m[2][0] * m[3][1]+m[0][2] * m[1][3] * m[2][0] * m[3][1]+ m[0][3] * m[1][0] * m[2][2] * m[3][1]-m[0][0] * m[1][3] * m[2][2] * m[3][1]- m[0][2] * m[1][0] * m[2][3] * m[3][1]+m[0][0] * m[1][2] * m[2][3] * m[3][1]+ m[0][3] * m[1][1] * m[2][0] * m[3][2]-m[0][1] * m[1][3] * m[2][0] * m[3][2]- m[0][3] * m[1][0] * m[2][1] * m[3][2]+m[0][0] * m[1][3] * m[2][1] * m[3][2]+ m[0][1] * m[1][0] * m[2][3] * m[3][2]-m[0][0] * m[1][1] * m[2][3] * m[3][2]- m[0][2] * m[1][1] * m[2][0] * m[3][3]+m[0][1] * m[1][2] * m[2][0] * m[3][3]+ m[0][2] * m[1][0] * m[2][1] * m[3][3]-m[0][0] * m[1][2] * m[2][1] * m[3][3]- m[0][1] * m[1][0] * m[2][2] * m[3][3]+m[0][0] * m[1][1] * m[2][2] * m[3][3];

// to iteratively solve det(x) = -
function secant(xn,xn1,eps=0.001) =
     let(fxn=f(xn))
     let(fxn1=f(xn1))
     let(x = xn - fxn*(xn - xn1)/ (fxn - fxn1))
     abs(f(x) - fxn) < eps
        ? x
        : secant(x,xn,eps);
 

p1=[lb,0,hb];
p2=[wl,0,0];
p3=[0,wm,hm];
p5=[0,0,h];

function f(x) = 
 let(m = [  
       [lb,0,hb,1],
       [wl,0,0,1],
       [0,wm,hm,1],
       [0,x,0,1]]
     )
  det4(m);
  
wh= secant(0,wm);
echo(wh);

p4=[0,wh,0];

module ship_q(t) {
   plane([p1,p2,p3],t);
   plane([p2,p3,p4],t);
   plane([p4,p2,p5],t);
};

$fn=steps;
scale(scale) 
 difference() {
  double([0,1,0]) 
     double([1,0,0]) 
         ship_q(thickness); 
 * ground();
 }
