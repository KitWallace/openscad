// transformations

use <functions.scad>; 
MAX=200;

module facade () {
    difference()  {  
         rotate([0,90,0])  child(0);
         translate([MAX-1,0,-MAX]) cube (2*MAX,center=true);
    }
}

module bottom(x) {
     difference() {
          child(0);
          translate([0,0,MAX+x]) cube(2*MAX,center=true);
   
  }
}

module top(x) {
      difference() {
          translate([0,0,-x]) child(0);
          translate([0,0,-MAX]) cube(2*MAX,center=true);
     }
}

module stack (separations) {
    union() {
       for (i = [1:len(separations)]) {
           assign(offset = v_sum(separations,i)) {
               echo("i",i,"offset",offset);
               translate ([0,0,offset])
               child(i-1);
          }
      }
   }
}

module sector (a) {
//  2 d angle slice of the child
    module sq() {
      assign(r=100)
      translate([0, r/2,0]) square(r,center=true);
    }
    if (a <= 180) 
        difference() {
           child(0);
           rotate([0,0, a])  sq();
           rotate([0,0, 180])  sq();
       }
   else
       rotate(- (360 - a))
          difference () {
             child(0);
             difference() {
                child(0);
                rotate([0,0, 360-a])  sq();
                rotate([0,0, 180])  sq();
          }
      }
}


module sector_3D(a) {
// 3D angle slice of the child 
// F5 doesnt render correctly but its really OK

    module block() {
      assign(r=100)
      translate([0, r/2,0]) cube(r,center=true);
    }
    if (a <= 180) 
        difference() {
           child(0);
           rotate([0,0, a])  block();
           rotate([0,0, 180])  block();
       }
   else
       rotate(- (360 - a))
          difference () {
             child(0);
             difference() {
                child(0);
                rotate([0,0, 360-a])  block();
                rotate([0,0, 180])  block();
          }
      }
}

module circular_replicate (radius,n,offset=0) {
for (i = [1:n]) 
   rotate([0,0,offset + i * 360/n]) translate([radius,0,0])
         child(0);
}

module grid_replicate(x_spacing,y_spacing,x_n,y_n) {
    for (i = [0:x_n -1])
       for (j=[0:y_n -1])
          translate([i *x_spacing , j*y_spacing,0]) child();
}

