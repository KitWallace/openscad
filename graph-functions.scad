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
   for(x = [min:step:max-step]) {
      hull() {
          translate(hadamard(f(fn,x),scale)) circle(d=thickness);
          translate(hadamard(f(fn,x+step),scale)) circle(d=thickness);
      }
  }
}


//  sum of sine and cosine functions
function f(fn,x) = 
      fn== 1  ? [x,0.5*sin(x),0] 
    : fn== 2  ? [x,0.3*cos(x),0] 
    : fn== 3  ? [x,0.5*sin(x) + 0.3*cos(x),0]
    : 0;

union() {
  graph(1, 0, 720, 1, scale=[0.05, 15,5]);
  graph(2, 0, 720, 1, scale=[0.05, 15,5]);   
  graph(3, 0, 720, 1, scale=[0.05, 15,10]);
}

line([0,-0.25,2],[40,-0.25,2]);

// Rose curves
/*
n=1;d=5;cycles=3;
function f(fn,x) = 
    fn==1 ? [cos(n/d*x) * cos(x),
            cos(n/d*x) * sin(x),
            0]
   :0;

 graph(1, 0, cycles*360, 1, scale=[20,20,5]);
 
 */
 
 // normal curve
 /*
 function f(fn,x) = 
   fn==1 ?  [x, exp(-x*x),0]
   : 0;
 union() { 
   graph(1, -3,3, 0.1, scale=[20,40,5]);
   graph(1, -3,3, 0.1, scale=[20,20,5]);
     
 }
*/
