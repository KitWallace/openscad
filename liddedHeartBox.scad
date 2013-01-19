
module heart(size,height) {
    linear_extrude(height=height) {
      union() {
        square(size,size);
        translate([size/2,size,0]) circle(size/2);
        translate([size,size/2,0]) circle(size/2);
    }
  }
}

module heart_box(size,height,thickness,clearance) {
    difference() {
       minkowski(){
          heart(size,height);
          cylinder(r=thickness+clearance,h=1);
     }
     translate([0,0,thickness]) 
        minkowski() {
          heart(size,height);
          cylinder(r=clearance,h=1);
        }
  }
}
 
module heart_lid(size,thickness,depth,clearance) {
  union()  {
       minkowski(){
            heart(size,thickness);
            cylinder(r=thickness+clearance,h=1);
        }
        translate([0,0,thickness]) 
            heart(size,depth);
  }
}
 
module heart_thing(size,height,thickness,depth,clearance) {
    union() {
       heart_box(size,height,thickness,clearance);
   //    rotate([0,0,180]) translate ([depth,depth,0])  // to place alongside for printing
      rotate([180,0,90]) translate ([0,0,-(height +4 * thickness)])  // to fit over box to check
          heart_lid(size,thickness,depth,clearance);
  }
}

heart_thing(20,10,3,5,0.3);
