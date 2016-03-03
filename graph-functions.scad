function hadamard(a,b) =
       len(a)==len(b)
           ?  [for (i=[0:len(a)-1]) a[i]*b[i]] 
           :  [];

module line(p1,p2,thickness=0.5) {
      hull() {
        translate(p1) circle(d=thickness);
        translate(p2) circle(d=thickness);
     }
}      

module graph(fn,min,max,step,scale=[1,1],thickness=0.5) {
   for(t = [min:step:max-step]) {
      hull() {
          translate(hadamard(f(fn,t),scale)) circle(d=thickness);
          translate(hadamard(f(fn,t+step),scale)) circle(d=thickness);
      }
  }
}

// shorthand
module le(height) {linear_extrude(height) children(); }

// examples
// sum of sine and cosine

function f(fn,t) = 
      fn== 1  ? [t,0.5*sin(t)] 
    : fn== 2  ? [t,0.3*cos(t)] 
    : fn== 3  ? [t,0.5*sin(t) + 0.3*cos(t)]
    : 0;

  le(5) graph(1, 0, 720, 1, scale=[0.05, 15]);
  le(5) graph(2, 0, 720, 1, scale=[0.05, 15]);   
  le(10) graph(3, 0, 720, 1, scale=[0.05, 15]);
  le(2) line([0,-0.25],[40,-0.25]);


// Rose curves

/*
n=1;d=5;cycles=3;
function f(fn,t) = 
    fn==1 ? [cos(n/d*t) * cos(t),
            cos(n/d*t) * sin(t)]
   :0;

 le(10) graph(1, 0, cycles*360, 1, scale=[20,20]);
 
*/
 // hormal curve
/*
 function f(fn,t) = 
   fn==1 ?  [t, exp(-t*t)]
   : 0;
   
   
 le(10) {
   graph(1, -3,3, 0.1, scale=[20,40]);
   graph(1, -3,3, 0.1, scale=[20,20]);   
 }

*/
//  cardiod
/*
function f(fn,t) = 
   fn ==1 ? [2 * cos(t) - cos(2 * t),
             2 * sin(t) - sin(2 * t)
             ]
   : 0 ;
   
cycles=1;
le(10) graph(1,0,cycles*360,1,scale=[10,10],thickness=3);
le(5) rotate([0,0,180]) graph(1,0,cycles*360,1,scale=[10,10],thickness=5);

*/

// falling ladder
/*
length = 100;
le(5)
   for(x = [0:length/10:length]) {
      y = sqrt(length * length - x*x);
 //   y = l-x;  for a different curve
      echo(x,y,sqrt(x*x + y*y));
      line([0,x],[y,0]);
}

*/
// lissajous
/*
a=5;b=3;delta=0;

function f(fn,t) =
   fn==1 ?  [sin(a * t + delta),
             sin(b * t )]
   : 0 ;
cycles=1;
le(5) graph(1,0,cycles*360,1,scale=[15,15],thickness=2);            

*/

//  from Wikipedia  parametric equation
/*
a=5;b=3;c=2;d=3;j=3;k=2;

function f(fn,t) =
   fn==1 ?  [cos(a*t) - pow(cos(b*t),j),
             sin(c*t) - pow(sin(d*t),k)]
   : 0 ;

cycles=1;
le(5) graph(1,0,cycles*360,1,scale=[15,15],thickness=2);     

*/
// Epitrochoid 
// if c=b then epicycloid

/*
a=3;b=2;c=4.6;

function f(fn,t) =
   fn==1 ? [ (a+b) * cos(t) - c* cos((a/b+1)*t),
             (a+b) * sin(t) - c* sin((a/b+1)*t)]
   :0;
cycles=2;
 
le(10) graph(1,0,cycles*360,1,scale=[2,2],thickness=2);     

*/
// Hypotrochoid 
// if c=b then hypocycloid
/*
a=3;b=5;c=5;

function f(fn,t) =
   fn==1 ? [ (a-b) * cos(t) - c* cos((a/b-1)*t),
             (a-b) * sin(t) - c* sin((a/b-1)*t)]
   :0;
cycles=5;
 
graph(1,0,cycles*360,1,scale=[15,15],thickness=4);     

*/
// Tricuspoid
/*
a=2;k=5;j=5;
function f(fn,t) =
   fn==1 ? [ a * (j * cos(t) + cos(k*t)),
             a*  (j * sin(t) - sin(k*t))]
   :0;
cycles=1;
$fn=20;
le(5) graph(1,0,cycles*360,1,scale=[2,2],thickness=2);     

*/
