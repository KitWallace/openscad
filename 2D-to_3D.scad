/*
  CSG operators - union, difference, intersection, hull and minkowski apply to 2D objects

*/

color("red") union(){
 circle(12);
 translate([5,0,0]) circle(10); 
}

translate([-20,0,20])
    text("union",size=10,font="Georgia");


color("green") translate([0,30,0])
   intersection(){
      circle(12);
      translate([5,0,0]) circle(10); 
}

translate([-20,30,10])
   color("red")  text("intersection",size=8,font="Times New Roman");


color("yellow") translate([0,60,0])
   rotate([0,0,45])
      difference(){
        circle(12);
        translate([5,0,0]) circle(10); 
}

translate([-20,60,10])
   color("red")  text("difference",size=6,font="Comic Sans MS");


color("blue") translate([40,0,0])
   hull(){
      circle(12);
      translate([5,0,0]) circle(10); 
}

translate([30,0,10])
   color("red")  text("hull",size=8,font="Times New Roman");


translate([40,30,10])
   color("red")  text("minkowski",size=6,font="Comic Sans MS");


color("black") translate([40,30,0])
   minkowski(){
      square(12);
      circle(5); 
}

translate([40,60,0])
color([.5,.9,.2,0.5]) square([10,20]);

