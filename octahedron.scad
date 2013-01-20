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

octahedron(20);