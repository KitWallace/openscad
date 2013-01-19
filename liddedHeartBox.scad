
module heart_shape(size) {
      union() {
        square(size,size);
        translate([size/2,size,0]) circle(size/2);
        translate([size,size/2,0]) circle(size/2);
    }
}

module heart(size,thickness,height) {
   linear_extrude(height=height) 
          minkowski() {
               heart_shape(size);
               circle(thickness);
        }
}

module heart_box(size,height,thickness,clearance) {
    difference() {
         heart(size,thickness + clearance,height);
         translate([0,0,thickness])  heart(size,clearance,height);
    }
}
 
module heart_lid(size,thickness,depth,clearance) {
  union()  {
        heart(size,thickness+clearance,thickness);
        translate([0,0,thickness]) heart(size,0.1, depth); 
  }
}
 
module heart_thing(size,height,thickness,depth,clearance) {
    union() {
       heart_box(size,height,thickness,clearance);
   //   rotate([0,0,180]) translate ([10,10,0])  // to place alongside for printing
      rotate([180,0,90]) translate ([0,0,- 2 * height ])  // to fit over box to check
          heart_lid(size,thickness,depth,clearance);
  }
}

heart_thing(20,10,3,5,0.5);
