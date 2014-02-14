// Mobius heart

//Radius of strip
Radius = 20;
//Width of Strip
Width = 5;
//Thickness of strip
Thickness=0.4;
//Half twists 0 is a collar, 1 is the mobius strip, 2 = full twist
Halftwist=2; 
//Start Angle - important if Halftwist = 0
Start=0;
//Step size in degrees
Step = 2;

function f(t) = 
[ 16*pow(sin(t),3),
  13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t),
  10*sin(t)
];


module mobius_strip(radius,width,thickness,step=1, halftwist=3,start=90) {
  for (i = [0:step:360])
    hull() {
           translate(f(i))
             rotate([0,start+i * halftwist * 0.5, 0]) 
               cube([width,Delta,thickness], center=true);
           translate(f(i+step))
             rotate([0,start+(i+step)* halftwist * 0.5 , 0]) 
               cube([width,Delta,thickness], center=true);
       }
}

Delta= 0.1;

mobius_strip(Radius, Width, Thickness, Step, Halftwist,Start);
