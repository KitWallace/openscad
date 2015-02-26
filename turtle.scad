/*
   turtle simulation 
   
   Kit Wallace 
   
   Code licensed under the Creative Commons - Attribution - Share Alike license.

  The project is documented in my blog 
   http://kitwallace.tumblr.com/tagged/turtle

*/

function flatten(l) = [ for (a = l) for (b = a) b ] ;

module ruler(n) {
   for (i=[0:n-1]) 
       translate([(i-n/2 +0.5)* 10,0,0]) cube([9.8,5,2], center=true);
}

module turtle (steps, i=0) {
  if ( i < len(steps)) {
   step = steps[i];
   command=step[0];
      
   if(command=="F") {
       distance = step[1];
       width=step[2];
       translate([distance/2,0]) 
            square([distance,width],center=true);
       translate([distance,0]) 
         turtle(steps,i+1);
      }
   else if (command=="L") {
      angle=step[1];
      width=step[2];
      circle(width/2);
      rotate([0,0,angle])
         turtle(steps,i+1);
      }
   else if (command=="R") {
      angle=step[1];
      width=step[2];
      circle(width/2);
      rotate([0,0,-angle])
         turtle(steps,i+1);
      }
   else
      echo("unknown command" ,step);
  }
};

//  basic poly 
function poly(side,angle,steps,width=1) =
   flatten(
    [for (i=[0:steps-1])
     [ ["F",side,width],["R",angle,width]]
    ]);

function poly2(side,angle,steps,width=1) =
   flatten(
    [for (i=[0:steps-1])
     [ ["F",side,width],["R",angle,width],["F",side,width],["R",2*angle,width] ]
    ]);

function spi(side,side_inc,angle,width=1,steps) =
   steps == 0
      ? []
      : concat( [["F",side,width]],
                [["L",angle,width]] ,
                spi(side+side_inc,side_inc,angle,width,steps-1) 
              )
    ; 
    
$fn=30;
// steps = poly(20,90,4);      //square
// steps = poly(10,45,8,4);    // an octagon  
// steps =  poly(40,144,5,2);  // a pentagram
// steps = poly(30,135,8);
// steps = poly(20,108,11);
// steps= poly2(5,144,5);
// steps= poly2(3,125,40,0.5);
    
steps = spi(2,1,60,3,20);
echo(steps);
    
linear_extrude(height=10)
    turtle(steps);

*ruler(10);
