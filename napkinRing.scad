module box(size) {
    cube([2*size, 2*size, size], center = true); 
}

module octahedron(size) {
      dihedral = 109.47122;
      n = 3;
      intersection(){
            box(size);
            intersection_for(i=[1:n])  { 
                rotate([dihedral, 0, 360 /n * i])  box(size); 
           }
      }
}

module ring(size) {
       difference() {
             union() {
                octahedron(size);
                mirror([0,0,90]) octahedron(size); 
             }
      translate([0,0,-size]) cylinder(r=size/2.5, h=2*size);      
     }
}

$fa = 0.01;
$fs = .5;
size = 40;
echo (size/2.5);
ring(size);
