/*
  CSG operators - union, difference, intersection, hull and minkowski apply to 3D objects

*/

color("red") union(){
  sphere(10);
  cube(12); 
}

translate([-20,0,20])
    text("union",size=10,font="Georgia");


color("green") translate([0,30,0])
   intersection(){
    sphere(10);
    cube(12); 
}

translate([-20,30,20])
   color("red")  text("intersection",size=8,font="Times New Roman");


color("yellow") translate([0,60,0])
   rotate([0,30,45])
      difference(){
      sphere(10);
      cube(12); 
}

translate([-20,60,20])
   color("red")  text("difference",size=6,font="Comic Sans MS");


color("blue") translate([40,0,0])
   hull(){
      sphere(10);
      cube(12); 
}

translate([30,0,20])
   color("red")  text("hull",size=8,font="Times New Roman");


translate([40,30,20])
   color("red")  text("minkowski",size=6,font="Comic Sans MS");


color("black") translate([40,30,0])
   minkowski(){
      cube(10);
     sphere(5); 
}

translate([40,90,0])
color([.5,.9,.2,0.5]) cube([10,20,30],center=true);

translate([0,90,0])
color([.8,.6,.1,1]) cylinder(r1=5,r2=10,h=20);

