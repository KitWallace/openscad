module box() {
    cube([2,2,1], center = true); 
}

module hedron(dihedral,n) {
       intersection(){
            box();
            intersection_for(i=[1:n])  { 
                rotate([dihedral, 0, 360 / n * i])  box(); 
           }
      }
}

a=$t*360;
echo(a);
scale(20) hedron(a,5);
  
  