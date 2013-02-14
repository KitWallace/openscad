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

// F5 doesnt render correctly but its really OK

module sector(a) {
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

