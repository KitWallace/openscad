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
               circle(thickness+0.1);
        }
}

module heart_box(size,height,thickness) {
    difference() {
         heart(size,thickness,height);
         translate([0,0,thickness])  heart(size,0,height);
    }
}
 
heart_box(20,10,3);
