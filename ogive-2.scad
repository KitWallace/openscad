function v_sum_r(v,n,k) =
      k > n ? 0 : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

// compute the x,y and r parameters for an arch with a given width,height
//  and sharpness 
//  messy code because function body is very restricted
// return array [x,y,r]

function ogive_r(w,h,s) =
       (pow(w/2,2) + pow(w * s,2) )/ w;
function ogive(w,h,s) =
       [ogive_r(w,h,s) - (w/2), h - w * s, ogive_r(w,h,s)];

// construct arch 
module arch(x,y,r) {
      union() {
        intersection () {
           translate([x,y,0]) circle(r);
           translate([-x,y,0]) circle(r);
      }
      translate([0,y/2,0]) square(size=[2 *(r-x), y],center=true);
  }
}

delta=1;

module archway_out(x,y,r,d,t) { 
  linear_extrude(height=d)
     difference () {
         arch(x,y,r+t,d);
         translate([0,0,-delta]) arch(x,y,r,d+2*delta);
  }
}

module archway_in(x,y,r,d,t) {
  linear_extrude(height=d)
     difference () {
         arch(x,y,r,d);
         translate([0,0,-delta]) arch(x,y,r-t,d+2*delta);
  }
}

module nested_archway_xy_out (x,y,r,d,t,n) {
  union() {
       for (i=[1:n]) {
          assign(dt =  v_sum(t,i-1)) {
              echo(t[i-1],dt);
              archway_out(x,y,r+dt,d[i-1], t[i-1]);
         }
    }
  }
}

module nested_archway_xy_in (x,y,r,d,t,n) {
  union() {
       for (i=[1:n]) {
          assign(dt =  v_sum(t,i-1)) {
              echo(t[i-1],dt);
              archway_in(x,y,r-dt,d[i-1], t[i-1]);
         }
    }
  }
}

module nested_archway_out(width,height,sharpness,depth,thickness,n) {
    assign(p = ogive(width,height,sharpness))
    nested_archway_xy_out(p[0],p[1],p[2],depth,thickness,n);
}

module nested_archway_in(width,height,sharpness,depth,thickness,n) {
    assign(p = ogive(width,height,sharpness))
    nested_archway_xy_in(p[0],p[1],p[2],depth,thickness,n);
}

module remove_ground() {
   difference()  {
     child(0);
     translate([0,-49.98,0]) cube([100,100,100],center=true);
  }
}

$fa = 0.01; $fs = 0.5; 

remove_ground () 
    nested_archway_out(10,30,0.8,[1,2,3,4],[2,1,3,1],4);

*translate([0,0,150])
  remove_ground () 
    nested_archway_in(20,40,0.8,[4,3,2,1],[2,1,3,1],4);
