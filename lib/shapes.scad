PI = 3.14159265359;

//  2-D primitives 
module triangle(radius)
{
  o= radius*sin(30);
  a= radius*cos(30);
  polygon([[-a,-o],[0,radius],[a,-o]]);
}

module hexagon(w) {
   intersection_for (i=[1:3])  rotate([0,0,i *360 /3 ])   
       square([2*w,w], center=true);
}

module hexagon_2(w) {
  intersection_for (i=[1:2])  rotate([0,0,i *360 /2 ])   
       triangle(w);
}

module decagon(w) {
  intersection_for (i=[1:5])  rotate([0,0,i *360 /5 ])   
       square([2*w,w], center=true);
}

module dodecahedron(w) {
  intersection_for (i=[1:4])  rotate([0,0,i *360 /4 ])   
       triangle(w);
}

module 14agon(w) {
  intersection_for (i=[1:7])  rotate([0,0,i *360 /7 ])   
       square([2*w,w], center=true);
}

module right_triangle (length,height,angle) {
    linear_extrude(height=height)
        difference() {
           square(length);
           rotate(angle) square(2*length);
     }
  }
