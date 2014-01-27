
function length(p) = sqrt(pow(p[0],2) + pow(p[1],2) + pow(p[2],2));

module cylinder_p2p(p1, p2, r) {
      assign(p = p2 - p1)
      assign(distance = length(p))
      translate(p1 + p/2)
      rotate([0, 0, atan2(p[1], p[0])]) 
      rotate([0, atan2(sqrt(pow(p[0], 2)+pow(p[1], 2)),p[2]), 0])
      cylinder(h = distance, r = r,center=true);
};

function f(t) =   // rolling knot
   [ a * cos (3 * t) / (1 - b* sin (2 *t)),
     a * sin( 3 * t) / (1 - b* sin (2 *t)),
     1.8 * b * cos (2 * t) /(1 - b* sin (2 *t))
   ];

module tube( r, step) {
   for (t=[0: step: 360]) {
       assign (p0 = f(t))
       assign (p1 = f(t +2* step ))
          cylinder_p2p (p0,p1,r);
   }
};

$fn=40;
a = 0.8;
b = sqrt (1 - a * a);
r = 0.3;
step = 0.5;

scale(15) tube (r,step);
