
module light_square(side,edge) {

difference() {
      square(side,center=true);
      square(side - edge*2,center=true);
}

translate([side/2-edge,side/2 + edge,0]) 
 difference() {
       circle(3);
       circle(1);
 }
 translate([-side/2+edge,side/2 + edge,0]) 
 difference() {
       circle(3);
       circle(1);
 }
difference() {
   square(side-edge*2,center=true);
   children();
}
}

module light_circle(d,edge) {
 eps=0.0001;
 difference() {
      circle(d/2);
      circle(d/2 - edge);
 }

 translate([0,d/2+edge,0]) 
  difference() {
       circle(3);
       circle(1);
 }
 difference() {
   circle(d/2-edge+eps);
   children();
 }
}


