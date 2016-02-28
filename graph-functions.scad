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


//  sample main 
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
