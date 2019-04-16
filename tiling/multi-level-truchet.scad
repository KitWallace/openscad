
function arc(start,end,d,step) =
  let(steps = (end-start)/step)
  [for (i = [0:steps])
     let(a=start+i*step)
     [d*cos(a),d*sin(a)]
  ];
//echo(arc(0,90,10));
  
module sweep(start,end,d,r,step=1) {
   ps = arc(start,end,d,step);
   for (i  = [0:len(ps)-2])
       hull(){
           translate(ps[i]) circle(r=r);
           translate(ps[i+1]) circle(r=r);
       }
}   

$fn=20;

module truchet(size) {
  d=size/2;
  r=size/6;
translate([-size/2,-size/2,0])    

  union() {
   sweep(0,90,d,r);
   translate([size,size]) 
     rotate([0,0,180]) 
        sweep(0,90,d,r);
  }
//  color("red") square([size,size], center=true);
}

module anti_truchet(size) {
 r=size/3;  
 union() {
      translate([-size/2,-size/2,0])    
      union() {
          translate([0,0]) circle(r=r);
          translate([size,size]) circle(r=r);
          translate([size,0]) circle(r=r,center=true);
          translate([0,size]) circle(r=r,center=true);
         
      }
      difference() {
         square([size,size], center=true);
         truchet (size);
       } 
 }
 }
size=20;
 
 rotate([0,0,90]) truchet(size);
 translate([size/2+size/4,size/4]) rotate([0,0,0]) anti_truchet(size/2);
 translate([size/2+size/4,-size/4]) rotate([0,0,90]) anti_truchet(size/2);
     
