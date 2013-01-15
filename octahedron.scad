module box() {
    cube([2,2,1], center = true); 
}

module octahedron() {
      dihedral = 109.47122;
      n = 3;
      intersection(){
            box();
            intersection_for(i=[1:n])  { 
                rotate([dihedral, 0, 360 /n * i])  box(); 
           }
      }
}

scale(10) octahedron();