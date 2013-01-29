module s (x,y,r) {
   union() {
    intersection () {
        translate([x,y,0]) circle(r);
        translate([-x,y,0]) circle(r);
    }
    translate([0,y/2,0]) square(size=[2 *(r-x), y],center=true);
 }
}

module door(x,y,r,d) {
      linear_extrude(height=d) s(x,y,r);
};

module arch(x,y,r,d,t) {
  translate([0,-1,0]) 
      difference () {
         door(x,y,r+t,d);
         translate([0,0,-1]) door(x,y,r,d+2*t + 2);
  }
}

module archway (x,y,r,d,t,n) {
  union() {
     for (i=[0:n-1]) {
       arch(x,y,r+i*t,d+i*t,t);
    }
  }
}

module triple_arch(x,y,r,d,t,n,dy,dn) {
  assign(offset = r + x + (n + dn -1) * t) {
  echo(offset);
  union() {
    archway(x,y,r,d,t,n);
    translate([offset,0,0])    archway(x,y+dy,r,d,t,n+dn);
    translate([-offset,0,0])   archway(x,y+dy,r,d,t,n+dn);
  }
  }
} 

difference() {
   triple_arch(4,7,8,3,1,4,-2,-2);
   translate([0,-10,-2]) cube([100,20,100],center=true);
}