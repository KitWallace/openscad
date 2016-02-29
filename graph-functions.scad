function hadamard(a,b) =
       len(a)==len(b)
           ?  [for (i=[0:len(a)-1]) a[i]*b[i]] 
           :  [];

module line(p1,p2,thickness=0.5) {
    linear_extrude(p1.z)
      hull() {
        translate(p1) circle(d=thickness);
        translate(p2) circle(d=thickness);
     }
}    

module graph(fn,min,max,step,scale=[1,1,1],thickness=0.5) {
   linear_extrude(scale.z)
   for(t = [min:step:max-step]) {
      hull() {
          translate(hadamard(f(fn,t),scale)) circle(d=thickness);
          translate(hadamard(f(fn,t+step),scale)) circle(d=thickness);
      }
  }
}
/*
function f(fn,t) = 
      fn== 1  ? [t,0.5*sin(t),0] 
    : fn== 2  ? [t,0.3*cos(t),0] 
    : fn== 3  ? [t,0.5*sin(t) + 0.3*cos(t),0]
    : 0;

union() {
  graph(1, 0, 720, 1, scale=[0.05, 15,5]);
  graph(2, 0, 720, 1, scale=[0.05, 15,5]);   
  graph(3, 0, 720, 1, scale=[0.05, 15,10]);
}

line([0,-0.25,2],[40,-0.25,2]);

*/

// Rose curves
/*
n=1;d=5;cycles=3;
function f(fn,t) = 
    fn==1 ? [cos(n/d*t) * cos(t),
            cos(n/d*t) * sin(t),
            0]
   :0;

 graph(1, 0, cycles*360, 1, scale=[20,20,5]);
 
*/
 // hormal curve
 /*
 function f(fn,t) = 
   fn==1 ?  [t, exp(-t*t),0]
   : 0;
 union() { 
   graph(1, -3,3, 0.1, scale=[20,40,5]);
   graph(1, -3,3, 0.1, scale=[20,20,5]);
     
 }
*/

//  cardiod
/*
function f(fn,t) = 
   fn ==1 ? [2 * cos(t) - cos(2 * t),
             2 * sin(t) - sin(2 * t),
             0]
   : 0 ;
   
cycles=1;
graph(1,0,cycles*360,1,scale=[10,10,8],thickness=3);
rotate([0,0,180]) graph(1,0,cycles*360,1,scale=[10,10,5],thickness=4);

*/

// falling ladder
/*
length = 100;
   for(x = [0:length/10:length]) {
      y = sqrt(length * length - x*x);
 //   y = l-x;  for a different curve
      echo(x,y,sqrt(x*x + y*y));
      line([0,x,10],[y,0,0],1);
}
*/

// lissajous
/*
a=5;b=3;delta=0;

function f(fn,t) =
   fn==1 ?  [sin(a * t + delta),
             sin(b * t ),
             0]
   : 0 ;
cycles=1;
graph(1,0,cycles*360,1,scale=[15,15,8],thickness=2);            

*/

//

a=5;b=3;c=2;d=3;j=3;k=2;

function f(fn,t) =
   fn==1 ?  [cos(a*t) - pow(cos(b*t),j),
             sin(c*t) - pow(sin(d*t),k),
             0]
   : 0 ;

cycles=1;
graph(1,0,cycles*360,1,scale=[15,15,8],thickness=2);     
