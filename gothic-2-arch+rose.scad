

module opening(x,y,r,d) {
    linear_extrude(height=d)
      union() {
        intersection () {
           translate([x,y,0]) circle(r);
          translate([-x,y,0]) circle(r);
      }
      translate([0,y/2,0]) square(size=[2 *(r-x), y],center=true);
 }
};

module arch(x,y,r,d,t) {
  translate([0,-1,0]) 
      difference () {
         opening(x,y,r+t,d);
         translate([0,0,-1]) opening(x,y,r,d+2*t + 2);
  }
}

module archway (x,y,r,d,t,n) {
  union() {
     for (i=[0:n-1]) {
       arch(x,y,r+i*t,d+i*t,t);
    }
  }
}

module window (x,y,r,d,t,dy,dr) {
  union() {
    arch(x*2,y*1.2,r*2,d,t);
    assign( offset=(r + x) / 2) {
       echo(offset);
       union() {
          translate([offset,0,0])    arch(x/2,y-dy,r-dr,d-t,t);
          translate([-offset,0,0])   arch(x/2,y-dy,r-dr,d-t,t);
       }
    }
  }
}

module ring(r,d,t) {
  linear_extrude(height=d)
    difference () {
      circle(r+t,center=true);
      circle(r,center=true);
    }
}

module rose(r1,r2,r3,d,t) {
 union() {
  difference() {
   union() {
    for (i =[1:4]) {
      rotate([0,0,i*90]) translate([r1,0,0]) ring(r2,d,t);
    }
   }
  translate([0,0,-1]) cylinder(r=r3,h=d+2);
 }
 ring(r3,d,t);
 }
}

module remove_ground() {
   difference()  {
     child(0);
     translate([0,-50,0]) cube([100,100,100],center=true);
  }
}

$fa = 0.01; $fs = 0.5; 

remove_ground () 
   union() {
     window(2,12,6,4,1,-2,2);
     translate([0,20.25,0]) scale(0.37)  rose(4,6,5,8,2);
  }