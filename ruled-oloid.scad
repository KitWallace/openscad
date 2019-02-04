
module orient_to(origin, normal) {   
      translate(origin)
      rotate([0, 0, atan2(normal.y, normal.x)]) 
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

module slice(x,thickness,params) {
   pa = f(x,params); 
   pb = g(x,params);
   length = norm(pb-pa);
   orient_to(pa,pb-pa)
   cylinder(r=thickness,h=length);   
};

module ruled_surface(limit,step,thickness=1,params) {
 for (x=[0:step:limit])
  hull() {
      slice(x,thickness,params);
      slice(x+step,thickness,params);
  }
};

//Oloid functions
function f(x,p) = [Radius * cos(x*120+60),
                   Radius * sin(x*120+60),
                   0];

function g(x,p) = [Radius * cos(x*120) + Radius,
                   0,
                   Radius * sin(x*120)
                  ];


Height=40;
Radius=20;
Revs=1;
Steps=50;
Step=1/Steps;
Thickness=1;
Sides=10;

$fn= Sides;

module quadrant() {
  ruled_surface(1,Step,Thickness);
}


module half() {
   quadrant();
   mirror() rotate([0,180,0])  quadrant();
}

module whole() {
   half();
   rotate([180,0,0])  half();
}

quadrant();
