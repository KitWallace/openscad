// Mobius trefoil
//Radius of strip
Radius = 20;
//Width of Strip
Width = 8;
//Thickness of strip
Thickness=2;
//Half twists 0 is a collar, 1 is the mobius strip, 2 = full twist
Halftwist=1; 
//Start Angle - important if Halftwist = 0
Start=0;
//Step size in degrees
Step = 2;


// trefoil function
function f(t) =  
   [ sin(t) + 2 * sin (2 * t),
     cos(t) - 2 * cos ( 2 * t),
     - sin (3 * t)
   ];

module mobius_strip(radius,width,thickness,step=1, halftwist=3,start=90) {
  for (i = [0:step:360])
    hull() {
           translate(radius*f(i))
             rotate([0,start+i * halftwist * 0.5, 0]) 
               cube([width,Delta,thickness], center=true);
           translate(radius*f(i+step))
             rotate([0,start+(i+step)* halftwist * 0.5 , 0]) 
               cube([width,Delta,thickness], center=true);
       }
}

Delta= 0.1;

mobius_strip(Radius, Width, Thickness, Step, Halftwist,Start);
