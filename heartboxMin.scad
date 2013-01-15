
module heart(s,h) {
    linear_extrude(height=h) {
      union() {
        square(s,s);
        translate([s/2,s,0]) circle(s/2);
        translate([s,s/2,0]) circle(s/2);
    }
  }
}

module heart_box(s,h,f) {
  union() {
    difference() {
       minkowski(){
          heart(s+f,h);
          cylinder(r=2,h=2);
     }
    translate([0,0,2]) heart(s+f,h+2);
  }

  rotate([0,0,180]) translate ([5,5,0]) 
//  rotate([180,0,90]) translate ([f,f,-h-2])  // to fit over box to check
 {
       minkowski(){
         heart(s,1);
         cylinder(r=2+f,h=1);
      }
      translate([0,0,1]) heart(s,2);
  }
 }
}

$fa = 0.01;
$fs = 0.5;
heart_box(20,15,0.5);