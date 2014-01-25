// rolling knot code with thanks to mathgrrl and nop head

module disc_p2p(p1, p2, r) {
      assign(p = p2 - p1)
      translate(p1 + p/2)
      rotate([0, 0, atan2(p[1], p[0])])
      rotate([0, atan2(sqrt(pow(p[0], 2)+pow(p[1], 2)),p[2]), 0])
      render() cylinder(h = 0.1, r1 = r, r2 = 0);
};

function f(a,b,t) =   // rolling knot
   [ a * cos (3 * t) / (1 - b* sin (2 *t)),
     a * sin( 3 * t) / (1 - b* sin (2 *t)),
     1.8 * b * cos (2 * t) /(1 - b* sin (2 *t))
   ];

module tube(a, b, r, step) {
   for (t=[0: step: 360])
       assign (p0 = f(a,b,t), 
               p1 = f(a,b,t + step ),
               p2 = f(a,b,t + 2 * step))
       render() hull() {
          disc_p2p (p0,p1,r);
          disc_p2p (p1,p2,r);   
       }
};

$fn=20;
a = 0.8;
scale(15) tube (a, sqrt (1 - a * a), 0.3, 2);
