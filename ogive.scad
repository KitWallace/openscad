module arch(x,y,r) {
      union() {
        intersection () {
           translate([x,y,0]) circle(r);
           translate([-x,y,0]) circle(r);
      }
      translate([0,y/2,0]) square(size=[2 *(r-x), y],center=true);
 }
}


module ogive_arch(width,height,sharpness) {
  assign(base=width/2)
  assign(length = base * sharpness)
  assign(radius = (base * base + length * length) / (2 * base))
  assign(x= radius - base,y = height-length)
     arch(x,y,radius);
}

module ogive_archway(width,height,sharpness,thickness) {
      difference () {
         ogive_arch(width,height,sharpness);
         ogive_arch(width- 2* thickness,height-thickness,sharpness);
  }
}

module ogive_solid_archway(width,height,sharpness,thickness,depth) {
   linear_extrude(height=depth)
      ogive_archway(width,height,sharpness,thickness);
}

function v_sum_r(v,n,k) =
      k > n ? 0 : v[k] + v_sum_r(v,n,k+1);

function v_sum(v,n) = v_sum_r(v,n-1,0);

module variable_nested_archway (width,height,sharpness,thickness,depth,n) {
  union() {
       for (i=[0:n-1]) {
       assign(dt =  v_sum(thickness,i+1) ) {
          echo(dt); 
          ogive_solid_archway(width + 2 * dt, height+ dt, sharpness,thickness[i],depth[i]);
      }
    }
  }
}

module remove_ground() {
   difference()  {
     child(0);
     translate([0,-49.9,0]) cube([100,100,100],center=true);
  }
}
$fa = 0.01; $fs = 2; 

remove_ground() 
    variable_nested_archway(15,30,1.5,[2,5,2,1],[1,3,4,5],4);
