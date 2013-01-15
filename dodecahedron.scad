module box() {
    cube([2,2,1], center = true); 
}

module dodecahedron() {
      dihedral = 116.565;
      intersection(){
            box();
            intersection_for(i=[1:5])  { 
                rotate([dihedral, 0, 360 / 5 * i])  box(); 
           }
      }
}

scale(10) dodecahedron();