
module arch(x,y,r,d) {
    linear_extrude(height=d)
      union() {
        intersection () {
           translate([x,y,0]) circle(r);
           translate([-x,y,0]) circle(r);
      }
      translate([0,y/2,0]) square(size=[2 *(r-x), y],center=true);
 }
};

module archway(x,y,r,d,t) {
  translate([0,-1,0]) 
      difference () {
         arch(x,y,r,d);
         translate([0,0,-1]) arch(x,y,r-t,d+ 2);
  }
}

module nested_archway (x,y,r,d,t,n) {
  union() {
     for (i=[0:n-1]) {
       archway(x,y,r+i*t,d+i*t,t);
    }
  }
}

function v_sum_r(v,n,k) =
      k > n ? 0 : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

module nested_archway_2 (x,y,r,d,t,n) {
  union() {
      archway(x,y,r,d[0], t[0]);
      if (n > 0)
       for (i=[1:n]) {
       assign(dt =  v_sum(t,i), dd = v_sum(d,i)) {
          echo(dt); echo(dd);
          archway(x,y,r+dt,d[0]+dd, t[i-1]);
      }
    }
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
    nested_archway_2(2,10,6,[1,3,1],[1,3,1],3);