module slot(d,l,h=10) {
  hull() {
    cylinder(d=d,h=h);
    translate([l-d,0,0])cylinder(d=d,h=h);
  }
}

module rcube(lx,ly,lz,r1=0.1,r2=1) {
   hull() {
      translate([lx/2-r1,ly/2-r1,-lz/2+r1]) sphere(r1);
      translate([lx/2-r1,-ly/2+r1,-lz/2+r1]) sphere(r1);
      translate([-lx/2+r1,ly/2-r1,-lz/2+r1]) sphere(r1);
      translate([-lx/2+r1,-ly/2+r1,-lz/2+r1]) sphere(r1);
      translate([lx/2-r2,ly/2-r2,lz/2-r2]) sphere(r2);
      translate([lx/2-r2,-ly/2+r2,lz/2-r2]) sphere(r2);
      translate([-lx/2+r2,ly/2-r2,lz/2-r2]) sphere(r2);
      translate([-lx/2+r2,-ly/2+r2,lz/2-r2]) sphere(r2);
   }
}


$fn=30;


difference() {
  union() {
    // cube ([37.85,30.22,6], center=true);
    rcube(37.85,30.22,6,$fn=10);
    translate([-37.85/2-1,0,15-5.9]) rotate([0,90,0]) rcube (24.09,42.43,4,,$fn=10);

  }
  translate([0,0,-2]) cube([33.35,16,4], center=true);
  translate([-8,0,-0.2])
  hull() {
    cylinder(d=16,h=4);
    translate([17,0,2]) cube([16,16, 4 ], center=true);
  }
  translate([-25,16.3, 17]) rotate([0,90,0]) slot(4.5,12.4);
  translate([-25,-16.3, 17]) rotate([0,90,0]) slot(4.5,12.4);;
}

l= 28.09;
d=12.1;
translate([-8,0,2]) {
      difference() {
           cylinder(d=5.84,h=3.61+2.2);
           translate([0,0,11.4]) rotate([0,30,0]) cube([20,20,10], center=true);
      }
      cylinder(d=d,h=2.2);
      hull() {
         translate([0,0,-1]) cylinder(d=d,h=2);
         translate([l - d +4,0,0]) cube([d,d, 2 ], center=true);
      }
}

translate([-17,10, 9]) rotate([0,90,0]) rcube(14,4.5,4);
translate([-17,-10, 9]) rotate([0,90,0]) rcube(14,4.5,4);


