/*
Durangle in an equilateral traingle
http://kmoddl.library.cornell.edu/model.php?m=4

*/

module durangle(r,x,h) {
    intersection () {
       translate([r-x,0,0]) cylinder(r=r,h=h);
       translate([-(r-x),0,0]) cylinder(r=r,h=h);
   }
}



$fa = 0.01;
$fs = 0.5; 

union () {
  // duangle and handle 
  translate ([20,0,0]) 
    union() {                    
        translate([0,2.1,0]) durangle(10,3,8); 
        translate([0,-3.5,7.5 ]) cylinder(r=1,h=6);
    }
  // equilateral cavity
  difference() {
      cylinder(r=12, h=10);
          translate([0,0,2]) linear_extrude(height=12) polygon(  
                  [[0.0, 10.0], 
                  [8.6602540378443873, -4.9999999999999982],
                  [-8.6602540378443837, -5.0000000000000044]
          ]);
   }
}


